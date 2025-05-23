import 'package:hive/hive.dart'; 
import 'package:flutter/material.dart';               // Flutterowy zestaw widgetów i narzędzi UI
import 'package:provider/provider.dart';              // Provider – zarządzanie stanem
import '../models/notebook.dart';
import '../models/note.dart';                         // Model Note (pojedyncza notatka)
import '../providers/notebooks_model.dart';
import '../providers/notes_model.dart';               // NotesModel – logika dodawania/usuwania notatek
import 'note_detail_screen.dart';
import 'voice_note_screen.dart';            // dodaj import
import 'package:just_audio/just_audio.dart';


class NotesScreen extends StatelessWidget {
  final String notebookId;                            // ID notatnika, dla którego pokazujemy notatki

  const NotesScreen({Key? key, required this.notebookId}) : super(key: key);

  /// Zwraca wpisany tytuł notatki (lub null, jeśli anulowano).
  Future<String?> _showAddDialog(BuildContext ctx) {
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
  Widget build(BuildContext context) {
    // Tworzymy provider stanu NotesModel tylko dla tego ekranu
    return ChangeNotifierProvider<NotesModel>(
      create: (_) => NotesModel(
        notebookId: notebookId,                      // Przekazujemy ID notatnika
        notesBox: Hive.box<Note>('notes'),           // Otwieramy już zainicjalizowane pudełko Hive
      ),
      builder: (context, child) {
        // Od tej pory w drzewie widgetów poniżej możemy pobierać NotesModel
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notatki'),            // Tytuł paska aplikacji
          ),
          body: Consumer<NotesModel>(
            builder: (ctx, notesModel, _) {
              final notes = notesModel.notes;         // Pobieramy listę notatek z modelu
              if (notes.isEmpty) {
                // Gdy brak notatek – pokazujemy komunikat
                return const Center(child: Text('Brak notatek'));
              }
              // Wyświetlamy listę notatek rozdzieloną liniami
              return ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: notes.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, idx) {
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
                        } else {
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
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
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
  heroTag: 'voiceNote',
  onPressed: () {
    final notesModel = context.read<NotesModel>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChangeNotifierProvider.value(
          value: notesModel,
          child: VoiceNoteScreen(notebookId: notebookId),
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
