import 'dart:convert';

import 'package:flutter/material.dart';

enum HabitType {
  chakra('CHAKRA', Color(0xFF5D63F3), Icons.self_improvement),
  vitality('VITALITY', Color(0xFFF4A11A), Icons.fitness_center),
  focus('FOCUS', Color(0xFF2E88F7), Icons.psychology);

  const HabitType(this.label, this.accent, this.icon);

  final String label;
  final Color accent;
  final IconData icon;

  static HabitType fromLabel(String raw) {
    return HabitType.values.firstWhere(
      (type) => type.label.toLowerCase() == raw.toLowerCase(),
      orElse: () => HabitType.focus,
    );
  }
}

class Habit {
  Habit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.completed = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final HabitType type;
  bool completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'type': type.label,
    'completed': completed,
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      type: HabitType.fromLabel((json['type'] as String?) ?? 'FOCUS'),
      completed: (json['completed'] as bool?) ?? false,
    );
  }

  static List<Habit> decodeList(String rawJson) {
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded.map((item) => Habit.fromJson(item as Map<String, dynamic>)).toList();
  }

  static String encodeList(List<Habit> habits) {
    return jsonEncode(habits.map((habit) => habit.toJson()).toList());
  }
}

List<Habit> defaultHabits() {
  return [
    Habit(
      id: 'h1',
      title: 'Deep Meditation',
      subtitle: 'Expand the mind\'s horizon',
      type: HabitType.chakra,
      completed: true,
    ),
    Habit(
      id: 'h2',
      title: 'Physical Tempering',
      subtitle: 'Strengthen the vessel',
      type: HabitType.vitality,
    ),
    Habit(
      id: 'h3',
      title: 'Focus Protocol',
      subtitle: '45m Deep Work Session',
      type: HabitType.focus,
    ),
    Habit(
      id: 'h4',
      title: 'Essence Hydration',
      subtitle: '2L Divine Fluid',
      type: HabitType.vitality,
      completed: true,
    ),
  ];
}
