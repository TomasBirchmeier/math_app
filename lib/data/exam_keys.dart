import 'exam_catalog.dart';
import 'ensayo_m1_2023_answers.dart';
import 'ensayo_paes_m1_text.dart';

class ExamKeys {
  static Map<int, String> keyFor(String examId) {
    switch (examId) {
      case ExamCatalog.assetM1ExamId:
        return ensayoM1May2023Answers;
      case ExamCatalog.paesM1ExamId:
        return {
          for (final question in paesM1TextQuestions) question.number: question.correctOption
        };
      default:
        return const {};
    }
  }

  static Set<int> excludedFor(String examId) {
    switch (examId) {
      case ExamCatalog.assetM1ExamId:
        return ensayoM1May2023Excluded;
      default:
        return const {};
    }
  }
}
