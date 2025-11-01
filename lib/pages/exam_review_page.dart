import 'package:flutter/material.dart';

import '../data/ensayo_m1_2023.dart';
import '../data/ensayo_paes_m1_text.dart';
import '../data/exam_catalog.dart';
import '../data/exam_keys.dart';
import '../models/exam.dart';
import '../utils/exam_scoring.dart';

class ExamReviewPage extends StatefulWidget {
  const ExamReviewPage({super.key, required this.attempt});

  final ExamAttempt attempt;

  @override
  State<ExamReviewPage> createState() => _ExamReviewPageState();
}

class _ExamReviewPageState extends State<ExamReviewPage> {
  late final PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exam = ExamCatalog.getById(widget.attempt.examId);
    final answerKey = ExamKeys.keyFor(exam.id);
    final excluded = ExamKeys.excludedFor(exam.id);
    final result = answerKey.isEmpty
        ? null
        : gradeAnswers(
            answerKey: answerKey,
            userAnswers: widget.attempt.answers,
            totalQuestions: exam.questionCount,
            excluded: excluded,
          );
    final questions = _buildQuestions(exam, answerKey, excluded);

    return Scaffold(
      appBar: AppBar(
        title: Text('Revisión · ${exam.title}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Completado el ${_formatDate(widget.attempt.completedAt)} · '
                  'Duración ${_formatDuration(widget.attempt.durationSeconds)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (result != null && result.totalGradable > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SummaryBadge(
                        label: 'Correctas',
                        value: '${result.correct}/${result.totalGradable}',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _SummaryBadge(
                        label: 'Exactitud',
                        value: '${(result.accuracy * 100).toStringAsFixed(1)}%',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  if (result.excluded.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Preguntas sin corrección automática: ${result.excluded.toList()..sort()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ],
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: questions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final question = questions[index];
                final status = question.status;
                final color = switch (status) {
                  _QuestionStatus.correct => Colors.green,
                  _QuestionStatus.incorrect => Colors.red,
                  _QuestionStatus.unanswered => Colors.grey,
                  _QuestionStatus.excluded => Colors.orange,
                  _QuestionStatus.noKey => Colors.blueGrey,
                };
                return ChoiceChip(
                  selected: _currentIndex == index,
                  label: Text(question.number.toString()),
                  backgroundColor: color.withOpacity(0.15),
                  selectedColor: color.withOpacity(0.35),
                  side: BorderSide(color: color.withOpacity(0.6)),
                  onSelected: (_) {
                    _controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return _QuestionReviewView(question: question);
              },
            ),
          ),
          _ReviewNavigationBar(
            current: _currentIndex,
            total: questions.length,
            onPrevious: _currentIndex > 0
                ? () => _controller.previousPage(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                    )
                : null,
            onNext: _currentIndex < questions.length - 1
                ? () => _controller.nextPage(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                    )
                : null,
          ),
        ],
      ),
    );
  }

  List<_ReviewQuestion> _buildQuestions(
    ExamCatalogEntry exam,
    Map<int, String> answerKey,
    Set<int> excluded,
  ) {
    final questions = <_ReviewQuestion>[];
    if (exam.usesAssets) {
      for (final question in ensayoM1May2023) {
        final userAnswer = widget.attempt.answers[question.number];
        final correctAnswer = answerKey[question.number];
        final isExcluded = excluded.contains(question.number);
        questions.add(
          _ReviewQuestion.asset(
            number: question.number,
            assetPath: question.assetPath,
            userAnswer: userAnswer,
            correctAnswer: correctAnswer,
            isExcluded: isExcluded,
          ),
        );
      }
    } else {
      for (final question in paesM1TextQuestions) {
        final userAnswer = widget.attempt.answers[question.number];
        questions.add(
          _ReviewQuestion.text(
            number: question.number,
            prompt: question.prompt,
            contextText: question.context,
            options: question.options,
            userAnswer: userAnswer,
            correctAnswer: question.correctOption,
          ),
        );
      }
    }
    questions.sort((a, b) => a.number.compareTo(b.number));
    return questions;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m ${remainingSeconds}s';
    }
    return '${minutes}m ${remainingSeconds}s';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

enum _QuestionStatus { correct, incorrect, unanswered, excluded, noKey }

class _ReviewQuestion {
  _ReviewQuestion.asset({
    required this.number,
    required this.assetPath,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isExcluded,
  })  : prompt = null,
        contextText = null,
        options = null;

