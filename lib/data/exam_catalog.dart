class ExamCatalogEntry {
  const ExamCatalogEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.usesAssets,
  });

  final String id;
  final String title;
  final String description;
  final int questionCount;
  final bool usesAssets;
}

class ExamCatalog {
  static const String assetM1ExamId = 'm1_pdf_mayo2023';
  static const String assetM1ExamFebId = 'm1_pdf_feb2023';
  static const String paesM1ExamId = 'paes_m1_textual';

  static const Map<String, ExamCatalogEntry> _entries = {
    assetM1ExamId: ExamCatalogEntry(
      id: assetM1ExamId,
      title: 'Ensayo M1 · Mayo 2023',
      description: 'Versión digitalizada del ensayo con preguntas originales en formato imagen.',
      questionCount: 65,
      usesAssets: true,
    ),
    assetM1ExamFebId: ExamCatalogEntry(
      id: assetM1ExamFebId,
      title: 'Ensayo M1 · Febrero 2023',
      description: 'Nueva versión digitalizada para reforzar la preparación con el temario de verano.',
      questionCount: 65,
      usesAssets: true,
    ),
    paesM1ExamId: ExamCatalogEntry(
      id: paesM1ExamId,
      title: 'Ensayo PAES M1 (Generado)',
      description:
          '65 ítems inéditos inspirados en la PAES de Matemática 1 con modelos, gráficos y problemas aplicados.',
      questionCount: 65,
      usesAssets: false,
    ),
  };

  static ExamCatalogEntry getById(String id) {
    return _entries[id] ?? _entries[assetM1ExamId]!;
  }

  static List<ExamCatalogEntry> all() => _entries.values.toList();
}
