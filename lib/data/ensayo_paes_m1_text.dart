class ExamTextQuestion {
  const ExamTextQuestion({
    required this.number,
    required this.prompt,
    required this.options,
    required this.correctOption,
    this.context,
  });

  final int number;
  final String prompt;
  final Map<String, String> options;
  final String correctOption;
  final String? context;
}

const List<ExamTextQuestion> paesM1TextQuestions = [
  ExamTextQuestion(
    number: 1,
    prompt: '¿Cuál es el valor de 5² + 3²?',
    options: {'A': '32', 'B': '34', 'C': '36', 'D': '38'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 2,
    prompt: 'Determina el valor de √196.',
    options: {'A': '12', 'B': '13', 'C': '14', 'D': '15'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 3,
    prompt: 'Calcula 1/2 + 3/4.',
    options: {'A': '7/4', 'B': '1', 'C': '3/2', 'D': '5/4'},
    correctOption: 'D',
  ),
  ExamTextQuestion(
    number: 4,
    prompt: 'Si a = 4 y b = 3, ¿cuál es el valor de 2a − b²?',
    options: {'A': '-5', 'B': '-2', 'C': '-1', 'D': '2'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 5,
    prompt: 'Resuelve la ecuación 2x + 3 = 19.',
    options: {'A': '6', 'B': '7', 'C': '8', 'D': '9'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 6,
    prompt: '¿Cuál es la solución de 4(x − 2) = 3x + 5?',
    options: {'A': '11', 'B': '12', 'C': '13', 'D': '14'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 7,
    prompt: 'Evalúa |−3| + |−7|.',
    options: {'A': '6', 'B': '8', 'C': '9', 'D': '10'},
    correctOption: 'D',
  ),
  ExamTextQuestion(
    number: 8,
    prompt: 'Simplifica (x + 2)(x − 2).',
    options: {'A': 'x² + 4', 'B': 'x² − 2', 'C': 'x² − 4', 'D': 'x² + 2'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 9,
    prompt: 'Factoriza x² − 5x + 6.',
    options: {
      'A': '(x − 1)(x − 6)',
      'B': '(x − 2)(x − 3)',
      'C': '(x + 2)(x + 3)',
      'D': '(x − 2)(x + 3)',
    },
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 10,
    prompt: 'Resuelve el sistema 2x + y = 11 y x − y = 1.',
    options: {
      'A': '(3, 5)',
      'B': '(4, 3)',
      'C': '(5, 1)',
      'D': '(6, −1)',
    },
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 11,
    prompt: 'Una progresión aritmética tiene primer término 7 y diferencia 4. ¿Cuál es el sexto término?',
    options: {'A': '23', 'B': '24', 'C': '27', 'D': '31'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 12,
    prompt: '¿Cuál es el valor de x en la ecuación (x − 3)(x + 5) = 0?',
    options: {'A': '−5', 'B': '3', 'C': '−3', 'D': '5'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 13,
    prompt: 'En la ecuación de segundo grado x² − 8x + 12 = 0, ¿cuál es la suma de las raíces?',
    options: {'A': '−8', 'B': '−6', 'C': '6', 'D': '8'},
    correctOption: 'D',
  ),
  ExamTextQuestion(
    number: 14,
    prompt: 'Si f(x) = 3x − 4, ¿cuál es el valor de f(5)?',
    options: {'A': '11', 'B': '15', 'C': '16', 'D': '19'},
    correctOption: 'D',
  ),
  ExamTextQuestion(
    number: 15,
    prompt: 'Determina el valor de k para que la recta y = kx + 2 pase por el punto (4, 10).',
    options: {'A': '1', 'B': '2', 'C': '3', 'D': '4'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 16,
    prompt: 'Si log₁₀(x) = 2, ¿cuál es el valor de x?',
    options: {'A': '20', 'B': '50', 'C': '100', 'D': '200'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 17,
    prompt: '¿Cuál es la pendiente de la recta que une los puntos (2, 5) y (6, 17)?',
    options: {'A': '2', 'B': '3', 'C': '4', 'D': '6'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 18,
    prompt: 'Si g(x) = x² − 2x + 1, ¿cuál es el valor mínimo de g(x)?',
    options: {'A': '−1', 'B': '0', 'C': '1', 'D': '2'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 19,
    prompt: 'Resuelve la inecuación 2x − 5 > 7.',
    options: {
      'A': 'x > 1',
      'B': 'x > 5',
      'C': 'x > 6',
      'D': 'x > 8',
    },
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 20,
    prompt: '¿Cuál es el término general de la sucesión geométrica 3, 6, 12, 24, ...?',
    options: {
      'A': 'aₙ = 3 · 2ⁿ',
      'B': 'aₙ = 3 · 2ⁿ⁻¹',
      'C': 'aₙ = 3 · 2ⁿ⁺¹',
      'D': 'aₙ = 3 · 3ⁿ',
    },
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 21,
    context:
        'La siguiente tabla muestra la relación entre el tiempo t (en segundos) y la altura h(t) (en metros) de un objeto lanzado verticalmente:\n\nt (s) | 0 | 1 | 2 | 3 | 4\nh(t) (m) | 0 | 18 | 27 | 21 | 12',
    prompt: 'Según la tabla, ¿en qué intervalo de tiempo el objeto desciende?',
    options: {
      'A': 'Entre 0 s y 1 s',
      'B': 'Entre 1 s y 2 s',
      'C': 'Entre 2 s y 4 s',
      'D': 'Entre 4 s y 5 s',
    },
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 22,
    context:
        'El gráfico de la función lineal f(x) = ax + b pasa por los puntos (−2, 6) y (4, −6).',
    prompt: '¿Cuál es el valor de f(0)?',
    options: {'A': '−2', 'B': '0', 'C': '1', 'D': '2'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 23,
    context:
        'En el plano cartesiano, el punto A(−1, 2) es reflejado respecto del eje x para obtener el punto B.',
    prompt: '¿Cuál es la coordenada del punto B?',
    options: {
      'A': '(−1, −2)',
      'B': '(1, 2)',
      'C': '(1, −2)',
      'D': '(−1, 2)',
    },
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 24,
    context:
        'Una compañía modela sus ingresos (en millones de pesos) con la función I(x) = −0,5x² + 8x + 10, donde x es el número de meses desde el lanzamiento de un producto.',
    prompt: '¿En qué mes los ingresos alcanzan su valor máximo?',
    options: {'A': '4', 'B': '6', 'C': '8', 'D': '10'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 25,
    context:
        'La gráfica de y = |x − 3| + 1 se traslada 2 unidades hacia la izquierda.',
    prompt: '¿Cuál es la nueva ecuación?',
    options: {
      'A': 'y = |x − 1| + 1',
      'B': 'y = |x + 1| + 1',
      'C': 'y = |x − 5| + 1',
      'D': 'y = |x − 3| + 3',
    },
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 26,
    context:
        'El valor de producción diaria P(x) de una planta industrial se modela con P(x) = 150 + 20 ln(x), donde x es el número de días desde el inicio de operaciones.',
    prompt: '¿Cuál es el valor aproximado de P(1)? (ln(1) = 0)',
    options: {'A': '130', 'B': '150', 'C': '170', 'D': '190'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 27,
    context:
        'Un ciclista recorre un tramo recto desde el kilómetro 2 hasta el kilómetro 14 en 30 minutos.',
    prompt: '¿Cuál es su velocidad promedio en km/h?',
    options: {'A': '20', 'B': '24', 'C': '28', 'D': '40'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 28,
    context:
        'Un depósito de agua se llena según la función F(t) = 500(1 − e^{−0,4t}), donde t se mide en horas.',
    prompt: '¿Cuál es el volumen cuando han transcurrido 3 horas? (e^{−1,2} ≈ 0,301)',
    options: {
      'A': '149,5 litros',
      'B': '200,5 litros',
      'C': '350,5 litros',
      'D': '349,5 litros',
    },
    correctOption: 'D',
  ),
  ExamTextQuestion(
    number: 29,
    context:
        'La función cuadrática q(x) = x² − 4x − 5 modela la altura de una partícula (en metros) respecto del tiempo x (en segundos).',
    prompt: '¿En qué instante la partícula toca el suelo nuevamente? (Cuando q(x) = 0)',
    options: {'A': 'x = −1', 'B': 'x = 0', 'C': 'x = 5', 'D': 'x = 9'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 30,
    context:
        'Una función exponencial cumple que f(1) = 12 y f(3) = 108.',
    prompt: '¿Cuál es el valor de f(2) si f(x) = ab^x?',
    options: {'A': '24', 'B': '36', 'C': '48', 'D': '60'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 31,
    context:
        'Un rectángulo tiene largo 12 cm y ancho 5 cm.',
    prompt: '¿Cuál es la longitud de su diagonal?',
    options: {'A': '11 cm', 'B': '12,5 cm', 'C': '13 cm', 'D': '14 cm'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 32,
    context:
        'Un triángulo isósceles tiene lados congruentes de 10 cm y base de 12 cm.',
    prompt: '¿Cuál es el área del triángulo?',
    options: {'A': '48 cm²', 'B': '54 cm²', 'C': '60 cm²', 'D': '96 cm²'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 33,
    context:
        'En un plano cartesiano, el cuadrado ABCD tiene vértices A(0, 0), B(4, 0), C(4, 4) y D(0, 4).',
    prompt: '¿Cuál es el área del triángulo ABD?',
    options: {'A': '8', 'B': '10', 'C': '12', 'D': '16'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 34,
    context:
        'Un cilindro tiene radio 5 cm y altura 12 cm.',
    prompt: '¿Cuál es su volumen? (Usa π ≈ 3,14)',
    options: {'A': '235,5 cm³', 'B': '314 cm³', 'C': '942 cm³', 'D': '1 256 cm³'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 35,
    context:
        'Un cono tiene el mismo radio y altura que el cilindro del ejercicio anterior.',
    prompt: '¿Cuál es su volumen?',
    options: {'A': '314 cm³', 'B': '471 cm³', 'C': '628 cm³', 'D': '785 cm³'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 36,
    context:
        'Una circunferencia de radio 9 cm se divide en un sector de 120° y el resto.',
    prompt: '¿Cuál es el área del sector? (Usa π ≈ 3,14)',
    options: {'A': '84,78 cm²', 'B': '104,72 cm²', 'C': '169,56 cm²', 'D': '339,12 cm²'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 37,
    context:
        'En la figura (no reproducida) se muestra un trapecio isósceles cuyos lados paralelos miden 18 cm y 10 cm, y su altura es 6 cm.',
    prompt: '¿Cuál es el área del trapecio?',
    options: {'A': '72 cm²', 'B': '84 cm²', 'C': '96 cm²', 'D': '108 cm²'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 38,
    context:
        'Un triángulo rectángulo tiene catetos de 9 cm y 12 cm.',
    prompt: '¿Cuál es el valor exacto de sin(θ) si θ es el ángulo opuesto al cateto de 9 cm?',
    options: {'A': '3/4', 'B': '4/5', 'C': '5/9', 'D': '9/13'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 39,
    context:
        'El vector u = (4, −2) y el vector v = (−1, 5).',
    prompt: '¿Cuál es el valor del producto punto u · v?',
    options: {'A': '−14', 'B': '6', 'C': '14', 'D': '24'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 40,
    context:
        'Una esfera tiene volumen 288π cm³.',
    prompt: '¿Cuál es su radio?',
    options: {'A': '4 cm', 'B': '6 cm', 'C': '8 cm', 'D': '12 cm'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 41,
    context:
        'Un dado justo se lanza dos veces.',
    prompt: '¿Cuál es la probabilidad de obtener una suma igual a 9?',
    options: {'A': '1/9', 'B': '1/8', 'C': '1/6', 'D': '1/4'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 42,
    context:
        'En una encuesta a 200 estudiantes, 120 practican deporte, 80 leen diariamente y 50 hacen ambas actividades.',
    prompt: '¿Cuántos estudiantes no practican ninguna de las dos actividades?',
    options: {'A': '50', 'B': '60', 'C': '80', 'D': '100'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 43,
    context:
        'Una distribución de datos presenta la siguiente tabla de frecuencias:\n\nIntervalo | Frecuencia\n[0, 10) | 4\n[10, 20) | 6\n[20, 30) | 10\n[30, 40) | 8',
    prompt: '¿Cuál es la frecuencia relativa del intervalo [20, 30)?',
    options: {'A': '0,10', 'B': '0,25', 'C': '0,30', 'D': '0,40'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 44,
    context:
        'El valor de la media aritmética de los números 5, 8, 12, 15 y x es 12.',
    prompt: '¿Cuál es el valor de x?',
    options: {'A': '20', 'B': '22', 'C': '25', 'D': '27'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 45,
    context:
        'En un triángulo rectángulo, tan(α) = 3/4.',
    prompt: '¿Cuál es el valor de sin(α)?',
    options: {'A': '3/5', 'B': '4/5', 'C': '5/7', 'D': '7/9'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 46,
    context:
        'Una moneda cargada tiene probabilidad 0,6 de caer cara. Se lanza tres veces.',
    prompt: '¿Cuál es la probabilidad de obtener exactamente dos caras?',
    options: {'A': '0,216', 'B': '0,432', 'C': '0,648', 'D': '0,864'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 47,
    context:
        'La función h(x) = 2 sin(x) + 3 cos(x).',
    prompt: '¿Cuál es el valor de h(0)?',
    options: {'A': '0', 'B': '2', 'C': '3', 'D': '5'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 48,
    context:
        'Un vector aleatorio toma valores 2, 4 y 6 con probabilidades respectivas 0,2; 0,5 y 0,3.',
    prompt: '¿Cuál es su valor esperado?',
    options: {'A': '3,8', 'B': '4,2', 'C': '4,4', 'D': '4,8'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 49,
    context:
        'La mediana de los datos 12, 18, 25, 30, 35, 40 y x es 30.',
    prompt: '¿Cuál puede ser el valor de x?',
    options: {'A': '10', 'B': '20', 'C': '32', 'D': '45'},
    correctOption: 'D',
  ),
  ExamTextQuestion(
    number: 50,
    context:
        'Se aplica una prueba estandarizada cuyo puntaje tiene distribución normal con media 600 y desviación estándar 40.',
    prompt: '¿Cuál es el puntaje z de un estudiante que obtuvo 660 puntos?',
    options: {'A': '1', 'B': '1,5', 'C': '2', 'D': '2,5'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 51,
    prompt: 'Calcula la derivada de f(x) = 3x² − 4x + 7.',
    options: {'A': '3x − 4', 'B': '6x − 4', 'C': '6x + 7', 'D': '9x − 4'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 52,
    prompt: 'Evalúa la derivada de g(x) = √x en x = 9.',
    options: {'A': '1/3', 'B': '1/6', 'C': '1/18', 'D': '1/9'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 53,
    prompt: 'Determina la integral indefinida ∫ (4x³ − 2x) dx.',
    options: {'A': 'x⁴ − x² + C', 'B': 'x⁴ − x²/2 + C', 'C': 'x⁴ + x² + C', 'D': '4x⁴ − x² + C'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 54,
    context:
        'Un tanque se vacía a razón de V(t) = 500 − 30t litros, donde t se mide en minutos.',
    prompt: '¿Cuánto volumen queda transcurridos 12 minutos?',
    options: {'A': '120 litros', 'B': '140 litros', 'C': '160 litros', 'D': '180 litros'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 55,
    context:
        'Se define la sucesión a₁ = 2 y aₙ₊₁ = 3aₙ + 1.',
    prompt: '¿Cuál es el valor de a₃?',
    options: {'A': '20', 'B': '22', 'C': '26', 'D': '28'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 56,
    prompt: 'Resuelve la ecuación exponencial 2^{x+1} = 64.',
    options: {'A': 'x = 4', 'B': 'x = 5', 'C': 'x = 6', 'D': 'x = 7'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 57,
    context:
        'Se tiene la función f(x) = ln(x² + 1).',
    prompt: '¿Cuál es f′(x)?',
    options: {'A': '2x / (x² + 1)', 'B': 'x / (x² + 1)', 'C': '2 / (x² + 1)', 'D': '1 / (x² + 1)'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 58,
    prompt: 'Un préstamo se capitaliza mensualmente a una tasa del 1,5 %. ¿Cuál es el factor de capitalización anual?',
    options: {'A': '1,015', 'B': '1,150', 'C': '1,196', 'D': '1,215'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 59,
    context:
        'La cantidad de bacterias en un cultivo se modela con B(t) = 2 000 · e^{0,3t}, donde t se mide en horas.',
    prompt: '¿Cuántas bacterias habrá después de 4 horas? (e^{1,2} ≈ 3,320)',
    options: {'A': '3 320', 'B': '4 256', 'C': '6 640', 'D': '13 280'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 60,
    context:
        'Una población se ajusta al modelo logístico P(t) = 10 000 / (1 + 9e^{−0,2t}).',
    prompt: '¿Cuál es el valor límite de la población?',
    options: {'A': '9 000 habitantes', 'B': '10 000 habitantes', 'C': '11 000 habitantes', 'D': '90 000 habitantes'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 61,
    prompt: 'Resuelve la ecuación logarítmica log₂(x − 1) = 3.',
    options: {'A': 'x = 7', 'B': 'x = 8', 'C': 'x = 9', 'D': 'x = 10'},
    correctOption: 'C',
  ),
  ExamTextQuestion(
    number: 62,
    context:
        'La función f(x) = x³ − 6x² + 9x modela la utilidad (en millones de pesos) de una empresa.',
    prompt: '¿En qué valor de x la utilidad es máxima? (Considera la derivada).',
    options: {'A': 'x = 0', 'B': 'x = 1', 'C': 'x = 2', 'D': 'x = 3'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 63,
    prompt: 'Evalúa la integral definida ∫₀² (3x² − 4x + 1) dx.',
    options: {'A': '2', 'B': '4', 'C': '6', 'D': '8'},
    correctOption: 'A',
  ),
  ExamTextQuestion(
    number: 64,
    context:
        'La razón entre los lados de un triángulo rectángulo es 5:12:13.',
    prompt: 'Si la hipotenusa mide 26 cm, ¿cuál es el perímetro del triángulo?',
    options: {'A': '52 cm', 'B': '60 cm', 'C': '78 cm', 'D': '91 cm'},
    correctOption: 'B',
  ),
  ExamTextQuestion(
    number: 65,
    context:
        'Un analista ajusta una regresión lineal obteniendo la pendiente m = 2,4 y la ordenada al origen b = −5,2.',
    prompt: '¿Cuál es el valor estimado cuando la variable independiente es 8?',
    options: {'A': '12,0', 'B': '13,0', 'C': '14,0', 'D': '14,2'},
    correctOption: 'D',
  ),
];
