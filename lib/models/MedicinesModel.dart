class Medicine {
  final String name;
  final String dosage;
  final String frequency;
  final String use;

  Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.use,
  });

  // Convert JSON → Dart object
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] ?? 'Unknown Medicine',
      dosage: json['dosage'] ?? 'Not specified',
      frequency: json['frequency'] ?? 'Not specified',
      use: json['use'] ?? 'Not specified',
    );
  }
}
