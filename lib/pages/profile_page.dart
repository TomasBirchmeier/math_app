import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exam_catalog.dart';
import '../data/exam_keys.dart';
import '../models/exam.dart';
import '../models/user.dart';
import '../state/app_state.dart';
import '../utils/exam_scoring.dart';
import 'exam_review_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    final progress = appState.progressFor(user.id);

    final attempts = appState.attemptsForUser(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi progreso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, user, appState.totalPointsFor(user.id)),
            const SizedBox(height: 24),
            Text(
              'Avance por tema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...AppState.topics.map((topic) {
              final score = progress[topic] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    child: Text(
                      topic.substring(0, 1),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(topic),
                  subtitle: LinearProgressIndicator(
                    value: (score / 30).clamp(0, 1),
                    backgroundColor: Colors.grey[200],
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  trailing: Text('$score pts'),
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(
              'Ensayos rendidos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (attempts.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Aún no has rendido ensayos. ¡Comienza cuando te sientas listo!',
                  ),
                ),
              )
            else
              ...attempts.map((attempt) => _AttemptCard(attempt: attempt)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, User user, int totalPoints) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Usuario: ${user.id}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total acumulado: $totalPoints pts',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  const _AttemptCard({required this.attempt});

  final ExamAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final exam = ExamCatalog.getById(attempt.examId);
    final answerKey = ExamKeys.keyFor(exam.id);
    ExamResult? result;
    if (answerKey.isNotEmpty) {
      final excluded = ExamKeys.excludedFor(exam.id);
      result = gradeAnswers(
        answerKey: answerKey,
        userAnswers: attempt.answers,
        totalQuestions: exam.questionCount,
        excluded: excluded,
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Respondidas: ${attempt.answeredCount} / ${exam.questionCount}',
            ),
            Text('Duración: ${_formatDuration(attempt.durationSeconds)}'),
            Text('Fecha: ${_formatDate(attempt.completedAt)}'),
            if (result != null && result.totalGradable > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Correctas: ${result.correct} / ${result.totalGradable} (${(result.accuracy * 100).toStringAsFixed(1)}%)',
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamReviewPage(attempt: attempt),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Revisar respuestas'),
              ),
            ),
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

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
