import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class Notebook {
  final String id;
  final String title;
  final Color color;

  Notebook({
    required this.id,
    required this.title,
    required this.color,
  });

  // Metoda fabryczna do tworzenia obiektu Notebook z unikatowym ID.
  factory Notebook.create(String title, Color color) {
    return Notebook(
      id: const Uuid().v4(),
      title: title,
      color: color,
    );
  }
}