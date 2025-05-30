import 'package:hive/hive.dart'; 
import 'package:flutter/material.dart';               // Flutterowy zestaw widgetów UI
import 'package:provider/provider.dart';              // Provider – zarządzanie stanem
import '../models/notebook.dart';                     // Model notatnika (Hive Type)
import '../models/note.dart';                         // Model notatki (Hive Type)
import '../providers/notebooks_model.dart';           
import '../providers/notes_model.dart';               // NotesModel – logika dodawania/usuwania notatek
import 'note_detail_screen.dart';                     // Ekran szczegółów notatki
import 'voice_note_screen.dart';                      // Ekran tworzenia notatki głosowej
import 'package:just_audio/just_audio.dart';          // Pakiet do odtwarzania audio



class NotesScreen extends StatelessWidget { // Ekran z listą notatek w danym notatniku
  final String notebookId;                            // ID notatnika, dla którego pokazujemy notatki

  const NotesScreen({Key? key, required this.notebookId}) : super(key: key);  // Konstruktor wymagający przekazania notebookId

  /// Zwraca wpisany tytuł notatki (lub null, jeśli anulowano).
  Future<String?> _showAddDialog(BuildContext ctx) { // Pokazuje dialog do wpisania tytułu nowej notatki tekstowej
    final controller = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (dCtx) {
        return AlertDialog(
          title: const Text('Dodaj nową notatkę'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Tytuł notatki',
              hintText: 'Wpisz tytuł notatki',
            ),
            autofocus: true, // od razu focus na pole tekstowe
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx), // anuluj
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dCtx, controller.text.trim()), 
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {  // Tworzy lokalny Providera NotesModel z dostępem do Hive.box('notes')
    return ChangeNotifierProvider<NotesModel>(
      create: (_) => NotesModel(
        notebookId: notebookId,                      // Przekazujemy ID notatnika
        notesBox: Hive.box<Note>('notes'),           // Otwieramy już zainicjalizowane pudełko Hive
      ),
      builder: (context, child) { // Budujemy UI ekranu notatek 
        return Scaffold( 
          appBar: AppBar(
            title: const Text('Notatki'),             // Nagłówek ekranu
          ),
          body: Consumer<NotesModel>(
            builder: (ctx, notesModel, _) {
              final notes = notesModel.notes;         // Pobieramy listę notatek z modelu
              if (notes.isEmpty) { // Gdy brak notatek – pokazuje komunikat
                return const Center(child: Text('Brak notatek'));
              }
              // Wyświetlamy listę notatek rozdzieloną liniami
              return ListView.separated( // ListView z separatorami
                padding: const EdgeInsets.all(8.0), // Marginesy wokół listy
                itemCount: notes.length,
                separatorBuilder: (_, __) => const Divider(), // Separator między notatkami
                itemBuilder: (_, idx) { // Buduje pojedynczy element listy
                  final note = notes[idx];
                  return Dismissible(
                    key: ValueKey(note.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      notesModel.deleteNote(note);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notatka usunięta')),
                      );
                    },
                    child: ListTile(
                      leading: Icon(
                        note.audioPath != null ? Icons.mic : Icons.description,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${note.createdAt}\n${note.audioPath != null ? "Ścieżka: ${note.audioPath}" : ""}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      isThreeLine: note.audioPath != null,
                      onTap: () async {
                        if (note.audioPath != null) {
                          // Odtwarzanie notatki głosowej
                          final player = AudioPlayer();
                          try {
                            await player.setFilePath(note.audioPath!);
                            player.play();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Odtwarzanie notatki głosowej'))
                            );
                            // Automatyczne zamknięcie playera po zakończeniu
                            player.playerStateStream.listen((state) {
                              if (state.processingState == ProcessingState.completed) {
                                player.dispose();
                              }
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Błąd odtwarzania: $e'))
                            );
                            player.dispose();
                          }
                        } else {  // Przechodzimy do ekranu szczegółów notatki tekstowej
                          final notesModel = context.read<NotesModel>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: notesModel,
                                child: NoteDetailScreen(
                                  noteId: note.id,
                                  notebookId: notebookId,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
          // Przyciski dodawania nowej notatki (tekstowej i głosowej)
          floatingActionButton: Column( // Kolumna z przyciskami
            mainAxisSize: MainAxisSize.min, // Minimalna wysokość kolumny
            children: [
              FloatingActionButton(
                heroTag: 'textNote',
                onPressed: () async {
                  // Dodawanie notatki tekstowej
                  final title = await _showAddDialog(context);
                  if (title != null && title.isNotEmpty) {
                    context.read<NotesModel>().addNote(title);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notatka dodana')),
                    );
                  }
                },
                tooltip: 'Nowa notatka',
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
  heroTag: 'voiceNote', // Unikalny tag dla przycisku notatki głosowej
  onPressed: () { // Dodawanie notatki głosowej
    final notesModel = context.read<NotesModel>();
    Navigator.of(context).push(
      MaterialPageRoute( 
        builder: (ctx) => ChangeNotifierProvider.value( // Przekazuje NotesModel do VoiceNoteScreen
          value: notesModel, // Używa istniejącego NotesModel
          child: VoiceNoteScreen(notebookId: notebookId), // Ekran do nagrywania notatki głosowej
        ),
      ),
    );
  },
  tooltip: 'Nowa notatka głosowa',
  child: const Icon(Icons.mic),
),

            ],
          ),
        );
      },
    );
  }
}
