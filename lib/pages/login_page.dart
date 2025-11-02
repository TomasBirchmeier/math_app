import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final appState = context.read<AppState>();
    final username = _userController.text;
    final password = _passwordController.text;

    if (username.trim().isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa usuario y contraseña.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await appState.login(username, password);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Usuario o contraseña incorrectos. Inténtalo nuevamente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(
          '¡Bienvenido de nuevo, ${appState.currentUser!.displayName}!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.08),
                    colorScheme.secondary.withOpacity(0.12),
                    colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, _) => CustomPaint(
                painter: _LoginBackgroundPainter(
                  progress: _backgroundController.value,
                  baseColor: colorScheme.primary.withOpacity(0.18),
                  secondaryColor: colorScheme.secondary.withOpacity(0.18),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 820;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: isWide
                          ? Row(
                              key: const ValueKey('wide'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildIllustration(colorScheme),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 48),
                            child: _buildFormCard(colorScheme),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                              key: const ValueKey('compact'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildIllustration(colorScheme),
                                  const SizedBox(height: 32),
                                  _buildFormCard(colorScheme),
                                ],
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(ColorScheme scheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 36),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.hasBoundedHeight;
          final double targetHeight =
              hasBoundedHeight ? (constraints.maxHeight - 96.0) : 0.0;
          final double minHeight =
              targetHeight.isFinite && targetHeight > 0 ? targetHeight : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 72, 8, 56),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  _LogoCard(),
                  const SizedBox(height: 40),
                  _ExperienceCard(controller: _backgroundController),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(ColorScheme scheme) {
    final theme = Theme.of(context);
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 38),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Quant+',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _userController,
                autofillHints: const [AutofillHints.username],
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Ingresa tu usuario',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: scheme.surfaceVariant.withOpacity(0.35),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingresa tu contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: scheme.surfaceVariant.withOpacity(0.35),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _handleLogin,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_rounded),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isSubmitting ? 'Ingresando...' : 'Entrar a la plataforma',
                    key: ValueKey(_isSubmitting),
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  final snack = SnackBar(
                    content: const Text(
                      'Escríbele a tu profesor para recuperar tu acceso 😊',
                    ),
                    behavior: SnackBarBehavior.floating,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                },
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      backgroundColor: scheme.secondaryContainer,
      labelStyle: TextStyle(color: scheme.onSecondaryContainer),
      label: Text(label),
      avatar: Icon(
        Icons.check_circle_outline,
        color: scheme.onSecondaryContainer,
      ),
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  const _LoginBackgroundPainter({
    required this.progress,
    required this.baseColor,
    required this.secondaryColor,
  });

  final double progress;
  final Color baseColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = baseColor;
    canvas.drawCircle(
      Offset(
        size.width * (0.2 + 0.04 * math.sin(progress * 2 * math.pi)),
        size.height * (0.25 + 0.05 * math.cos(progress * math.pi)),
      ),
      size.width * 0.35,
      paint,
    );

    paint.color = secondaryColor;
    canvas.drawCircle(
      Offset(
        size.width * (0.82 + 0.06 * math.cos(progress * 2 * math.pi)),
        size.height * (0.18 + 0.04 * math.sin(progress * math.pi)),
      ),
      size.width * 0.28,
      paint,
    );

    paint.color = baseColor.withOpacity(0.75);
    final wave = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * (0.68 + 0.05 * math.sin(progress * 2 * math.pi)),
        size.width * 0.45,
        size.height * (0.78 - 0.05 * math.sin(progress * math.pi)),
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * (0.8 + 0.04 * math.cos(progress * 2 * math.pi)),
        size.width,
        size.height * (0.74 + 0.04 * math.sin(progress * math.pi)),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave, paint);
  }

  @override
  bool shouldRepaint(covariant _LoginBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}

class _PlanetOrbit extends StatelessWidget {
  const _PlanetOrbit({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => CustomPaint(
        painter: _PlanetPainter(
          progress: animation.value,
          background: background,
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quant+',
            style: GoogleFonts.nunito(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: scheme.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El aula digital de matemáticas para estudiantes que quieren llegar más lejos.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: scheme.primary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offset = math.sin(controller.value * 2 * math.pi) * 6;
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withOpacity(0.94),
              scheme.secondary.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.28),
              blurRadius: 38,
              offset: const Offset(0, 26),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explora Quant+',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Practica con ensayos oficiales, obtén feedback instantáneo y permite que tu profesor siga cada avance.',
              style: GoogleFonts.nunito(
                fontSize: 16,
                height: 1.45,
                color: Colors.white.withOpacity(0.92),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            AspectRatio(
              aspectRatio: 1.05,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF8FBFF),
                        Color(0xFFE4F0FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF8B5CFF).withOpacity(0.18),
                                  const Color(0xFF6BF0A8).withOpacity(0.22),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ColoredBox(
                              color: Colors.transparent,
                              child: _PlanetOrbit(animation: controller),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Planeta Quant',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: _CuriosityBanner(animation: controller),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Lo que encontrarás en la plataforma',
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FeatureChip(label: 'Ensayos oficiales PAES'),
                _FeatureChip(label: 'Corrección automática'),
                _FeatureChip(label: 'Seguimiento docente'),
                _FeatureChip(label: 'Práctica guiada inteligente'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  const _PlanetPainter({required this.progress, required this.background});

  final double progress;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.52);
    final baseRadius = size.height * 0.38;
    final rotation = progress * math.pi * 2;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF2F80ED).withOpacity(0.28), background],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.9));
    canvas.drawCircle(center, baseRadius * 1.7, glowPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 0.25);

    final planetPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.4),
        radius: 1.05,
        colors: [const Color(0xFF2F80ED), const Color(0xFF1C4CBD)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: baseRadius));
    canvas.drawCircle(Offset.zero, baseRadius, planetPaint);

    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.6),
        radius: 0.7,
        colors: [Colors.white.withOpacity(0.65), Colors.white.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: baseRadius));
    canvas.drawCircle(Offset.zero, baseRadius, highlightPaint);

    final continentPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF6BF0A8), const Color(0xFF4CD28C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: baseRadius));

    Path createContinent(double seed, double scale, Offset shift) {
      final wiggle = math.sin(rotation + seed) * 0.08;
      double x(double v) => v * scale + shift.dx;
      double y(double v) => v * scale + shift.dy;
      final path = Path()
        ..moveTo(x(-baseRadius * (0.65 + wiggle)), y(-baseRadius * 0.05))
        ..cubicTo(
          x(-baseRadius * 0.4),
          y(-baseRadius * (0.55 + wiggle)),
          x(baseRadius * (0.15 + wiggle)),
          y(-baseRadius * 0.46),
          x(baseRadius * 0.38),
          y(-baseRadius * 0.1),
        )
        ..cubicTo(
          x(baseRadius * (0.58 - wiggle)),
          y(baseRadius * 0.3),
          x(-baseRadius * 0.12),
          y(baseRadius * 0.5),
          x(-baseRadius * 0.55),
          y(baseRadius * 0.32),
        )
        ..close();
      return path;
    }

    canvas.drawPath(createContinent(0.0, 1.0, Offset.zero), continentPaint);
    canvas.drawPath(
      createContinent(1.2, 0.82, const Offset(46, -42)),
      continentPaint,
    );

    final ridgePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final t = rotation + i * 0.85;
      final start = Offset(
        baseRadius * 0.6 * math.cos(t),
        baseRadius * 0.35 * math.sin(t),
      );
      final end = Offset(
        baseRadius * 0.25 * math.cos(t + 0.7),
        baseRadius * 0.7 * math.sin(t + 0.55),
      );
      canvas.drawLine(start, end, ridgePaint);
    }
    canvas.restore();

    final orbitRadius = baseRadius * 1.45;
    final orbitPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.65),
          Colors.white.withOpacity(0.12),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: orbitRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 0.9);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: orbitRadius * 2.3,
        height: orbitRadius * 1.35,
      ),
      orbitPaint,
    );

    final satelliteAngle = rotation * 2.3;
    final satellitePos = Offset(
      orbitRadius * 1.1 * math.cos(satelliteAngle),
      orbitRadius * 0.68 * math.sin(satelliteAngle),
    );
    final satellitePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.3)],
      ).createShader(Rect.fromCircle(center: satellitePos, radius: 10));
    canvas.drawCircle(satellitePos, 10, satellitePaint);
    canvas.drawCircle(
      satellitePos + const Offset(6, -3),
      4,
      Paint()..color = const Color(0xFF6BF0A8).withOpacity(0.8),
    );
    canvas.restore();

    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.7);
    for (var i = 0; i < 5; i++) {
      final t = rotation + i * 1.05;
      final cloudCenter = Offset(
        center.dx + baseRadius * 0.98 * math.cos(t),
        center.dy + baseRadius * 0.48 * math.sin(t),
      );
      canvas.drawCircle(cloudCenter, 12, cloudPaint);
      canvas.drawCircle(cloudCenter + const Offset(13, -4), 10, cloudPaint);
      canvas.drawCircle(cloudCenter + const Offset(-11, -3), 8, cloudPaint);
    }

    final sparklePaint = Paint()..color = Colors.white.withOpacity(0.55);
    for (var i = 0; i < 26; i++) {
      final t = (i * 27 + rotation * 720) % 360;
      final radians = t * math.pi / 180;
      final radius = baseRadius * 1.95;
      final sparkleCenter = Offset(
        center.dx + radius * math.cos(radians),
        center.dy + radius * 0.6 * math.sin(radians),
      );
      canvas.drawCircle(sparkleCenter, 1.5, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.background != background;
  }
}

class _CuriosityBanner extends StatelessWidget {
  const _CuriosityBanner({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final pulse = 0.85 + 0.15 * math.sin(animation.value * 2 * math.pi);
        return Transform.scale(
          scale: pulse,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  scheme.secondary.withOpacity(0.9),
                  scheme.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.public, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dato curioso: a la velocidad de la luz podrías rodear la Tierra 7.5 veces en un segundo.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
