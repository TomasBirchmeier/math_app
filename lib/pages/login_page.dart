import 'dart:math' as math;

import 'package:flutter/material.dart';
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
        content: Text(
          '¡Bienvenido de nuevo, ${appState.currentUser!.displayName}!',
        ),
        backgroundColor: Colors.indigo,
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
                                Expanded(child: _buildFormCard(colorScheme)),
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
      child: Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withOpacity(0.85),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.25),
              blurRadius: 38,
              offset: const Offset(0, 26),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.onPrimaryContainer.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  width: 1.5,
                  color: scheme.onPrimaryContainer.withOpacity(0.25),
                ),
              ),
              child: Icon(
                Icons.calculate_outlined,
                size: 64,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Maths by Tomás',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: scheme.onPrimaryContainer,
                height: 1.15,
                fontFamily: 'Cursive',
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Practica con bancos ilimitados, ensayos oficiales en línea y seguimiento docente en tiempo real.',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: scheme.onPrimaryContainer.withOpacity(0.75),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: const [
                _FeatureChip(label: 'Sesión personalizada'),
                _FeatureChip(label: 'Temario variado'),
                _FeatureChip(label: 'Panel docente'),
                _FeatureChip(label: 'Ensayos PAES'),
              ],
            ),
          ],
        ),
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
                'Maths by Tomás',
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
                  hintText: 'Ej. sofia',
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
                  hintText: 'Ej. sofia456',
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
              const Divider(height: 32),
              Text(
                'Prueba con usuarios ejemplo como “sofia/sofia456” o ingresa como administradora “admin/admin123”.',
                style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
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
