import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:hive/hive.dart';

import '../models/note.dart';

class NoteDetailScreen extends StatefulWidget { //Tworzy ekran szczegółów notatki stateful widget, ponieważ będziemy edytować notatkę i potrzebujemy stanu do przechowywania kontrolera Quill oraz obiektu notatki
  final String noteId; // ID notatki do wyświetlenia/edycji
  final String notebookId; // ID notatnika
  const NoteDetailScreen(
      {Key? key, required this.noteId, required this.notebookId})
      : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> // Stan dla ekranu szczegółów notatki
    with WidgetsBindingObserver {   // Implementacja WidgetsBindingObserver pozwala na reagowanie na zmiany cyklu życia aplikacji Dzięki temu możemy zapisać notatkę, gdy aplikacja jest w tle lub nieaktywna
  late quill.QuillController _controller; // Kontroler Quill do edycji notatki
  late Note _note; // Obiekt notatki, który będzie edytowany

  @override
  void initState() { // Metoda wywoływana przy inicjalizacji widgetu Inicjalizuje stan i kontroler Quill
    super.initState(); // Wywołanie metody initState z klasy nadrzędnej jest to wymagane, aby poprawnie zainicjalizować stan widgetu
    WidgetsBinding.instance.addObserver(this); // Dodaje obserwatora cyklu życia aplikacji, aby móc reagować na zmiany stanu aplikacji (np. przejście do tła)
    final box = Hive.box<Note>('notes'); // Otwiera pudełko Hive z notatkami
    _note = box.values.firstWhere((n) => n.id == widget.noteId); // Pobiera notatkę o podanym ID z pudełka Hive
    final docJson = jsonDecode(_note.docJson); // Dekoduje JSON z pola docJson notatki, który zawiera strukturę dokumentu Quill
    final document = quill.Document.fromJson(docJson);
    _controller = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { /* Metoda wywoływana przy zmianie stanu cyklu życia aplikacji
     Jeśli aplikacja jest w tle lub nieaktywna, zapisujemy notatkę
     To pozwala na zapisanie zmian, gdy użytkownik opuszcza aplikację */
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _persistNote();
    }
  }

  @override
  void dispose() { // Metoda wywoływana przy usuwaniu widgetu Zapisujemy notatkę przed usunięciem widgetu
    _persistNote();
    WidgetsBinding.instance.removeObserver(this); // Usuwa obserwatora cyklu życia aplikacji, aby uniknąć wycieków pamięci
    super.dispose();
  }

  void _persistNote() { // Metoda do zapisywania notatki w bazie Hive Konwertuje dokument Quill na JSON i zapisuje w polu docJson notatki
    final json = jsonEncode(_controller.document.toDelta().toJson()); //Konwertuje dokument Quill na Delta, a następnie na JSON, ponieważ Hive przechowuje dane w formacie JSON
    _note.docJson = json;
    _note.save();
  }

  void _saveNote() { // Metoda wywoływana przy kliknięciu przycisku zapisu
    _persistNote();
    Navigator.of(context).pop(); // Zamykamy ekran notatki po zapisaniu
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
          quill.QuillSimpleToolbar( // Pasek narzędzi Quill do formatowania tekstu
            controller: _controller,
            config: const quill.QuillSimpleToolbarConfig( //  Konfiguracja paska narzędzi
              showAlignmentButtons: true,
              showBackgroundColorButton: false,
              showBoldButton: true,
              showInlineCode: true,
              showLink: false,
              showColorButton: true,
              showHeaderStyle: true,
            ),
          ),
          Expanded( // Rozszerza kontener, aby zajął całą dostępną przestrzeń
            child: Container(  // Kontener dla edytora Quill
              padding: const EdgeInsets.all(8.0),
              child: quill.QuillEditor.basic( // Edytor Quill do edycji notatki
                controller: _controller, // Przekazuje kontroler Quill
                config: const quill.QuillEditorConfig(), // Konfiguracja edytora
              ),
            ),
          ),
        ],
      ),
    );
  }
}