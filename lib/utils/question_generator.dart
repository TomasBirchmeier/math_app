import 'dart:math';

typedef _QuestionFactory = Map<String, String> Function();

class QuestionGenerator {
  final Random _random = Random();

  List<Map<String, String>> generar(String tema, {int cantidad = 5}) {
    final factories = _factoriesForTopic(tema);
    if (factories.isEmpty) {
      return const [];
    }
    final ejercicios = <Map<String, String>>[];
    for (int i = 0; i < cantidad; i++) {
      final factory = factories[_random.nextInt(factories.length)];
      ejercicios.add(factory());
    }
    return ejercicios;
  }

  List<_QuestionFactory> _factoriesForTopic(String tema) {
    switch (tema) {
      case 'Probabilidad':
        return [
          () {
            final caras = _random.nextInt(6) + 1;
            return {
              'pregunta':
                  'Al lanzar un dado balanceado, ¿cuál es la probabilidad de obtener un $caras?',
              'respuesta_correcta': '1/6',
            };
          },
          () {
            final exitos = _random.nextInt(3) + 1;
            const total = 5;
            return {
              'pregunta':
                  'En una bolsa hay $total canicas, $exitos son rojas. ¿Cuál es la probabilidad de sacar una roja?',
              'respuesta_correcta': '$exitos/$total',
            };
          },
          () {
            const total = 8;
            final caras = _random.nextInt(total) + 1;
            return {
              'pregunta':
                  'Un spinner numerado del 1 al $total se gira una vez. ¿Cuál es la probabilidad de que caiga en un número menor o igual a $caras?',
              'respuesta_correcta': '$caras/$total',
            };
          },
          () {
            return {
              'pregunta':
                  'Si lanzo una moneda dos veces, ¿cuál es la probabilidad de obtener dos caras seguidas?',
              'respuesta_correcta': '1/4',
            };
          },
        ];
      case 'Álgebra':
        return [
          () {
            final x = _random.nextInt(8) + 2;
            final resultado = 3 * x + 5;
            return {
              'pregunta': 'Resuelve para x: 3x + 5 = $resultado',
              'respuesta_correcta': '$x',
            };
          },
          () {
            final a = _random.nextInt(5) + 2;
            final b = _random.nextInt(6) + 1;
            final resultado = a * b;
            return {
              'pregunta': 'Si $a y = $resultado, ¿cuál es el valor de y?',
              'respuesta_correcta': '$b',
            };
          },
          () {
            final x = _random.nextInt(5) + 2;
            final c = _random.nextInt(6) + 1;
            final resultado = x - c;
            return {
              'pregunta': 'Resuelve: x - $c = $resultado',
              'respuesta_correcta': '$x',
            };
          },
          () {
            final x = _random.nextInt(6) + 2;
            final resultado = (x * x) + 4;
            return {
              'pregunta': 'Si x² + 4 = $resultado, ¿cuál es el valor de x?',
              'respuesta_correcta': '$x',
            };
          },
        ];
      case 'Números':
        return [
          () {
            final a = _random.nextInt(50) + 10;
            final b = _random.nextInt(50) + 10;
            return {
              'pregunta': '$a + $b = ?',
              'respuesta_correcta': '${a + b}',
            };
          },
          () {
            final a = _random.nextInt(90) + 10;
            final b = _random.nextInt(a);
            return {
              'pregunta': '$a - $b = ?',
              'respuesta_correcta': '${a - b}',
            };
          },
          () {
            final a = _random.nextInt(12) + 2;
            final b = _random.nextInt(10) + 2;
            return {
              'pregunta': '$a × $b = ?',
              'respuesta_correcta': '${a * b}',
            };
          },
          () {
            final divisor = _random.nextInt(8) + 2;
            final resultado = _random.nextInt(9) + 2;
            final dividendo = divisor * resultado;
            return {
              'pregunta': '$dividendo ÷ $divisor = ?',
              'respuesta_correcta': '$resultado',
            };
          },
        ];
      case 'Geometría':
        return [
          () {
            final lado = _random.nextInt(12) + 3;
            return {
              'pregunta': '¿Área de un cuadrado de lado $lado cm?',
              'respuesta_correcta': '${lado * lado}',
            };
          },
          () {
            final base = _random.nextInt(15) + 5;
            final altura = _random.nextInt(12) + 4;
            return {
              'pregunta': '¿Área de un triángulo de base $base cm y altura $altura cm?',
              'respuesta_correcta': '${(base * altura) ~/ 2}',
            };
          },
          () {
            final radio = _random.nextInt(8) + 3;
            final area = (pi * radio * radio).toStringAsFixed(2);
            return {
              'pregunta': 'Aproxima el área de un círculo de radio $radio cm (usa π ≈ 3.14).',
              'respuesta_correcta': area,
            };
          },
          () {
            final largo = _random.nextInt(15) + 5;
            final ancho = _random.nextInt(10) + 3;
            return {
              'pregunta': 'Perímetro de un rectángulo de $largo cm por $ancho cm:',
              'respuesta_correcta': '${2 * (largo + ancho)}',
            };
          },
          () {
            final lado = _random.nextInt(12) + 4;
            return {
              'pregunta': 'Perímetro de un triángulo equilátero con lado $lado cm:',
              'respuesta_correcta': '${lado * 3}',
            };
          },
        ];
      default:
        return const [];
    }
  }
}
