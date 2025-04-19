
class DailyStats {
  final DateTime date;
  final double waterLiters;
  final int completedActivities;
  final int completedWorkouts;
  final bool wasActive;

  DailyStats({
    required this.date,
    this.waterLiters = 0.0,
    this.completedActivities = 0,
    this.completedWorkouts = 0,
    this.wasActive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'waterLiters':waterLiters,
      'completedActivities': completedActivities,
      'completedWorkouts': completedWorkouts,
      'wasActive': wasActive,
    };
  }

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date']),
      waterLiters: (json['waterLiters'] as num).toDouble(),
      completedActivities: json['completedActivities'] as int,
      completedWorkouts: json['completedWorkouts'] as int,
      wasActive: json['wasActive'] as bool,
    );
  }
}

