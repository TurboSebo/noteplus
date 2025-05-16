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

  void addNote(String content) {
    final note = Note.create(_notebookId, content);
    _notesBox.add(note);
    notifyListeners();
  }

  void deleteNote(Note note) {
    note.delete();
    notifyListeners();
  }
}