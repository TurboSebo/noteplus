import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/notebook.dart';

class NotesModel extends ChangeNotifier {
  final String _notebookId;
  final Box<Note> _notesBox;

  NotesModel({
    required String notebookId,
    required Box<Note> notesBox,
  }) : _notebookId = notebookId, 
       _notesBox = notesBox;

  List<Note> get notes => _notesBox.values // Pobiera wszystkie notatki z pudełka Hive
      .where((note) => note.notebookId == _notebookId) // Filtruje notatki, aby zwrócić tylko te z odpowiednim notebookId
      .toList() // Konwertuje Iterable do List
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sortuje notatki malejąco według daty utworzenia

  void addNote(String title) {
    final note = Note.create(_notebookId, title);
    _notesBox.add(note);
    notifyListeners();
  }

  void deleteNote(Note note) {
    note.delete();
    notifyListeners();
  }
  void updateNote(Note note) {
    note.save();
    notifyListeners();
  }
  void addVoiceNote(String filePath, String title) {   // Dodaje notatkę głosową z podaną ścieżką i tytułem
    final note = Note.create(_notebookId, title); // Inicjalizuje nową notatkę z unikatowym ID i tytułem
    note.audioPath = filePath; // Ustawia ścieżkę audio na podaną
    _notesBox.add(note); // Dodaje notatkę do pudełka Hive
    notifyListeners();
  }
  void deleteVoiceNote(Note note) {
    note.audioPath = null; // Usuwa ścieżkę audio, ale nie usuwa samej notatki
    note.save();
    notifyListeners();
  }

}