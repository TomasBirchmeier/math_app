import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/exam_catalog.dart';
import '../models/user.dart';
import '../models/exam.dart';
import '../services/remote_submission_service.dart';

class AppState extends ChangeNotifier {
  AppState();

  static const String remoteClassroomId = 'quantplus-main';

  static const List<String> topics = [
    'Probabilidad',
    'Álgebra',
    'Números',
    'Geometría',
  ];

  final List<User> _users = const [
    User(
      id: 'admin',
      displayName: 'Profesor Tomás',
      role: UserRole.admin,
      password: 'admin2806',
      email: 'tomas@quantplus.cl',
    ),
    User(
      id: 'sofia',
      displayName: 'Sofía Torres',
      role: UserRole.student,
      password: 'sofia456',
      email: 'birchmeiertomas@gmail.com',
    ),
    User(
      id: 'Agustin_Hermosilla',
      displayName: 'Agustín Hermosilla',
      role: UserRole.student,
      password: 'agustin2010',
      email: 'agustin.hermosilla@quantplus.cl',
    ),
    User(
      id: 'Cristobal_Rojas',
      displayName: 'Cristóbal Rojas',
      role: UserRole.student,
      password: 'cristobal2007',
      email: 'cristobal.rojas@quantplus.cl',
    ),
    User(
      id: 'mateo',
      displayName: 'Mateo Díaz',
      role: UserRole.student,
      password: 'mateo456',
      email: 'mateo.diaz@quantplus.cl',
    ),
    User(
      id: 'valentina',
      displayName: 'Valentina Ruiz',
      role: UserRole.student,
      password: 'valen456',
      email: 'valentina.ruiz@quantplus.cl',
    ),
  ];

  final Map<String, Map<String, int>> _studentProgress = {};
  final Map<String, ExamAttempt> _examAttempts = {};
  final Map<String, Map<int, String>> _examDrafts = {};
  User? _currentUser;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  User? get currentUser => _currentUser;
  List<User> get users => List.unmodifiable(_users);
  Iterable<User> get students =>
      _users.where((user) => user.role == UserRole.student);
  List<ExamAttempt> get examAttempts {
    final attempts = _examAttempts.values.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return attempts;
  }

  ExamAttempt? examAttemptFor(String examId, String userId) =>
      _examAttempts['$examId|$userId'];

  List<ExamAttempt> examAttemptsFor(String examId) =>
      _examAttempts.values.where((attempt) => attempt.examId == examId).toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

