import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exam_catalog.dart';
import '../data/exam_keys.dart';
import '../data/ensayo_m1_2023.dart';
import '../data/ensayo_paes_m1_text.dart';
import '../utils/exam_scoring.dart';
import '../models/exam.dart';
import '../state/app_state.dart';
import 'profile_page.dart';
import 'exam_session_page.dart';
import 'exam_text_session_page.dart';
import 'practice_page.dart';
import 'exam_review_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const String _brandName = 'Maths by Tomás';
  late final AnimationController _heroController;
  late final AnimationController _titleController;
  late final Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    );
    _titleController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final progreso = appState.progressFor(user.id);
    final total = appState.totalPointsFor(user.id);
    final attempts = appState.attemptsForUser(user.id);
    final points = _buildAttemptPoints(attempts);
    final assetInfo = ExamCatalog.getById(ExamCatalog.assetM1ExamId);
    final paesInfo = ExamCatalog.getById(ExamCatalog.paesM1ExamId);
    final assetAttempt = appState.examAttemptFor(assetInfo.id, user.id);
    final paesAttempt = appState.examAttemptFor(paesInfo.id, user.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Maths by Tomás'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Práctica guiada',
            icon: const Icon(Icons.auto_graph_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PracticePage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AppState>().logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroSection(
                context,
                user.displayName,
                progreso,
                total,
                points,
                attempts.length,
              ),
              const SizedBox(height: 24),
              _buildPerformanceSection(context, points),
              const SizedBox(height: 24),
              Text(
                'Ensayos disponibles',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _ExamCard(
                examId: assetInfo.id,
                title: assetInfo.title,
                description: assetInfo.description,
                questionCount: assetInfo.questionCount,
                attempt: assetAttempt,
                formatDuration: _formatDuration,
                formatDate: _formatAttemptDate,
                onStart: assetAttempt == null
                    ? () => _launchExam(
                        (_) => ExamAssetSessionPage(
                          examId: assetInfo.id,
                          examTitle: assetInfo.title,
                          questions: ensayoM1May2023,
                        ),
                      )
                    : null,
                onReview: assetAttempt == null
                    ? null
                    : () => _openReview(assetAttempt),
              ),
              const SizedBox(height: 16),
              _ExamCard(
                examId: paesInfo.id,
                title: paesInfo.title,
                description: paesInfo.description,
                questionCount: paesInfo.questionCount,
                attempt: paesAttempt,
                formatDuration: _formatDuration,
                formatDate: _formatAttemptDate,
                onStart: paesAttempt == null
                    ? () => _launchExam(
                        (_) => ExamTextSessionPage(
                          examId: paesInfo.id,
                          examTitle: paesInfo.title,
                          questions: paesM1TextQuestions,
                        ),
                      )
                    : null,
                onReview: paesAttempt == null
                    ? null
                    : () => _openReview(paesAttempt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchExam(WidgetBuilder builder) async {
    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Comenzar ensayo'),
          content: const Text(
            'El cronómetro iniciará en cuanto presiones continuar. '
            'Asegúrate de contar con el tiempo necesario, ya que el ensayo se envía automáticamente al finalizar el tiempo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
    if (shouldStart == true && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: builder));
    }
  }

  void _openReview(ExamAttempt attempt) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExamReviewPage(attempt: attempt)),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    String name,
    Map<String, int> progreso,
    int total,
    List<_AttemptPoint> points,
    int attemptsCount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 520;
    final heroHeight = isCompact ? 260.0 : 230.0;
    final bestTopicEntry = (progreso.isNotEmpty && total > 0)
        ? progreso.entries.reduce((a, b) => a.value >= b.value ? a : b)
        : null;
    final latestPercent = points.isNotEmpty ? points.last.percent : null;
    return Container(
      constraints: BoxConstraints(minHeight: heroHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.85),
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _heroController,
              builder: (context, _) => CustomPaint(
                painter: _HeroBackgroundPainter(
                  progress: _heroController.value,
                  baseColor: colorScheme.onPrimary.withOpacity(0.12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $name 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _titleAnimation,
                  builder: (context, _) {
                    final totalUnits = _brandName.length;
                    final currentUnits = (_titleAnimation.value * totalUnits)
                        .clamp(0, totalUnits)
                        .round();
                    final endIndex = currentUnits.clamp(0, totalUnits);
                    final display = currentUnits == 0
                        ? ''
                        : _brandName.substring(0, endIndex.toInt());
                    final showCursor = currentUnits < totalUnits;
                    final textToShow = (display.isEmpty && showCursor)
                        ? '|'
                        : showCursor
                        ? '$display|'
                        : display;
                    return Text(
                      textToShow,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                        fontFamily: 'Cursive',
                        fontSize: 26,
                        letterSpacing: 1.2,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  'Tu hub para ensayos y práctica guiada.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.78),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricBadge(
                      label: 'Total acumulado',
                      value: '$total pts',
                      tone: MetricTone.light,
                    ),
                    _MetricBadge(
                      label: 'Ensayos rendidos',
                      value: '$attemptsCount',
                      tone: MetricTone.light,
                    ),
                    if (bestTopicEntry != null)
                      _MetricBadge(
                        label: 'Tema destacado',
                        value: bestTopicEntry.key,
                        tone: MetricTone.light,
                      ),
                    if (latestPercent != null)
                      _MetricBadge(
                        label: 'Último puntaje',
                        value: '${latestPercent.toStringAsFixed(1)}%',
                        tone: MetricTone.light,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PracticePage()),
                    );
                  },
                  icon: const Icon(Icons.psychology_alt_outlined),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.onPrimary.withOpacity(0.18),
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  label: const Text('Abrir práctica guiada'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(
    BuildContext context,
    List<_AttemptPoint> points,
  ) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final chartHeight = media.size.width < 520 ? 180.0 : 220.0;
    final hasOutliers = points.any((point) => point.outOfBounds);
    if (points.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evolución de tus ensayos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Todavía no tienes resultados automáticos. Rinde un ensayo para comenzar a ver tu progreso.',
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolución de tus ensayos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _PerformanceChart(points: points, height: chartHeight),
            const SizedBox(height: 16),
            if (hasOutliers) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ajustamos algunos puntajes que estaban fuera del rango 0%-100% para mostrar el gráfico correctamente. Revisa las claves cargadas si notas valores inesperados.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Último resultado · ${points.last.examTitle}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${points.last.percent.toStringAsFixed(1)}% · ${_formatAttemptDate(points.last.date)}',
            ),
          ],
        ),
      ),
    );
  }

  List<_AttemptPoint> _buildAttemptPoints(List<ExamAttempt> attempts) {
    final List<_AttemptPoint> items = [];
    for (final attempt in attempts) {
      final key = ExamKeys.keyFor(attempt.examId);
      if (key.isEmpty) {
        continue;
      }
      final excluded = ExamKeys.excludedFor(attempt.examId);
      final result = gradeAnswers(
        answerKey: key,
        userAnswers: attempt.answers,
        totalQuestions: ExamCatalog.getById(attempt.examId).questionCount,
        excluded: excluded,
      );
      if (result.totalGradable == 0) {
        continue;
      }
      final examTitle = ExamCatalog.getById(attempt.examId).title;
      final percent = result.accuracy * 100;
      final sanitizedPercent = percent.isFinite ? percent.clamp(0, 100) : 0.0;
      final outOfBounds = !percent.isFinite || percent < 0 || percent > 100;
      items.add(
        _AttemptPoint(
          date: attempt.completedAt,
          percent: sanitizedPercent.toDouble(),
          examTitle: examTitle,
          outOfBounds: outOfBounds,
        ),
      );
    }
    return items;
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${duration.inMinutes}m ${secs.toString().padLeft(2, '0')}s';
  }

  String _formatAttemptDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.examId,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.attempt,
    required this.onStart,
    this.onReview,
    required this.formatDuration,
    required this.formatDate,
  });

  final String examId;
  final String title;
  final String description;
  final int questionCount;
  final ExamAttempt? attempt;
  final VoidCallback? onStart;
  final VoidCallback? onReview;
  final String Function(int) formatDuration;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ExamResult? result;
    if (attempt != null) {
      final answerKey = ExamKeys.keyFor(examId);
      if (answerKey.isNotEmpty) {
        final excluded = ExamKeys.excludedFor(examId);
        result = gradeAnswers(
          answerKey: answerKey,
          userAnswers: attempt!.answers,
          totalQuestions: questionCount,
          excluded: excluded,
        );
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Text('Preguntas: $questionCount'),
            if (attempt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Último intento',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text('Respondidas: ${attempt!.answeredCount} / $questionCount'),
              Text('Duración: ${formatDuration(attempt!.durationSeconds)}'),
              Text('Fecha: ${formatDate(attempt!.completedAt)}'),
              if (result != null && result.totalGradable > 0)
                Text(
                  'Resultado: ${result.correct} / ${result.totalGradable} (${(result.accuracy * 100).toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodyMedium,
                ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onStart,
              icon: Icon(
                onStart != null ? Icons.play_circle_fill : Icons.lock_outline,
              ),
              label: Text(
                onStart != null ? 'Iniciar ensayo' : 'Ensayo completado',
              ),
            ),
            if (onReview != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver respuestas'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum MetricTone { light, normal }

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.label,
    required this.value,
    this.tone = MetricTone.normal,
  });

  final String label;
  final String value;
  final MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool isLight = tone == MetricTone.light;
    final Color background = isLight
        ? Colors.white.withOpacity(0.18)
        : scheme.surfaceVariant.withOpacity(0.9);
    final Color textColor = isLight ? Colors.white : scheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textColor.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }
}

