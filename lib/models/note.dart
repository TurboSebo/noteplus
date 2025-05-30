import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // Importujemy pakiet uuid do generowania unikatowych identyfikatorów
import 'dart:convert'; // Importujemy bibliotekę do kodowania i dekodowaniu JSON
import 'package:quill_delta/quill_delta.dart'; // import klasy Delta do inicjalizacji docJson

part 'note.g.dart'; // Poprawne użycie pojedynczych cudzysłowów w poleceniu part

@HiveType(typeId: 1) // Klasa reprezentująca notatkę
class Note extends HiveObject {
  @HiveField(0) // Unikatowy identyfikator notatki
  String id;

  @HiveField(1) // Identyfikator notatnika, do którego należy notatka
  String notebookId;

  @HiveField(2) // Tytuł notatki
  String title;

@HiveField(3)
String docJson;  // Quill JSON: zapisuje strukturę dokumentu
  
  @HiveField(4) // Data utworzenia notatki
  DateTime createdAt;

@HiveField(5) 
String? audioPath;  // ścieżka do pliku nagrania, null jeśli brak

  Note({ // Konstruktor klasy Note
    required this.id,
    required this.notebookId,
    required this.title,
    required this.docJson,
    required this.createdAt,
    this.audioPath,
  });

  // Metoda fabryczna do tworzenia obiektu Note z unikatowym ID.
  // Dodaliśmy parametr notebookId, aby przypisać notatkę do odpowiedniego notatnika.
factory Note.create(String notebookId, String title) {
  final now = DateTime.now();
  // początkowy Delta: tytuł i pusty paragraf
  final delta = Delta()
    ..insert('$title\n', {'header': 1})
    ..insert('\n');
  return Note(
    id: const Uuid().v4(),
    notebookId: notebookId,
    title: title,
    docJson: jsonEncode(delta.toJson()),
    createdAt: now,
  );
}
  // Metoda do konwersji obiektu Note na mapę (przydatne do serializacji)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notebookId': notebookId,
      'title': title,
      'docJson': docJson,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Metoda do tworzenia obiektu Note z mapy (przydatne do deserializacji)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      notebookId: map['notebookId'],
      title: map['title'],
      docJson: map['docJson'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}