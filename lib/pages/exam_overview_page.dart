import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exam_catalog.dart';
import '../models/exam.dart';
import '../state/app_state.dart';

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
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(exam.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Alumno: ${student.displayName} (${student.id})'),
                    Text('Respondió ${attempt.answeredCount} / ${exam.questionCount} preguntas'),
                    Text('Duración: ${_formatDuration(attempt.durationSeconds)}'),
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
    final student = state.users.firstWhere(
      (user) => user.id == attempt.userId,
      orElse: () => state.users.first,
    );
    final exam = ExamCatalog.getById(attempt.examId);
    return Scaffold(
      appBar: AppBar(
        title: Text('${student.displayName} · ${exam.title}'),
      ),
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
            const SizedBox(height: 16),
            Expanded(
              child: answers.isEmpty
                  ? const Center(child: Text('El alumno no seleccionó ninguna respuesta.'))
                  : ListView.builder(
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final entry = answers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(entry.key.toString()),
                          ),
                          title: Text('Respuesta marcada: ${entry.value}'),
                        );
                      },
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
}
