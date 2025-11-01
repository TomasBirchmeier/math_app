import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/ensayo_paes_m1_text.dart';
import '../data/exam_keys.dart';
import '../models/exam.dart';
import '../state/app_state.dart';
import '../utils/exam_scoring.dart';

class ExamTextSessionPage extends StatefulWidget {
  const ExamTextSessionPage({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.questions,
  });

  final String examId;
  final String examTitle;
  final List<ExamTextQuestion> questions;

  @override
  State<ExamTextSessionPage> createState() => _ExamTextSessionPageState();
}

class _ExamTextSessionPageState extends State<ExamTextSessionPage> {
  static const int _totalDurationSeconds = 2 * 60 * 60 + 20 * 60; // 2h 20m
  final PageController _pageController = PageController();
  final Map<int, String> _answers = {};
  late DateTime _startedAt;
  int _remainingSeconds = _totalDurationSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(
          0,
          _totalDurationSeconds,
        );
      });
      if (_remainingSeconds == 0) {
        _submitExam(auto: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToQuestion(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
    );
  }

  void _advanceAfterAnswer(int currentIndex) {
    if (currentIndex < widget.questions.length - 1) {
      _goToQuestion(currentIndex + 1);
    }
  }

  Future<void> _submitExam({bool auto = false}) async {
    if (!mounted) return;
    _timer?.cancel();
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      Navigator.of(context).pop();
      return;
    }
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;
    final answerKey = ExamKeys.keyFor(widget.examId);
    final result = gradeAnswers(
      answerKey: answerKey,
      userAnswers: _answers,
      totalQuestions: widget.questions.length,
    );
    final attempt = ExamAttempt(
      userId: user.id,
      durationSeconds: elapsed,
      answers: Map<int, String>.from(_answers),
      completedAt: DateTime.now(),
      examId: widget.examId,
    );
    await appState.recordExamAttempt(attempt);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(auto ? 'Tiempo terminado' : 'Ensayo enviado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Respuestas registradas: ${_answers.length} de ${widget.questions.length}.',
              ),
              const SizedBox(height: 8),
              if (result.totalGradable > 0) ...[
                Text(
                  'Correctas: ${result.correct} / ${result.totalGradable} (${(result.accuracy * 100).toStringAsFixed(1)}%)',
                ),
                const SizedBox(height: 8),
              ],
              Text('Duración: ${_formatElapsed(elapsed)}.'),
              const SizedBox(height: 8),
              const Text(
                'Tu docente podrá revisar tus respuestas desde el panel administrador.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salir del ensayo'),
          content: const Text(
            'Si abandonas ahora, tus respuestas no se guardarán. ¿Deseas salir?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continuar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  String _formatRemaining(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatElapsed(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final hrs = mins ~/ 60;
    final remainingMins = mins % 60;
    if (hrs > 0) {
      return '${hrs}h ${remainingMins}m ${secs}s';
    }
    return '${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _confirmExit();
        if (shouldExit) {
          _timer?.cancel();
        }
        return shouldExit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.examTitle),
          actions: [
            TextButton.icon(
              onPressed: () => _submitExam(auto: false),
              icon: const Icon(Icons.send),
              label: const Text('Enviar'),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Tiempo restante: ${_formatRemaining(_remainingSeconds)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Resueltas: ${_answers.length}/${widget.questions.length}',
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.questions[index];
                  final selected = _answers[question.number];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Pregunta ${question.number}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (question.context != null)
                          Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                question.context!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        Text(
                          question.prompt,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        ...question.options.entries.map(
                          (entry) => Card(
                            elevation: 0,
                            child: RadioListTile<String>(
                              value: entry.key,
                              groupValue: selected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == null) {
                                    _answers.remove(question.number);
                                  } else {
                                    _answers[question.number] = value;
                                  }
                                });
                                if (value != null) {
                                  Future.delayed(
                                    const Duration(milliseconds: 120),
                                    () {
                                      if (mounted) {
                                        _advanceAfterAnswer(index);
                                      }
                                    },
                                  );
                                }
                              },
                              title: Text('${entry.key}) ${entry.value}'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _ExamNavigationBar(
              controller: _pageController,
              total: widget.questions.length,
              onSubmit: () => _submitExam(auto: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamNavigationBar extends StatefulWidget {
  const _ExamNavigationBar({
    required this.controller,
    required this.total,
    required this.onSubmit,
  });

  final PageController controller;
  final int total;
  final VoidCallback onSubmit;

  @override
  State<_ExamNavigationBar> createState() => _ExamNavigationBarState();
}

class _ExamNavigationBarState extends State<_ExamNavigationBar> {
  int _current = 0;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      final page = widget.controller.page?.round() ?? 0;
      if (page != _current && mounted) {
        setState(() {
          _current = page;
        });
      }
    };
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('Pregunta ${_current + 1} de ${widget.total}'),
          const Spacer(),
          IconButton(
            tooltip: 'Pregunta anterior',
            onPressed: _current > 0
                ? () => widget.controller.previousPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Pregunta siguiente',
            onPressed: _current < widget.total - 1
                ? () => widget.controller.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: widget.onSubmit,
            icon: const Icon(Icons.send),
            label: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
