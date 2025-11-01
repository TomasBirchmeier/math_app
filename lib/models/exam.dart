import 'dart:convert';

class ExamAttempt {
  const ExamAttempt({
    required this.userId,
    required this.durationSeconds,
    required this.answers,
    required this.completedAt,
    required this.examId,
  });

  final String userId;
  final int durationSeconds;
  final Map<int, String> answers;
  final DateTime completedAt;
  final String examId;

  int get answeredCount => answers.length;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'durationSeconds': durationSeconds,
        'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
        'completedAt': completedAt.toIso8601String(),
        'examId': examId,
      };

  static ExamAttempt fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      userId: json['userId'] as String,
      durationSeconds: json['durationSeconds'] as int,
      answers: (json['answers'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(int.parse(key), value as String),
      ),
      completedAt: DateTime.parse(json['completedAt'] as String),
      examId: (json['examId'] as String?) ?? defaultExamId,
    );
  }

  static String encodeList(List<ExamAttempt> attempts) {
    final data = attempts.map((attempt) => attempt.toJson()).toList();
    return jsonEncode(data);
  }

  static List<ExamAttempt> decodeList(String value) {
    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded
        .map((item) => ExamAttempt.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static const String defaultExamId = 'm1_pdf_mayo2023';
}
