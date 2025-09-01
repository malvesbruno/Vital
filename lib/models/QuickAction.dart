// Modelo de ação rápida

class QuickAction {
  final String name;
  final DateTime timestamp;

  QuickAction({required this.name, required this.timestamp});

  factory QuickAction.empty() {
    return QuickAction(
      name: 'Ação rápida',
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      name: json['name'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
