import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exam_catalog.dart';
import '../data/exam_keys.dart';
import '../models/exam.dart';
import '../models/user.dart';
import '../state/app_state.dart';
import '../utils/exam_scoring.dart';

class ExamOverviewPage extends StatelessWidget {
  const ExamOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final attempts = state.examAttempts;
        if (attempts.isEmpty) {
          return const Center(
            child: Text(
              'Aún no hay intentos registrados. Invita a tus alumnos a rendir el ensayo.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: attempts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final attempt = attempts[index];
            final student = state.users.firstWhere(
              (user) => user.id == attempt.userId,
              orElse: () => state.users.first,
            );
            final exam = ExamCatalog.getById(attempt.examId);
            ExamResult? result;
            final answerKey = ExamKeys.keyFor(exam.id);
            final excluded = ExamKeys.excludedFor(exam.id);
            if (answerKey.isNotEmpty) {
              result = gradeAnswers(
                answerKey: answerKey,
                userAnswers: attempt.answers,
                totalQuestions: exam.questionCount,
                excluded: excluded,
              );
            }
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(exam.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Alumno: ${student.displayName} (${student.id})'),
                    Text(
                      'Respondió ${attempt.answeredCount} / ${exam.questionCount} preguntas',
                    ),
                    Text(
                      'Duración: ${_formatDuration(attempt.durationSeconds)}',
                    ),
                    if (result != null && result.totalGradable > 0)
                      Text(
                        'Resultado: ${result.correct} / ${result.totalGradable} (${(result.accuracy * 100).toStringAsFixed(1)}%)',
                      ),
                  ],
                ),
                trailing: Text(
                  _formatDate(attempt.completedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.right,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamAttemptDetailPage(attempt: attempt),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class ExamAttemptDetailPage extends StatelessWidget {
  const ExamAttemptDetailPage({super.key, required this.attempt});

  final ExamAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final answers = attempt.answers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final state = context.watch<AppState>();
    final isAdmin = state.currentUser?.role == UserRole.admin;
    final student = state.users.firstWhere(
      (user) => user.id == attempt.userId,
      orElse: () => state.users.first,
    );
    final exam = ExamCatalog.getById(attempt.examId);
    final answerKey = ExamKeys.keyFor(exam.id);
    final excluded = ExamKeys.excludedFor(exam.id);
    final result = answerKey.isEmpty
        ? null
        : gradeAnswers(
            answerKey: answerKey,
            userAnswers: attempt.answers,
            totalQuestions: exam.questionCount,
            excluded: excluded,
          );
    return Scaffold(
      appBar: AppBar(title: Text('${student.displayName} · ${exam.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preguntas respondidas: ${attempt.answeredCount} / ${exam.questionCount}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Duración total: ${_formatDuration(attempt.durationSeconds)}'),
            if (result != null && result.totalGradable > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Correctas: ${result.correct} / ${result.totalGradable} (${(result.accuracy * 100).toStringAsFixed(1)}%)',
              ),
              if (result.excluded.isNotEmpty)
                Text(
                  'Preguntas excluidas del cálculo: ${_formatExcluded(result.excluded)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: answers.isEmpty
                  ? const Center(
                      child: Text('El alumno no seleccionó ninguna respuesta.'),
                    )
                  : ListView.builder(
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final entry = answers[index];
                        final expected = answerKey[entry.key];
                        final isExcluded = excluded.contains(entry.key);
                        final hasKey = expected != null;
                        final isCorrect =
                            hasKey && !isExcluded && entry.value == expected;
                        final color = !hasKey || isExcluded
                            ? null
                            : (isCorrect ? Colors.green : Colors.red);
                        final status = isExcluded
                            ? 'Pregunta no evaluada automáticamente'
                            : hasKey
                            ? (isCorrect
                                  ? 'Respuesta correcta'
                                  : 'Correcta: $expected')
                            : 'Sin clave registrada';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color?.withOpacity(0.2),
                            foregroundColor:
                                color ??
                                Theme.of(context).colorScheme.onSurface,
                            child: Text(entry.key.toString()),
                          ),
                          title: Text('Respuesta marcada: ${entry.value}'),
                          subtitle: Text(status),
                        );
                      },
                    ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Permitir nuevo intento'),
                        content: Text(
                          'Se eliminará el intento de ${student.displayName} para "${exam.title}". '
                          'Esto permitirá que vuelva a rendir el ensayo. ¿Deseas continuar?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Resetear'),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AppState>().resetExamAttempt(
                      examId: attempt.examId,
                      userId: attempt.userId,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Permitir un nuevo intento'),
              ),
            ],
          ],
        ),
      ),
    );
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

  String _formatExcluded(Set<int> excluded) {
    if (excluded.isEmpty) {
      return '';
    }
    final list = excluded.toList()..sort();
    return list.join(', ');
  }
}
