import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exam_catalog.dart';
import '../data/exam_keys.dart';
import '../data/ensayo_m1_2023.dart';
import '../models/exam.dart';
import '../state/app_state.dart';
import '../utils/exam_scoring.dart';
import '../widgets/trimmed_asset_image.dart';

class ExamAssetSessionPage extends StatefulWidget {
  const ExamAssetSessionPage({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.questions,
  });

  final String examId;
  final String examTitle;
  final List<ExamQuestionAsset> questions;

  @override
  State<ExamAssetSessionPage> createState() => _ExamAssetSessionPageState();
}

class _ExamAssetSessionPageState extends State<ExamAssetSessionPage> {
  static const int _totalDurationSeconds = 2 * 60 * 60 + 20 * 60; // 2h20m
  final PageController _pageController = PageController();
  final Map<int, String> _answers = {};
  late DateTime _startedAt;
  int _remainingSeconds = _totalDurationSeconds;
  Timer? _timer;
  Timer? _remoteSyncDebounce;
  late final bool _isGuideExam;

  @override
  void initState() {
    super.initState();
    _isGuideExam = widget.examId == ExamCatalog.agustinGuideExamId;
    _startedAt = DateTime.now();
    if (!_isGuideExam) {
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
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraft());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remoteSyncDebounce?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionNumber, String choice) {
    setState(() {
      _answers[questionNumber] = choice;
    });
    _scheduleRemoteSync();
    _persistDraft();
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

  Future<void> _restoreDraft() async {
    if (!mounted) return;
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user == null) return;
    final draft = appState.examDraftFor(widget.examId, user.id);
    if (draft.isEmpty) return;
    setState(() {
      _answers.addAll(draft);
    });
    final firstPendingIndex = widget.questions.indexWhere(
      (question) => !_answers.containsKey(question.number),
    );
    if (firstPendingIndex > 0 && _pageController.hasClients) {
      _pageController.jumpToPage(firstPendingIndex);
    }
  }

  Future<void> _persistDraft() async {
    if (!_isGuideExam || !mounted) return;
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user == null) return;
    await appState.saveExamDraft(
      examId: widget.examId,
      userId: user.id,
      answers: _answers,
    );
  }

  Future<void> _handleSaveAndExit() async {
    if (!mounted) return;
    if (_isGuideExam) {
      await _persistDraft();
      await _syncRemoteProgress();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Avance guardado. Puedes continuar más tarde desde la sección de ensayos.',
          ),
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    final shouldExit = await _confirmExit();
    if (shouldExit && mounted) {
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitExam({bool auto = false}) async {
    if (!mounted) return;
    _timer?.cancel();
    _remoteSyncDebounce?.cancel();
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      Navigator.of(context).pop();
      return;
    }
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;
    final answerKey = ExamKeys.keyFor(widget.examId);
    final excluded = ExamKeys.excludedFor(widget.examId);
    final result = gradeAnswers(
      answerKey: answerKey,
      userAnswers: _answers,
      totalQuestions: widget.questions.length,
      excluded: excluded,
    );
    final attempt = ExamAttempt(
      userId: user.id,
      durationSeconds: elapsed,
      answers: Map<int, String>.from(_answers),
      completedAt: DateTime.now(),
      examId: widget.examId,
    );
    await appState.recordExamAttempt(attempt);
    if (_isGuideExam) {
      await appState.clearExamDraft(examId: widget.examId, userId: user.id);
    }
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
                if (result.excluded.isNotEmpty)
                  Text(
                    'Preguntas sin corrección automática: ${_formatExcluded(result.excluded)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
              ] else ...[
                Text(
                  widget.examId == ExamCatalog.agustinGuideExamId
                      ? 'Ensayo de práctica guiada Quant+. Durante la clase revisaremos estas preguntas y la estrategia de resolución.'
                      : 'Aún no hay clave cargada para este ensayo. Revisa tus respuestas con tu profesora.',
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

  void _scheduleRemoteSync() {
    _remoteSyncDebounce?.cancel();
    _remoteSyncDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_syncRemoteProgress());
    });
  }

  Future<void> _syncRemoteProgress() async {
    if (!mounted) return;
    final appState = context.read<AppState>();
    await appState.syncRemoteProgress(
      examId: widget.examId,
      examTitle: widget.examTitle,
      questionCount: widget.questions.length,
      startedAt: _startedAt,
      answers: Map<int, String>.from(_answers),
    );
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salir del ensayo'),
          content: Text(
            _isGuideExam
                ? 'Puedes cerrar esta guía y retomarla más tarde. ¿Quieres salir ahora?'
                : 'Si abandonas ahora, tus respuestas no se guardarán. ¿Deseas salir?',
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
    if (_isGuideExam && result == true) {
      await _persistDraft();
    }
    return result ?? false;
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

  String _formatExcluded(Set<int> excluded) {
    if (excluded.isEmpty) {
      return '';
    }
    final list = excluded.toList()..sort();
    return list.join(', ');
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
            _isGuideExam
                ? _GuideProgressHeader(
                    answered: _answers.length,
                    total: widget.questions.length,
                  )
                : _TimedHeader(
                    remainingSeconds: _remainingSeconds,
                    answered: _answers.length,
                    total: widget.questions.length,
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
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 700,
                              maxHeight: 420,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: TrimmedAssetImage(
                                assetPath: question.assetPath,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecciona tu respuesta:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: ['A', 'B', 'C', 'D', 'E'].map((choice) {
                            final isSelected = choice == selected;
                            return ChoiceChip(
                              label: Text(
                                choice,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              selected: isSelected,
                              onSelected: (value) {
                                if (!value) {
                                  setState(
                                    () => _answers.remove(question.number),
                                  );
                                  _persistDraft();
                                } else {
                                  _selectAnswer(question.number, choice);
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
                            );
                          }).toList(),
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
              onSave: _handleSaveAndExit,
              showSave: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimedHeader extends StatelessWidget {
  const _TimedHeader({
    required this.remainingSeconds,
    required this.answered,
    required this.total,
  });

  final int remainingSeconds;
  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined),
          const SizedBox(width: 8),
          Text(
            'Tiempo restante: ${_formatRemainingStatic(remainingSeconds)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text('Resueltas: $answered/$total'),
        ],
      ),
    );
  }

  static String _formatRemainingStatic(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _GuideProgressHeader extends StatelessWidget {
  const _GuideProgressHeader({required this.answered, required this.total});

  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : answered / total;
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_outlined),
              const SizedBox(width: 8),
              Text(
                'Avance guardado automáticamente',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('$answered de $total respondidas'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Puedes salir y volver cuando quieras; tus respuestas quedan guardadas.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ExamNavigationBar extends StatefulWidget {
  const _ExamNavigationBar({
    required this.controller,
    required this.total,
    required this.onSubmit,
    required this.onSave,
    this.showSave = false,
  });

  final PageController controller;
  final int total;
  final VoidCallback onSubmit;
  final VoidCallback onSave;
  final bool showSave;

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
    final total = widget.total;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('Pregunta ${_current + 1} de $total'),
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
            onPressed: _current < total - 1
                ? () => widget.controller.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 12),
          if (widget.showSave) ...[
            FilledButton.tonalIcon(
              onPressed: widget.onSave,
              icon: const Icon(Icons.cloud_download_outlined),
              label: const Text('Guardar y continuar después'),
            ),
            const SizedBox(width: 12),
          ],
          FilledButton.icon(
            onPressed: widget.onSubmit,
            icon: const Icon(Icons.send),
            label: const Text('Entregar ahora'),
          ),
        ],
      ),
    );
  }
}
