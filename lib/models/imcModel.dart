class BmiEntry {
  final double weight; // em kg
  final double height; // em metros
  final double bmi;
  final DateTime date;

  BmiEntry({
    required this.weight,
    required this.height,
    required this.bmi,
    required this.date,
  });

  factory BmiEntry.fromData(double weight, double height) {
    final bmi = weight / (height * height);
    return BmiEntry(
      weight: weight,
      height: height,
      bmi: bmi,
      date: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'height': height,
        'bmi': bmi,
        'date': date.toIso8601String(),
      };

  factory BmiEntry.fromJson(Map<String, dynamic> json) => BmiEntry(
        weight: json['weight'],
        height: json['height'],
        bmi: json['bmi'],
        date: DateTime.parse(json['date']),
      );
}
