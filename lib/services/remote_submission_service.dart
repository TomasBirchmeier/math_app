import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class RemoteSubmissionService {
  RemoteSubmissionService._();

  static final RemoteSubmissionService instance = RemoteSubmissionService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  bool get isEnabled => Firebase.apps.isNotEmpty;

  Future<void> pushProgress({
    required String classId,
    required String studentId,
    required String studentName,
    String? studentEmail,
    required String examId,
    required String examTitle,
    required int questionCount,
    required DateTime startedAt,
    required Map<int, String> answers,
  }) async {
    if (!isEnabled) {
      return;
    }
    final payload = <String, dynamic>{
      'classId': classId,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'examId': examId,
      'examTitle': examTitle,
      'questionCount': questionCount,
      'answeredCount': answers.length,
      'answers': _encodeAnswers(answers),
      'status': 'in_progress',
      'startedAt': Timestamp.fromDate(startedAt.toUtc()),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtClient': Timestamp.fromDate(DateTime.now().toUtc()),
    };
    try {
      await _doc(
        classId: classId,
        examId: examId,
        studentId: studentId,
      ).set(payload, SetOptions(merge: true));
    } catch (error, stackTrace) {
      debugPrint('Remote progress sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> submitAttempt({
    required String classId,
    required String studentId,
    required String studentName,
    String? studentEmail,
    required String examId,
    required String examTitle,
    required int questionCount,
    required DateTime startedAt,
    required DateTime completedAt,
    required int durationSeconds,
    required Map<int, String> answers,
  }) async {
    if (!isEnabled) {
      return;
    }
    final payload = <String, dynamic>{
      'classId': classId,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'examId': examId,
      'examTitle': examTitle,
      'questionCount': questionCount,
      'answeredCount': answers.length,
      'answers': _encodeAnswers(answers),
      'status': 'submitted',
      'durationSeconds': durationSeconds,
      'startedAt': Timestamp.fromDate(startedAt.toUtc()),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtClient': Timestamp.fromDate(DateTime.now().toUtc()),
      'submittedAt': FieldValue.serverTimestamp(),
      'completedAtClient': Timestamp.fromDate(completedAt.toUtc()),
    };
    try {
      await _doc(
        classId: classId,
        examId: examId,
        studentId: studentId,
      ).set(payload, SetOptions(merge: true));
    } catch (error, stackTrace) {
      debugPrint('Remote attempt sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Stream<List<RemoteSubmissionRecord>> watchSubmissions({
    required String classId,
    int limit = 150,
  }) {
    if (!isEnabled) {
      return Stream<List<RemoteSubmissionRecord>>.value(const []);
    }
    return _collection(classId)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(RemoteSubmissionRecord.fromSnapshot)
              .toList(growable: false),
        );
  }

  CollectionReference<Map<String, dynamic>> _collection(String classId) {
    return _db.collection('classes').doc(classId).collection('submissions');
  }

  DocumentReference<Map<String, dynamic>> _doc({
    required String classId,
    required String examId,
    required String studentId,
  }) {
    return _collection(classId).doc('$examId|$studentId');
  }

  Map<String, String> _encodeAnswers(Map<int, String> answers) {
    return answers.map(
      (question, answer) => MapEntry(question.toString(), answer),
    );
  }
}

class RemoteSubmissionRecord {
  const RemoteSubmissionRecord({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.examId,
    required this.examTitle,
    required this.questionCount,
    required this.answeredCount,
    required this.answers,
    required this.status,
    required this.startedAt,
    required this.updatedAt,
    required this.submittedAt,
    required this.durationSeconds,
  });

  final String id;
  final String classId;
  final String studentId;
  final String studentName;
  final String? studentEmail;
  final String examId;
  final String examTitle;
  final int questionCount;
  final int answeredCount;
  final Map<int, String> answers;
  final String status;
  final DateTime? startedAt;
  final DateTime? updatedAt;
  final DateTime? submittedAt;
  final int? durationSeconds;

  bool get isSubmitted => status == 'submitted';

  DateTime? get lastUpdate => submittedAt ?? updatedAt ?? startedAt;

  factory RemoteSubmissionRecord.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return RemoteSubmissionRecord(
      id: snapshot.id,
      classId: (data['classId'] as String?) ?? '',
      studentId: (data['studentId'] as String?) ?? 'unknown',
      studentName:
          (data['studentName'] as String?) ??
          (data['studentId'] as String?) ??
          'Unknown',
      studentEmail: data['studentEmail'] as String?,
      examId: (data['examId'] as String?) ?? 'm1_pdf_mayo2023',
      examTitle: (data['examTitle'] as String?) ?? 'Ensayo',
      questionCount: _asInt(data['questionCount']),
      answeredCount: _asInt(data['answeredCount']),
      answers: _decodeAnswers(data['answers']),
      status: (data['status'] as String?) ?? 'in_progress',
      startedAt: _asDateTime(data['startedAt']),
      updatedAt: _asDateTime(data['updatedAt']),
      submittedAt: _asDateTime(data['submittedAt']),
      durationSeconds: _asNullableInt(data['durationSeconds']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return _asInt(value);
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Map<int, String> _decodeAnswers(dynamic raw) {
    if (raw is! Map) {
      return const {};
    }
    final parsed = <int, String>{};
    raw.forEach((question, answer) {
      final number = int.tryParse(question.toString());
      final value = answer?.toString();
      if (number != null && value != null && value.isNotEmpty) {
        parsed[number] = value;
      }
    });
    return parsed;
  }
}
