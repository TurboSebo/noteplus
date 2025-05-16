import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // Importujemy pakiet uuid do generowania unikatowych identyfikatorów

part 'note.g.dart'; // Poprawne użycie pojedynczych cudzysłowów w poleceniu part

@HiveType(typeId: 1) // Klasa reprezentująca notatkę
class Note extends HiveObject {
  @HiveField(0) // Unikatowy identyfikator notatki
  String id;

  @HiveField(1) // Identyfikator notatnika, do którego należy notatka
  String notebookId;

  @HiveField(2) // Treść notatki
  String content;

  @HiveField(3) // Data utworzenia notatki
  DateTime createdAt;

  Note({
    required this.id,
    required this.notebookId,
    required this.content,
    required this.createdAt,
  });

  // Metoda fabryczna do tworzenia obiektu Note z unikatowym ID.
  // Dodaliśmy parametr notebookId, aby przypisać notatkę do odpowiedniego notatnika.
  factory Note.create(String notebookId, String content) {
    final now = DateTime.now();
    return Note(
      id: const Uuid().v4(), // Generujemy unikatowy identyfikator
      notebookId: notebookId, // Przypisujemy identyfikator notatnika
      content: content,
      createdAt: now,
    );
  }
}