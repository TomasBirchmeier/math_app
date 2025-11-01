import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/question_generator.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late String _temaSeleccionado;
  List<Map<String, String>> _ejercicios = [];
  final Map<int, String> _respuestas = {};
  bool _corregido = false;

  @override
  void initState() {
    super.initState();
    _temaSeleccionado = AppState.topics.first;
    _generarEjercicios(_temaSeleccionado);
  }

  void _generarEjercicios(String tema) {
    final nuevosEjercicios = QuestionGenerator().generar(tema);
    setState(() {
      _temaSeleccionado = tema;
      _ejercicios = nuevosEjercicios;
      _respuestas.clear();
      _corregido = false;
    });
  }

  Future<void> _corregir() async {
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      return;
    }

    int aciertos = 0;
    for (var i = 0; i < _ejercicios.length; i++) {
      final respuesta = _respuestas[i]?.trim();
      final correcta = _ejercicios[i]['respuesta_correcta'];
      if (respuesta != null && correcta != null && respuesta == correcta) {
        aciertos++;
      }
    }

    setState(() {
      _corregido = true;
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
        content: Text(
          'Obtuviste $aciertos / ${_ejercicios.length} respuestas correctas 🎯',
        ),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para acceder a la práctica.')),
      );
    }
    final progreso = appState.progressFor(user.id);
    final total = appState.totalPointsFor(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Práctica guiada · Maths by Tomás'),
        actions: [
          IconButton(
            tooltip: 'Nuevos ejercicios',
            icon: const Icon(Icons.refresh),
            onPressed: () => _generarEjercicios(_temaSeleccionado),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResumenProgreso(progreso: progreso, total: total),
              const SizedBox(height: 16),
              _buildSelectorTema(),
              const SizedBox(height: 16),
              Expanded(child: _buildEjercicios()),
              if (_ejercicios.isNotEmpty) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _corregido ? null : _corregir,
                  icon: _corregido
                      ? const Icon(Icons.emoji_events_outlined)
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _corregido ? 'Resultados listos' : 'Corregir respuestas',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
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
      ),
    );
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
        IconButton.filledTonal(
          tooltip: 'Recargar',
          icon: const Icon(Icons.shuffle),
          onPressed: () => _generarEjercicios(_temaSeleccionado),
        ),
      ],
    );
  }

  Widget _buildEjercicios() {
    if (_ejercicios.isEmpty) {
      return const Center(
        child: Text(
          'Selecciona un tema para comenzar 📚',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _ejercicios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ejercicio = _ejercicios[index];
        final correcta = ejercicio['respuesta_correcta'];
        final esCorrecto = correcta != null && _respuestas[index] == correcta;
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                          hintText: 'Tu respuesta aquí',
                        ),
                        onChanged: (val) => _respuestas[index] = val.trim(),
                      ),
              ],
            ),
          ),
        );
      },
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
                    (topic) =>
                        _TopicChip(topic: topic, points: progreso[topic] ?? 0),
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
        Text(
          'Tu respuesta: ${respuestaUsuario?.isEmpty ?? true ? '—' : respuestaUsuario}',
        ),
        Text('Respuesta correcta: $respuestaCorrecta'),
      ],
    );
  }
}