class _HeroBackgroundPainter extends CustomPainter {
  const _HeroBackgroundPainter({
    required this.progress,
    required this.baseColor,
  });

  final double progress;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = baseColor;
    canvas.drawCircle(
      Offset(
        size.width * (0.2 + 0.05 * math.sin(progress * 2 * math.pi)),
        size.height * 0.28,
      ),
      size.width * 0.25,
      paint,
    );

    paint.color = baseColor.withOpacity(0.65);
    canvas.drawCircle(
      Offset(
        size.width * (0.72 + 0.04 * math.cos(progress * 2 * math.pi)),
        size.height * 0.22,
      ),
      size.width * 0.18,
      paint,
    );

    paint.color = baseColor.withOpacity(0.4);
    canvas.drawCircle(
      Offset(
        size.width * 0.55,
        size.height * (0.72 + 0.03 * math.sin(progress * math.pi)),
      ),
      size.width * 0.35,
      paint,
    );

    final wavePath = Path()
      ..moveTo(0, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * (0.68 + 0.07 * math.sin(progress * 2 * math.pi)),
        size.width * 0.5,
        size.height * (0.71 - 0.05 * math.cos(progress * 2 * math.pi)),
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * (0.74 + 0.04 * math.sin(progress * 3 * math.pi)),
        size.width,
        size.height * (0.7 - 0.05 * math.sin(progress * 2 * math.pi)),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    paint.color = baseColor.withOpacity(0.35);
    canvas.drawPath(wavePath, paint);
  }

