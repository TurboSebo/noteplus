import 'dart:async';                           // Potrzebne do Future i Timerów
import 'package:flutter/material.dart';       // Podstawowe widgety Fluttera
import 'package:record/record.dart';          // Pakiet do nagrywania dźwięku
import 'package:path_provider/path_provider.dart'; // Dostęp do katalogów w urządzeniu
import 'package:permission_handler/permission_handler.dart'; // Obsługa uprawnień
import 'package:provider/provider.dart';      // Provider – zarządzanie stanem
import '../providers/notes_model.dart';       // Model dodający notatki do Hive

// StatefulWidget, bo stan nagrywania (_isRecording) się zmienia
class VoiceNoteScreen extends StatefulWidget {
  final String notebookId;  // ID notatnika, do którego dodane zostanie nagranie
  const VoiceNoteScreen({Key? key, required this.notebookId}) : super(key: key);

  @override
  _VoiceNoteScreenState createState() => _VoiceNoteScreenState(); // Stan dla VoiceNoteScreen
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> { // Stan dla VoiceNoteScreen
  // Inicjalizuje obiekt AudioRecorder do nagrywania dźwięku 
  final AudioRecorder _recorder = AudioRecorder(); // Obiekt do sterowania nagrywaniem
  bool _isRecording = false; // Flaga czy jest nagrywanie
  String? _filePath; // Ścieżka do pliku z nagraniem

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

// Prosi użytkownika o zgodę na użycie mikrofonu
  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) { // Jeśli brak zgody, pokazywany jest komunikat i przerywamy
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak dostępu do mikrofonu')),
      );
      return false;
    }
    return true;
  }

  Future<void> _toggleRecording() async { // Przełącza stan nagrywania: start/stop
    if (_isRecording) { // Jeśli nagrywanie jest aktywne, zatrzymujemy je
      final path = await _recorder.stop();  // Zatrzymuje nagrywanie i pobiera ścieżkę do pliku
      setState(() => _isRecording = false); 
      if (path != null) { 
        final titleController = TextEditingController();
        final title = await showDialog<String>( // Pokazuje dialog z polem tekstowym do wpisania tytułu
          context: context, // Kontekst do wyświetlenia dialogu
          builder: (ctx) => AlertDialog( // Buduje dialog z polem tekstowym
            title: const Text('Podaj tytuł notatki głosowej'),
            content: TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Tytuł...'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
              TextButton(onPressed: () => Navigator.pop(ctx, titleController.text.trim()), child: const Text('OK')),
            ],
          ),
        );
        if (title != null && title.isNotEmpty) { // Jeśli tytuł nie jest pusty, dodajemy notatkę
          context.read<NotesModel>().addVoiceNote(path, title); // Dodaje notatkę głosową do modelu
        }
      }
      Navigator.of(context).pop(); // Zamykamy ekran nagrywania
    } else {
      if (await _ensureMicPermission()) { // Sprawdza zgodę na mikrofon
        final dir = await getApplicationDocumentsDirectory(); // Pobiera katalog dokumentów aplikacji
        final filePath ='${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a'; // Generuje unikalną nazwę pliku na podstawie czasu 
        await _recorder.start( // Rozpoczyna nagrywanie
          const RecordConfig(encoder: AudioEncoder.aacLc), // Ustawienia nagrywania: kodek AAC LC
          path: filePath, // Ścieżka do pliku nagrania
        );
        setState(() {
          _isRecording = true;
          _filePath = filePath;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) { // Buduje UI ekranu nagrywania notatki głosowej
    return Scaffold(
      appBar: AppBar( // Pasek aplikacji z tytułem
        title: const Text('Nowa notatka głosowa'), // Tytuł ekranu
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 64,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              color: Theme.of(context).primaryColor,
              onPressed: _toggleRecording,
            ),
            const SizedBox(height: 12),
            Text(
              _isRecording ? 'Nagrywanie...' : 'Dotknij, aby nagrać',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
