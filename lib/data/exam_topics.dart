import 'exam_catalog.dart';

const List<String> _topicOrder = [
  'Probabilidad',
  'Álgebra',
  'Números',
  'Geometría',
];

class ExamTopics {
  static final Map<String, Map<int, String>> _cache = {};

  static String topicFor(String examId, int questionNumber) {
    final mapping = _mappingForExam(examId);
    return mapping[questionNumber] ?? _topicOrder[(questionNumber - 1) % _topicOrder.length];
  }

  static Map<int, String> _mappingForExam(String examId) {
    if (_cache.containsKey(examId)) {
      return _cache[examId]!;
    }

    final entry = ExamCatalog.getById(examId);
    final total = entry.questionCount;
    final mapping = <int, String>{};

    for (var i = 1; i <= total; i++) {
      mapping[i] = _topicOrder[(i - 1) % _topicOrder.length];
    }

    _cache[examId] = mapping;
    return mapping;
  }
}
