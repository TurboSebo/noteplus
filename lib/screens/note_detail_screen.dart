import 'package:flutter/material.dart';

class NoteDetailScreen extends StatelessWidget {
  final String noteId;  // ID notatki do wyświetlenia/edycji
  final String notebookId; // ID notatnika
  const NoteDetailScreen({Key? key, required this.noteId, required this.notebookId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note Details"),
      ),
      body: const Center(
        child: Text(
          "Placeholder content for Note Detail Screen",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}