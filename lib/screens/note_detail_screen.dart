import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_model.dart';
import '../models/note.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


/// Ekran pokazujący szczegóły pojedynczej notatki
class NoteDetailScreen extends StatefulWidget {
  final String noteId; // ID notatki do wyświetlenia
  final String notebookId;
  const NoteDetailScreen({super.key, required this.noteId, required this.notebookId});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late NotesModel _notesModel; // Model notatek
  late Note _note; // Obiekt notatki
  late TextEditingController _controller; // Kontroler tekstu do edytowania treści notatki

  @override
  void initState() {
    super.initState();
    _notesModel = Provider.of<NotesModel>(context, listen: false); // Pobierz model notatek
    _note = _notesModel.notes.firstWhere((note) => note.id == widget.noteId); // Znajdź notatkę po ID
    _controller = TextEditingController(text: _note.content); // Ustaw kontroler tekstu na treść notatki

  }
  @override
  void dispose() {
    _controller.dispose(); // Zwolnij zasoby kontrolera
    super.dispose();
  }

  @override
  void _saveNote() {
    _note.content = _controller.text; // Zaktualizuj treść notatki
    _note.save(); // Zapisz zmiany w bazie danych
    Navigator.pop(context); // Zamknij ekran szczegółów notatki
  }

 @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notesModel,
      child: WillPopScope(
        // Wywołaj _saveNote() przy próbie wyjścia z ekranu
        onWillPop: () async {
          _saveNote();
          return true; // Zezwól na zamknięcie ekranu
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edytuj notatkę'),
            // ...inne akcje...
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // wyrównanie do lewej
              children: [
                // Pogrubiony tytuł notatki na górze
                Text(
                  _note.title,
                  style: const TextStyle(
                    fontSize: 24,               // większa czcionka
                    fontWeight: FontWeight.bold // pogrubienie
                  ),
                ),
                const SizedBox(height: 16),    // odstęp pod tytułem
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Wpisz treść notatki',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // tu w przyszłości przycisk do dodawania zdjęć
              ],
            ),
          ),
        ),
      ),
    );
  }
}