  _ReviewQuestion.text({
    required this.number,
    required this.prompt,
    required this.contextText,
    required this.options,
    required this.userAnswer,
    required this.correctAnswer,
  })  : assetPath = null,
        isExcluded = false;

  final int number;
  final String? assetPath;
  final String? prompt;
  final String? contextText;
  final Map<String, String>? options;
  final String? userAnswer;
  final String? correctAnswer;
  final bool isExcluded;

  _QuestionStatus get status {
    if (isExcluded) {
      return _QuestionStatus.excluded;
    }
    if (correctAnswer == null) {
      return _QuestionStatus.noKey;
    }
    if (userAnswer == null || userAnswer!.isEmpty) {
      return _QuestionStatus.unanswered;
    }
    return userAnswer == correctAnswer
        ? _QuestionStatus.correct
        : _QuestionStatus.incorrect;
  }
}

class _QuestionReviewView extends StatelessWidget {
  const _QuestionReviewView({required this.question});

  final _ReviewQuestion question;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = question.status;
    Color? statusColor;
    String statusLabel;
    switch (status) {
      case _QuestionStatus.correct:
        statusColor = Colors.green;
        statusLabel = 'Respuesta correcta';
        break;
      case _QuestionStatus.incorrect:
        statusColor = Colors.red;
        statusLabel = 'Respuesta incorrecta';
        break;
      case _QuestionStatus.unanswered:
        statusColor = Colors.grey;
        statusLabel = 'Sin responder';
        break;
      case _QuestionStatus.excluded:
        statusColor = Colors.orange;
        statusLabel = 'Pregunta no evaluada automáticamente';
        break;
      case _QuestionStatus.noKey:
        statusColor = Colors.blueGrey;
        statusLabel = 'Sin clave registrada';
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            label: Text(statusLabel),
            backgroundColor: statusColor.withOpacity(0.15),
            labelStyle: TextStyle(color: statusColor),
            avatar: Icon(
              switch (status) {
                _QuestionStatus.correct => Icons.check_circle,
                _QuestionStatus.incorrect => Icons.cancel,
                _QuestionStatus.unanswered => Icons.help_outline,
                _QuestionStatus.excluded => Icons.info_outline,
                _QuestionStatus.noKey => Icons.key_off,
              },
              color: statusColor,
            ),
          ),
          const SizedBox(height: 16),
          if (question.assetPath != null)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720, maxHeight: 480),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    question.assetPath!,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          if (question.prompt != null) ...[
            if (question.contextText != null) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: scheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(question.contextText!),
                ),
              ),
            ],
            Text(
              question.prompt!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            if (question.options != null)
              ...question.options!.entries.map(
                (entry) {
                  final isCorrect = entry.key == question.correctAnswer;
                  final isSelected = entry.key == question.userAnswer;
                  Color? borderColor;
                  if (isCorrect) {
                    borderColor = Colors.green;
                  } else if (isSelected && !isCorrect) {
                    borderColor = Colors.red;
                  }
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: borderColor ?? Colors.grey.shade300,
                      ),
                    ),
                    child: ListTile(
                      title: Text('${entry.key}) ${entry.value}'),
                      trailing: isCorrect
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : isSelected
                              ? const Icon(Icons.cancel, color: Colors.red)
                              : null,
                    ),
                  );
                },
              ),
          ],
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu respuesta: ${question.userAnswer ?? '—'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (question.correctAnswer != null)
                    Text(
                      'Respuesta correcta: ${question.correctAnswer}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _ReviewNavigationBar extends StatelessWidget {
  const _ReviewNavigationBar({
    required this.current,
    required this.total,
    this.onPrevious,
    this.onNext,
  });

  final int current;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('Pregunta ${current + 1} de $total'),
          const Spacer(),
          IconButton(
            tooltip: 'Pregunta anterior',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Pregunta siguiente',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
