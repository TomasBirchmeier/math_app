import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/exam_catalog.dart';
import '../data/exam_keys.dart';
import '../data/exam_topics.dart';
import '../models/exam.dart';
import '../models/user.dart';
import '../state/app_state.dart';
import 'exam_scoring.dart';

class ReportService {
  static Future<void> sendStudentReport({
    required BuildContext context,
    required AppState appState,
    required User student,
    String? overrideEmail,
  }) async {
    final report = _buildReport(appState, student);
    final recipient = overrideEmail ??
        student.email ??
        appState.currentUser?.email ??
        'tomas@quantplus.cl';

    final uri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {
        'subject': report.subject,
        'body': report.body,
      },
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    final messenger = ScaffoldMessenger.of(context);
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir el cliente de correo. Copia y envía el reporte manualmente.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Reporte listo. Revisa el correo dirigido a $recipient.',
          ),
        ),
      );
    }
  }

  static _StudentReport _buildReport(AppState appState, User student) {
    final progress = appState.progressFor(student.id);
    final totalPoints = progress.values.fold<int>(0, (a, b) => a + b);
    final sortedTopics = progress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final strengths = sortedTopics.where((e) => e.value > 0).take(2).toList();
    final needsSupport = sortedTopics.reversed.take(min(2, sortedTopics.length)).toList();

    final attempts = appState.attemptsForUser(student.id);
    final latestAttempt = attempts.isNotEmpty ? attempts.last : null;
    ExamResult? latestResult;
    Map<String, List<int>> incorrectByTopic = {};
    String? examTitle;
    if (latestAttempt != null) {
      final exam = ExamCatalog.getById(latestAttempt.examId);
      examTitle = exam.title;
      final answerKey = ExamKeys.keyFor(exam.id);
      final excluded = ExamKeys.excludedFor(exam.id);
      if (answerKey.isNotEmpty) {
        latestResult = gradeAnswers(
          answerKey: answerKey,
          userAnswers: latestAttempt.answers,
          totalQuestions: exam.questionCount,
          excluded: excluded,
        );
        incorrectByTopic = _detectErrors(
          attempt: latestAttempt,
          answerKey: answerKey,
          excluded: excluded,
        );
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('Quant+ · Informe personalizado');
    buffer.writeln('Estudiante: ${student.displayName} (${student.id})');
    buffer.writeln(
      'Fecha del reporte: ${_formatDate(DateTime.now())}',
    );
    buffer.writeln('');

    if (latestAttempt != null) {
      buffer.writeln('Ensayo reciente: ${examTitle ?? latestAttempt.examId}');
      buffer.writeln(
        'Respuestas enviadas: ${latestAttempt.answeredCount} en ${_formatDuration(latestAttempt.durationSeconds)}',
      );
      if (latestResult != null && latestResult.totalGradable > 0) {
        buffer.writeln(
          'Exactitud registrada: ${(latestResult.accuracy * 100).toStringAsFixed(1)}%',
        );
      } else {
        buffer.writeln(
          'Exactitud registrada: pendiente de corrección automática.',
        );
      }
      buffer.writeln('');
    }

    buffer.writeln('Resumen por área (puntaje acumulado):');
    for (final entry in sortedTopics) {
      final indicator = _strengthEmoji(entry.value, totalPoints);
      buffer.writeln(
        '• ${entry.key}: ${entry.value} pts $indicator',
      );
    }
    buffer.writeln('');

    if (strengths.isNotEmpty) {
      buffer.writeln('Fortalezas destacadas:');
      for (final entry in strengths) {
        buffer.writeln(
          '• ${entry.key}: ritmo de práctica consistente (${entry.value} pts).',
        );
      }
      buffer.writeln('');
    }

    buffer.writeln('Áreas a consolidar:');
    if (needsSupport.every((e) => e.value == 0)) {
      buffer.writeln(
        '• Aún no registramos práctica diferenciada. Agenda sesiones focalizadas en cada rama del plan (Números, Álgebra, Geometría, Probabilidad).',
      );
    } else {
      for (final entry in needsSupport) {
        buffer.writeln(
          '• ${entry.key}: refuerza ejercicios dirigidos (${entry.value} pts acumulados).',
        );
      }
    }
    buffer.writeln('');

    if (incorrectByTopic.isNotEmpty) {
      buffer.writeln('Preguntas con observaciones por área:');
      incorrectByTopic.forEach((topic, questions) {
        buffer.writeln(
          '• $topic: repasar las preguntas ${questions.join(', ')}.',
        );
      });
      buffer.writeln('');
    }

    buffer.writeln('Recomendaciones Quant+:');
    buffer.writeln(
      '• Alterna sesiones de ensayo completo con práctica guiada para consolidar conceptos.',
    );
    buffer.writeln(
      '• Registra dudas surgidas en las preguntas identificadas y prográmalas en la próxima tutoría.',
    );
    buffer.writeln(
      '• Mantén la constancia: pequeñas sesiones de 20 minutos en la app se traducen en progresos visibles semana a semana.',
    );

    final subject = 'Informe personalizado · Quant+ · ${student.displayName}';
    return _StudentReport(subject: subject, body: buffer.toString());
  }

  static Map<String, List<int>> _detectErrors({
    required ExamAttempt attempt,
    required Map<int, String> answerKey,
    required Set<int> excluded,
  }) {
    final errors = <String, List<int>>{};
    for (final entry in answerKey.entries) {
      final question = entry.key;
      final expected = entry.value;
      if (excluded.contains(question)) continue;
      final userAnswer = attempt.answers[question];
      if (userAnswer == null || userAnswer != expected) {
        final topic = ExamTopics.topicFor(attempt.examId, question);
        errors.putIfAbsent(topic, () => <int>[]).add(question);
      }
    }
    errors.removeWhere((_, list) => list.isEmpty);
    for (final list in errors.values) {
      list.sort();
    }
    return errors;
  }

  static String _strengthEmoji(int value, int totalPoints) {
    if (value == 0) return '⚪️';
    final ratio = totalPoints == 0 ? 0.0 : value / max(totalPoints, 1);
    if (ratio >= 0.35) return '🟢';
    if (ratio >= 0.2) return '🟡';
    return '🟠';
  }

  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m ${remainingSeconds}s';
    }
    return '${minutes}m ${remainingSeconds}s';
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year · $hour:$minute';
  }
}

class _StudentReport {
  const _StudentReport({
    required this.subject,
    required this.body,
  });

  final String subject;
  final String body;
}
