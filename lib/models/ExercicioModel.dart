
class ExercicioModel {
  String name;
  int sets;
  int duration;
  int completedSets;
  bool completed;

  ExercicioModel({
    required this.name,
    required this.sets,
    required this.duration,
    this.completedSets = 0,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'sets': sets,
        'duration': duration,
        'completedSets': completedSets,
        'completed': completed,
      };

  factory ExercicioModel.fromMap(Map<String, dynamic> map) => ExercicioModel(
        name: map['name'],
        sets: map['sets'],
        duration: map['duration'],
        completedSets: map['completedSets'] ?? 0,
        completed: map['completed'] ?? false,
      );

  Map<String, dynamic> toJson() {
    return {
        'name': name,
        'sets': sets,
        'duration': duration,
        'completedSets': completedSets,
        'completed': completed,
      };
  }

  factory ExercicioModel.fromJson(Map<String, dynamic> json) {
    return ExercicioModel(
      name: json['name'],
      sets: json['sets'],
      duration: json['duration'],
      completedSets: json['completedSets'],
      completed: json['completed'] ?? false,
    );
  }

}