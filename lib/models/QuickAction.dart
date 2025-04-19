
class QuickAction {
  final String name;
  final DateTime timestamp;

  QuickAction({required this.name, required this.timestamp});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp
    };
  }

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      name: json['name'],
      timestamp: json['timestamp'],
    );
  }

}