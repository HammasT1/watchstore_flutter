import 'package:flutter/material.dart';

class WatchItem {
  const WatchItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.accent,
    required this.description,
    required this.caseSize,
    required this.movement,
    required this.waterResistance,
    required this.strap,
  });

  final String id;
  final String name;
  final String image;
  final int price;
  final Color accent;
  final String description;
  final String caseSize;
  final String movement;
  final String waterResistance;
  final String strap;
}
