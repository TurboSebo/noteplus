import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'notebook.g.dart';

@HiveType(typeId: 0)/// Klasa reprezentująca notatnik.
class Notebook extends HiveObject {
  @HiveField(0) /// Unikatowy identyfikator notatnika.
  String id;
  @HiveField(1) /// Tytuł notatnika.
  String title;
  @HiveField(2) /// Kolor notatnika.
  int colorValue;

  Notebook({
    required this.id,
    required this.title,
    required this.colorValue,
  });

  Color get color => Color(colorValue); /// Zwraca kolor notatnika jako obiekt Color.
  // Metoda fabryczna do tworzenia obiektu Notebook z unikatowym ID.
  factory Notebook.create(String title, Color color) {
    return Notebook(
      id: const Uuid().v4(),
      title: title,
      colorValue: color.value,
    );
  }
}