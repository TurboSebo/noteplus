import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:hive/hive.dart';

import '../models/note.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId; // ID notatki do wyświetlenia/edycji
  final String notebookId; // ID notatnika
  const NoteDetailScreen(
      {Key? key, required this.noteId, required this.notebookId})
      : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen>
    with WidgetsBindingObserver {
  late quill.QuillController _controller;
  late Note _note;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final box = Hive.box<Note>('notes');
    _note = box.values.firstWhere((n) => n.id == widget.noteId);
    final docJson = jsonDecode(_note.docJson);
    final document = quill.Document.fromJson(docJson);
    _controller = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _persistNote();
    }
  }

  @override
  void dispose() {
    _persistNote();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _persistNote() {
    final json = jsonEncode(_controller.document.toDelta().toJson());
    _note.docJson = json;
    _note.save();
  }

  void _saveNote() {
    _persistNote();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          // pasek narzędzi edytora
          quill.QuillSimpleToolbar(
            controller: _controller,
            config: const quill.QuillSimpleToolbarConfig(),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: quill.QuillEditor.basic(
                controller: _controller,
                config: const quill.QuillEditorConfig(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}