import 'package:flutter/material.dart';

class StatsModel {
  final DateTime date;
  final String title;
  final List<double> data;
  final IconData icon;
  final Color color;
  final List<String> labels;
  final String unit;
  final bool isPercentage;
  final double goal;
  final bool isBmi;

  StatsModel({
    required this.date,
    required this.title,
    required this.data,
    required this.icon,
    required this.labels,
    required this.color,
    required this.unit,
    required this.isPercentage,
    required this.goal,
    required this.isBmi
  });

}