  @override
  bool shouldRepaint(covariant _HeroBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor;
  }
}

class _AttemptPoint {
  const _AttemptPoint({
    required this.date,
    required this.percent,
    required this.examTitle,
    this.outOfBounds = false,
  });

  final DateTime date;
  final double percent;
  final String examTitle;
  final bool outOfBounds;
}

class _PerformanceChart extends StatelessWidget {
  const _PerformanceChart({required this.points, required this.height});

  final List<_AttemptPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _PerformanceChartPainter(
          points: points,
          colorScheme: theme.colorScheme,
          textStyle: theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

class _PerformanceChartPainter extends CustomPainter {
  _PerformanceChartPainter({
    required this.points,
    required this.colorScheme,
    required this.textStyle,
  });

  final List<_AttemptPoint> points;
  final ColorScheme colorScheme;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 38.0;
    const rightPadding = 12.0;
    const topPadding = 14.0;
    const bottomPadding = 30.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final axisPaint = Paint()
      ..color = colorScheme.outline.withOpacity(0.35)
      ..strokeWidth = 1.1;

    final gridPaint = Paint()
      ..color = colorScheme.outline.withOpacity(0.18)
      ..strokeWidth = 1;

    // Axes
    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, size.height - bottomPadding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, size.height - bottomPadding),
      Offset(size.width - rightPadding, size.height - bottomPadding),
      axisPaint,
    );

    const yValues = [0, 25, 50, 75, 100];
    for (final value in yValues) {
      final dy = topPadding + chartHeight * (1 - value / 100);
      canvas.drawLine(
        Offset(leftPadding, dy),
        Offset(size.width - rightPadding, dy),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '$value%',
          style: textStyle.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, dy - tp.height / 2));
    }

    if (points.isEmpty) {
      return;
    }

    final path = Path();
    final fillPath = Path();
    final offsets = <Offset>[];
    final denominator = math.max(1, points.length - 1);
    for (var i = 0; i < points.length; i++) {
      final progress = i / denominator;
      final x = leftPadding + chartWidth * progress;
      final y =
          topPadding +
          chartHeight * (1 - points[i].percent.clamp(0, 100) / 100);
      final offset = Offset(x, y);
      offsets.add(offset);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath
      ..lineTo(offsets.last.dx, size.height - bottomPadding)
      ..lineTo(offsets.first.dx, size.height - bottomPadding)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary.withOpacity(0.25), Colors.transparent],
          ).createShader(
            Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
          );

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader =
          LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
          ).createShader(
            Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
          );

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;

    for (final offset in offsets) {
      canvas.drawCircle(offset, 4, pointPaint);
    }

    final labelCount = math.min(points.length, 5);
    final Set<int> selectedIndices = <int>{};
    if (labelCount == 1) {
      selectedIndices.add(0);
    } else if (labelCount > 1) {
      final maxIndex = points.length - 1;
      for (var i = 0; i < labelCount; i++) {
        final position = (i * maxIndex / (labelCount - 1)).round();
        selectedIndices.add(position);
      }
      selectedIndices.add(0);
      selectedIndices.add(maxIndex);
    }
    final sortedIndices = selectedIndices.toList()..sort();

    for (final index in sortedIndices) {
      final point = points[index];
      final dx = offsets[index].dx;
      final label =
          '${point.date.day.toString().padLeft(2, '0')}/${point.date.month.toString().padLeft(2, '0')}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: 80);
      tp.paint(
        canvas,
        Offset(dx - tp.width / 2, size.height - bottomPadding + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PerformanceChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.colorScheme != colorScheme;
  }
}
