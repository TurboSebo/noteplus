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

  List<Note> get notes => _notesBox.values
      .where((note) => note.notebookId == _notebookId)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
  /// Dodaje notatkę głosową z podaną ścieżką i tytułem
  void addVoiceNote(String filePath, String title) {
    final note = Note.create(_notebookId, title);
    note.audioPath = filePath;
    _notesBox.add(note);
    notifyListeners();
  }
  void deleteVoiceNote(Note note) {
    note.audioPath = null; // lub inna logika usuwania
    note.save();
    notifyListeners();
  }

}