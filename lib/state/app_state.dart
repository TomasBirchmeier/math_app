import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/exam.dart';

class AppState extends ChangeNotifier {
  AppState();

  static const List<String> topics = [
    'Probabilidad',
    'Álgebra',
    'Números',
    'Geometría',
  ];

  final List<User> _users = const [
    User(
      id: 'admin',
      displayName: 'Profesora Ana',
      role: UserRole.admin,
      password: 'admin123',
    ),
    User(
      id: 'sofia',
      displayName: 'Sofía Torres',
      role: UserRole.student,
      password: 'sofia456',
    ),
    User(
      id: 'mateo',
      displayName: 'Mateo Díaz',
      role: UserRole.student,
      password: 'mateo456',
    ),
    User(
      id: 'valentina',
      displayName: 'Valentina Ruiz',
      role: UserRole.student,
      password: 'valen456',
    ),
  ];

  final Map<String, Map<String, int>> _studentProgress = {};
  final Map<String, ExamAttempt> _examAttempts = {};
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

  List<ExamAttempt> examAttemptsFor(String examId) => _examAttempts.values
      .where((attempt) => attempt.examId == examId)
      .toList()
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

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
    _examAttempts[key] = attempt;
    await _persistExamAttempts();
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

  static const String _progressKey = 'student_progress_v1';
  static const String _examAttemptsKey = 'exam_attempts_v1';
}
