import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exam_catalog.dart';
import '../data/exam_keys.dart';
import '../models/user.dart';
import '../state/app_state.dart';
import '../utils/exam_scoring.dart';
import 'exam_overview_page.dart';
import 'exam_review_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final students = appState.students.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de seguimiento'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AppState>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${appState.currentUser?.displayName ?? 'Admin'} 👩‍🏫',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa el avance de cada alumno en tiempo real. Los puntos se suman cada vez que superan un conjunto de ejercicios.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExamOverviewPage()),
                );
              },
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Ver ensayos entregados'),
            ),
            const SizedBox(height: 24),
            if (students.isNotEmpty)
              _AdminStats(
                topStudent: _findTopStudent(appState),
                totalPoints: students
                    .map((s) => appState.totalPointsFor(s.id))
                    .fold<int>(0, (a, b) => a + b),
              ),
            if (students.isNotEmpty) const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _StudentsTable(students: students),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentsTable extends StatelessWidget {
  const _StudentsTable({required this.students});

  final List<User> students;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final topics = AppState.topics;

    if (students.isEmpty) {
      return const Center(
        child: Text('No hay alumnos registrados todavía.'),
      );
    }

    final table = DataTable(
      dataRowMinHeight: 88,
      dataRowMaxHeight: 148,
      headingRowColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.primaryContainer,
      ),
      columns: [
        const DataColumn(label: Text('Alumno')),
        const DataColumn(label: Text('Usuario')),
        ...topics.map((topic) => DataColumn(label: Text(topic))),
        const DataColumn(label: Text('Total')),
        const DataColumn(label: Text('Último ensayo')),
      ],
      rows: students.map((student) {
        final progress = appState.progressFor(student.id);
        final total = appState.totalPointsFor(student.id);
        return DataRow(
          cells: [
            DataCell(Text(student.displayName)),
            DataCell(Text(student.id)),
            ...topics.map((topic) {
              final score = progress[topic] ?? 0;
              return DataCell(Text('$score pts'));
            }),
            DataCell(Text('$total pts')),
            DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: _buildAttemptSummary(context, appState, student),
              ),
            ),
          ],
        );
      }).toList(),
    );

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 96,
          ),
          child: SingleChildScrollView(
            child: table,
          ),
        ),
      ),
    );
  }

  Widget _buildAttemptSummary(
    BuildContext context,
    AppState appState,
    User student,
  ) {
    final attempts = appState.attemptsForUser(student.id);
    if (attempts.isEmpty) {
      return const Text('Sin ensayos rendidos');
    }

    final latestAttempt = attempts.last;
    final exam = ExamCatalog.getById(latestAttempt.examId);

    final answerKey = ExamKeys.keyFor(exam.id);
    final excluded = ExamKeys.excludedFor(exam.id);
    ExamResult? result;
    if (answerKey.isNotEmpty) {
      result = gradeAnswers(
        answerKey: answerKey,
        userAnswers: latestAttempt.answers,
        totalQuestions: exam.questionCount,
        excluded: excluded,
      );
    }

    final accuracyText = result != null && result.totalGradable > 0
        ? '${(result.accuracy * 100).toStringAsFixed(1)}% exactitud'
        : 'Corrección pendiente';
    final answeredSummary =
        '${latestAttempt.answeredCount}/${exam.questionCount} respondidas';

    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      runSpacing: 8,
      spacing: 12,
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exam.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '$answeredSummary · $accuracyText',
                style: textTheme.bodySmall,
              ),
              Text(
                'Última vez: ${_formatShortDate(latestAttempt.completedAt)}',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Navegar intento'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExamReviewPage(attempt: latestAttempt),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatShortDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month · $hour:$minute';
  }
}

_TopStudentData? _findTopStudent(AppState appState) {
  _TopStudentData? best;
  for (final student in appState.students) {
    final score = appState.totalPointsFor(student.id);
    if (best == null || score > best.totalPoints) {
      best = _TopStudentData(student: student, totalPoints: score);
    }
  }
  return best;
}

class _TopStudentData {
  const _TopStudentData({required this.student, required this.totalPoints});

  final User student;
  final int totalPoints;
}

class _AdminStats extends StatelessWidget {
  const _AdminStats({this.topStudent, required this.totalPoints});

  final _TopStudentData? topStudent;
  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Card(
            color: scheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Puntos totales del grupo',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalPoints pts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: scheme.secondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mejor desempeño',
                    style:
                        TextStyle(color: scheme.onSecondaryContainer.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 8),
                  if (topStudent != null)
                    Text(
                      '${topStudent!.student.displayName}\n${topStudent!.totalPoints} pts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSecondaryContainer,
                      ),
                    )
                  else
                    Text(
                      'Aún no hay resultados registrados',
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
