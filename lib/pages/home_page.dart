import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exam_catalog.dart';
import '../data/ensayo_m1_2023.dart';
import '../data/ensayo_paes_m1_text.dart';
import '../models/exam.dart';
import '../state/app_state.dart';
import '../utils/question_generator.dart';
import 'profile_page.dart';
import 'exam_session_page.dart';
import 'exam_text_session_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _temaSeleccionado = AppState.topics.first;
  List<Map<String, String>> _ejercicios = [];
  final Map<int, String> _respuestas = {};
  bool _corregido = false;
  int _puntos = 0;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _generarEjercicios(_temaSeleccionado);
  }

  void _generarEjercicios(String tema) {
    final nuevosEjercicios = QuestionGenerator().generar(tema);
    setState(() {
      _temaSeleccionado = tema;
      _ejercicios = nuevosEjercicios;
      _respuestas.clear();
      _corregido = false;
      _puntos = 0;
    });
  }

  Future<void> _corregir() async {
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      return;
    }

    int aciertos = 0;
    for (int i = 0; i < _ejercicios.length; i++) {
      final respuesta = _respuestas[i]?.trim();
      final correcta = _ejercicios[i]['respuesta_correcta'];
      if (respuesta != null && correcta != null && respuesta == correcta) {
        aciertos++;
      }
    }

    setState(() {
      _corregido = true;
      _puntos = aciertos;
    });

    if (aciertos > 0) {
      await appState.recordScore(
        userId: user.id,
        topic: _temaSeleccionado,
        points: aciertos,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Obtuviste $aciertos / ${_ejercicios.length} respuestas correctas 🎯'),
        backgroundColor: Colors.indigo,
      ),
    );
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${user.displayName}'),
        actions: [
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
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildPracticeTab(progreso, total),
          _buildExamTab(appState, user.id),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Práctica',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Ensayos',
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeTab(Map<String, int> progreso, int total) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ResumenProgreso(progreso: progreso, total: total),
            const SizedBox(height: 16),
            _buildSelectorTema(),
            const SizedBox(height: 16),
            Expanded(child: _buildEjercicios()),
            if (_ejercicios.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  onPressed: _corregido ? null : _corregir,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Corregir respuestas'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              if (_corregido)
                TextButton.icon(
                  onPressed: () => _generarEjercicios(_temaSeleccionado),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Intentar con nuevos ejercicios'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExamTab(AppState state, String userId) {
    final assetInfo = ExamCatalog.getById(ExamCatalog.assetM1ExamId);
    final paesInfo = ExamCatalog.getById(ExamCatalog.paesM1ExamId);
    final assetAttempt = state.examAttemptFor(assetInfo.id, userId);
    final paesAttempt = state.examAttemptFor(paesInfo.id, userId);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ensayos de preparación PAES',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona el ensayo que quieres rendir. Cada intento se registra con su tiempo y tus respuestas para que la profesora pueda retroalimentarte.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _ExamCard(
              title: assetInfo.title,
              description: assetInfo.description,
              questionCount: assetInfo.questionCount,
              attempt: assetAttempt,
              formatDuration: _formatDuration,
              formatDate: _formatAttemptDate,
              onStart: () => _launchExam((_) => ExamAssetSessionPage(
                    examId: assetInfo.id,
                    examTitle: assetInfo.title,
                    questions: ensayoM1May2023,
                  )),
            ),
            const SizedBox(height: 16),
            _ExamCard(
              title: paesInfo.title,
              description: paesInfo.description,
              questionCount: paesInfo.questionCount,
              attempt: paesAttempt,
              formatDuration: _formatDuration,
              formatDate: _formatAttemptDate,
              onStart: () => _launchExam((_) => ExamTextSessionPage(
                    examId: paesInfo.id,
                    examTitle: paesInfo.title,
                    questions: paesM1TextQuestions,
                  )),
            ),
            const SizedBox(height: 24),
            Text(
              'Recomendaciones',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('• No cierres la aplicación mientras el ensayo está en curso.'),
            const Text('• Marca la alternativa que consideres correcta (A, B, C o D).'),
            const Text('• El ensayo se enviará automáticamente al agotar el tiempo.'),
          ],
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

  String _formatAttemptDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  Widget _buildSelectorTema() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Selecciona un tema',
              border: OutlineInputBorder(),
            ),
            value: _temaSeleccionado,
            items: AppState.topics
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _generarEjercicios(value);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        IconButton.outlined(
          tooltip: 'Nuevos ejercicios',
          icon: const Icon(Icons.refresh),
          onPressed: () => _generarEjercicios(_temaSeleccionado),
        ),
      ],
    );
  }

  Widget _buildEjercicios() {
    if (_ejercicios.isEmpty) {
      return const Center(
        child: Text(
          'No hay ejercicios disponibles por ahora.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: _ejercicios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ejercicio = _ejercicios[index];
        final correcta = ejercicio['respuesta_correcta'];
        final esCorrecto = correcta != null && _respuestas[index] == correcta;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ejercicio ${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  ejercicio['pregunta'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _corregido
                    ? _ResultadoRespuesta(
                        esCorrecto: esCorrecto,
                        respuestaCorrecta: correcta ?? '',
                        respuestaUsuario: _respuestas[index],
                      )
                    : TextField(
                        decoration: const InputDecoration(
                          labelText: 'Tu respuesta',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _respuestas[index] = value.trim();
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.title,
    required this.description,
    required this.questionCount,
    required this.attempt,
    required this.onStart,
    required this.formatDuration,
    required this.formatDate,
  });

  final String title;
  final String description;
  final int questionCount;
  final ExamAttempt? attempt;
  final VoidCallback onStart;
  final String Function(int) formatDuration;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Text('Preguntas: $questionCount'),
            if (attempt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Último intento',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text('Respondidas: ${attempt!.answeredCount} / $questionCount'),
              Text('Duración: ${formatDuration(attempt!.durationSeconds)}'),
              Text('Fecha: ${formatDate(attempt!.completedAt)}'),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Iniciar ensayo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenProgreso extends StatelessWidget {
  const _ResumenProgreso({required this.progreso, required this.total});

  final Map<String, int> progreso;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu progreso general',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppState.topics
                  .map(
                    (topic) => _TopicChip(
                      topic: topic,
                      points: progreso[topic] ?? 0,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Total acumulado: $total puntos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.topic, required this.points});

  final String topic;
  final int points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: scheme.secondary,
        child: Text(
          topic.substring(0, 1),
          style: TextStyle(
            color: scheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text('$topic • $points pts'),
    );
  }
}

class _ResultadoRespuesta extends StatelessWidget {
  const _ResultadoRespuesta({
    required this.esCorrecto,
    required this.respuestaCorrecta,
    this.respuestaUsuario,
  });

  final bool esCorrecto;
  final String respuestaCorrecta;
  final String? respuestaUsuario;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              esCorrecto ? Icons.check_circle : Icons.cancel,
              color: esCorrecto ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              esCorrecto ? '¡Correcto!' : 'Respuesta incorrecta',
              style: TextStyle(
                color: esCorrecto ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Tu respuesta: ${respuestaUsuario?.isEmpty ?? true ? '—' : respuestaUsuario}'),
        Text('Respuesta correcta: $respuestaCorrecta'),
      ],
    );
  }
}
