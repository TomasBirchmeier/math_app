class ExamResult {
  const ExamResult({
    required this.correct,
    required this.totalGradable,
    required this.totalQuestions,
    required this.answered,
    required this.excluded,
  });

  final int correct;
  final int totalGradable;
  final int totalQuestions;
  final int answered;
  final Set<int> excluded;

  double get accuracy => totalGradable == 0 ? 0 : correct / totalGradable;
}

ExamResult gradeAnswers({
  required Map<int, String> answerKey,
  required Map<int, String> userAnswers,
  required int totalQuestions,
  Set<int> excluded = const {},
}) {
  final gradableQuestions = answerKey.keys.toSet()..removeAll(excluded);
  final totalGradable = gradableQuestions.length;
  var correct = 0;
  var answered = 0;

  for (final entry in userAnswers.entries) {
    if (excluded.contains(entry.key)) {
      continue;
    }
    final expected = answerKey[entry.key];
    if (expected == null) {
      continue;
    }
    answered++;
    if (entry.value == expected) {
      correct++;
    }
  }

  return ExamResult(
    correct: correct,
    totalGradable: totalGradable,
    totalQuestions: totalQuestions,
    answered: answered,
    excluded: excluded,
  );
}