  List<ExamAttempt> attemptsForUser(String userId) =>
      _examAttempts.values.where((attempt) => attempt.userId == userId).toList()
        ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProgress = prefs.getString(_progressKey);
    if (rawProgress != null) {
      final decoded = jsonDecode(rawProgress) as Map<String, dynamic>;
      decoded.forEach((userId, data) {
        final topicData = <String, int>{};
        final record = data as Map<String, dynamic>;
        record.forEach((topic, value) {
          topicData[topic] = (value as num).toInt();
        });
        _studentProgress[userId] = topicData;
      });
    }
    final rawAttempts = prefs.getString(_examAttemptsKey);
    if (rawAttempts != null && rawAttempts.isNotEmpty) {
      final decoded = ExamAttempt.decodeList(rawAttempts);
      for (final attempt in decoded) {
        final key = '${attempt.examId}|${attempt.userId}';
        _examAttempts[key] = attempt;
      }
    }
    final rawDrafts = prefs.getString(_examDraftsKey);
    if (rawDrafts != null && rawDrafts.isNotEmpty) {
      final decoded = jsonDecode(rawDrafts) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        final answers = (value as Map<String, dynamic>).map(
          (question, answer) => MapEntry(int.parse(question), answer as String),
        );
        _examDrafts[key] = answers;
      });
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String id, String password) async {
    final normalizedId = id.trim().toLowerCase();
    final normalizedPassword = password.trim();
    User? foundUser;
    for (final candidate in _users) {
      if (candidate.id.toLowerCase() == normalizedId) {
        foundUser = candidate;
        break;
      }
    }
    if (foundUser == null || foundUser.password != normalizedPassword) {
      return false;
    }
    _currentUser = foundUser;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Map<String, int> progressFor(String userId) {
    final existing = _studentProgress[userId];
    if (existing != null) {
      return Map<String, int>.from(existing);
    }
    final emptyProgress = {for (final topic in topics) topic: 0};
    _studentProgress[userId] = emptyProgress;
    return Map<String, int>.from(emptyProgress);
  }

  int totalPointsFor(String userId) {
    return progressFor(userId).values.fold(0, (prev, score) => prev + score);
  }

  Future<void> recordScore({
    required String userId,
    required String topic,
    required int points,
  }) async {
    final topicProgress = progressFor(userId);
    topicProgress[topic] = (topicProgress[topic] ?? 0) + points;
    _studentProgress[userId] = topicProgress;
    await _persistProgress();
    notifyListeners();
  }

  Future<void> recordExamAttempt(ExamAttempt attempt) async {
    final key = '${attempt.examId}|${attempt.userId}';
    if (_examAttempts.containsKey(key)) {
      return;
    }
    _examAttempts[key] = attempt;
    if (_examDrafts.remove(key) != null) {
      await _persistExamDrafts();
    }
    await _persistExamAttempts();
    await _syncRemoteSubmission(attempt);
    notifyListeners();
  }

  Future<void> syncRemoteProgress({
    required String examId,
    required String examTitle,
    required int questionCount,
    required DateTime startedAt,
    required Map<int, String> answers,
  }) async {
    final user = _currentUser;
    if (user == null || user.role != UserRole.student) {
      return;
    }
    await RemoteSubmissionService.instance.pushProgress(
      classId: remoteClassroomId,
      studentId: user.id,
      studentName: user.displayName,
      studentEmail: user.email,
      examId: examId,
      examTitle: examTitle,
      questionCount: questionCount,
      startedAt: startedAt,
      answers: answers,
    );
  }

  Future<void> resetExamAttempt({
    required String examId,
    required String userId,
  }) async {
    final key = '$examId|$userId';
    if (_examAttempts.remove(key) != null) {
      await _persistExamAttempts();
    }
    if (_examDrafts.remove(key) != null) {
      await _persistExamDrafts();
    }
    notifyListeners();
  }

  Future<void> _persistProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{};
    _studentProgress.forEach((userId, data) {
      payload[userId] = Map<String, int>.from(data);
    });
    await prefs.setString(_progressKey, jsonEncode(payload));
  }

  Future<void> _persistExamAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _examAttemptsKey,
      ExamAttempt.encodeList(_examAttempts.values.toList()),
    );
  }

  Map<int, String> examDraftFor(String examId, String userId) {
    final key = '$examId|$userId';
    final existing = _examDrafts[key];
    return existing == null ? {} : Map<int, String>.from(existing);
  }

  Future<void> saveExamDraft({
    required String examId,
    required String userId,
    required Map<int, String> answers,
  }) async {
    final key = '$examId|$userId';
    _examDrafts[key] = Map<int, String>.from(answers);
    await _persistExamDrafts();
  }

  Future<void> clearExamDraft({
    required String examId,
    required String userId,
  }) async {
    final key = '$examId|$userId';
    if (_examDrafts.remove(key) != null) {
      await _persistExamDrafts();
    }
  }

  Future<void> _persistExamDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, Map<String, String>>{};
    _examDrafts.forEach((key, value) {
      payload[key] = value.map(
        (question, answer) => MapEntry(question.toString(), answer),
      );
    });
    await prefs.setString(_examDraftsKey, jsonEncode(payload));
  }

  Future<void> _syncRemoteSubmission(ExamAttempt attempt) async {
    final student = _userById(attempt.userId);
    if (student == null || student.role != UserRole.student) {
      return;
    }
    final exam = ExamCatalog.getById(attempt.examId);
    final startedAt = attempt.completedAt.subtract(
      Duration(seconds: attempt.durationSeconds),
    );
    await RemoteSubmissionService.instance.submitAttempt(
      classId: remoteClassroomId,
      studentId: student.id,
      studentName: student.displayName,
      studentEmail: student.email,
      examId: attempt.examId,
      examTitle: exam.title,
      questionCount: exam.questionCount,
      startedAt: startedAt,
      completedAt: attempt.completedAt,
      durationSeconds: attempt.durationSeconds,
      answers: attempt.answers,
    );
  }

  User? _userById(String userId) {
    for (final user in _users) {
      if (user.id == userId) {
        return user;
      }
    }
    return null;
  }

  static const String _progressKey = 'student_progress_v1';
  static const String _examAttemptsKey = 'exam_attempts_v1';
  static const String _examDraftsKey = 'exam_drafts_v1';
}
