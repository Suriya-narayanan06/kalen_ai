import 'package:flutter/material.dart';

class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
