
class DailyChallengeModel {
  final String title;
  final String description;
  final int reward;
  final int exp;
  bool completed;
  final bool autoComplete;
  final String assignedDate; // formato: 'yyyy-MM-dd'

  DailyChallengeModel({
    required this.title,
    this.description = '',
    required this.reward,
    required this.exp,
    this.completed = false,
    this.autoComplete = false,
    required this.assignedDate,
  });

  /// Construtor de desafio vazio (placeholder)
  factory DailyChallengeModel.empty() {
    return DailyChallengeModel(
      title: '',
      description: '',
      reward: 0,
      exp: 0,
      completed: false,
      autoComplete: false,
      assignedDate: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'reward': reward,
      'exp': exp,
      'completed': completed,
      'autoComplete': autoComplete,
      'assignedDate': assignedDate,
    };
  }

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      title: json['title'],
      description: json['description'],
      reward: json['reward'] ?? 0,
      exp: json['exp'] ?? 0,
      completed: json['completed'] ?? false,
      autoComplete: json['autoComplete'] ?? false,
      assignedDate: json['assignedDate'] ?? '',
    );
  }

  factory DailyChallengeModel.fromMap(Map<String, dynamic> map) {
    return DailyChallengeModel(
      title: map['title'],
      description: map['description'],
      reward: map['reward'],
      exp: map['exp'],
      completed: map['completed'] == 1,
      autoComplete: map['autoComplete'] == 1,
      assignedDate: map['assignedDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'reward': reward,
      'exp': exp,
      'completed': completed ? 1 : 0,
      'autoComplete': autoComplete ? 1 : 0,
      'assignedDate': assignedDate,
    };
  }
}
