import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  NotificationModel({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}
