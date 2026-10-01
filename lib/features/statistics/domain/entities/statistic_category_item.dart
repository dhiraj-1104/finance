import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a category item within statistics breakdown (with amount, percentage, color, and icon).
class StatisticCategoryItem extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double amount;
  final double percentage;
  final List<StatisticCategoryItem> subCategories;

  const StatisticCategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
    this.subCategories = const [],
  });

  StatisticCategoryItem copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    double? amount,
    double? percentage,
    List<StatisticCategoryItem>? subCategories,
  }) {
    return StatisticCategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    color,
    amount,
    percentage,
    subCategories,
  ];
}
