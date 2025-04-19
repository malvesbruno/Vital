class DailyChallengeModel {
  final String title;
  final String description;
  final int reward; // moedas recebidas ao concluir
  final int exp;
  bool completed;
  final bool autoComplete;

  DailyChallengeModel({
    required this.title,
    this.description = '',
    required this.reward,
    required this.exp,
    this.completed = false,
    this.autoComplete = false
    
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'reward': reward, 
      'exp':  exp,
      'completed': completed,
      'autocomplete': autoComplete
    };
  }

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      title: json['title'],
      description: json['description'],
      reward: json['reward'] ?? 0,
      exp: json['exp'] ?? 0,
      completed: json['completed'] ?? false,
      autoComplete: json['autocomplete'] ?? false
    );
  }

}