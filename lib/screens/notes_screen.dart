import 'package:flutter/material.dart';               // Flutterowy zestaw widgetów i narzędzi UI
import 'package:provider/provider.dart';              // Provider – zarządzanie stanem
import '../models/notebook.dart';
import '../models/note.dart';                         // Model Note (pojedyncza notatka)
import '../providers/notebooks_model.dart';
import '../providers/notes_model.dart';               // NotesModel – logika dodawania/usuwania notatek
import 'package:hive/hive.dart';                      // Hive – lokalna baza danych
import 'package:hive_flutter/hive_flutter.dart';      // Rozszerzenie Hive dla Fluttera
import 'note_detail_screen.dart';

class NotesScreen extends StatelessWidget {
  final String notebookId;                            // ID notatnika, dla którego pokazujemy notatki

  const NotesScreen({Key? key, required this.notebookId}) : super(key: key);

  /// Pokazuje dialog z polem tekstowym i zwraca wpisaną wartość (lub null, jeśli anulowano)
  Future<String?> _showAddDialog(BuildContext ctx) {
    final controller = TextEditingController();       // Kontroler do odczytu wpisu w TextField
    return showDialog<String>(
      context: ctx,
      builder: (dCtx) {
        return AlertDialog(
          title: const Text('Dodaj notatkę'),         // Nagłówek okna
          content: TextField(
            controller: controller,                   // Podpinamy kontroler
            decoration: const InputDecoration(
              hintText: 'Wpisz treść notatki',        // Podpowiedź w polu
            ),
            autofocus: true,                          // Od razu otwiera klawiaturę
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),   // Anuluj: zamykamy dialog bez zwracania wartości
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dCtx, controller.text.trim()),  
                                                       // Zatwierdź: zwracamy wpisaną treść
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
                  // Każdy element można przesunąć w bok, by go usunąć
                  return Dismissible(
                    key: ValueKey(note.id),           // Unikalny klucz
                    background: Container(             // Czerwone tło z ikoną „usuń”
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      notesModel.deleteNote(note);     // Usuwamy notatkę z modelu
                      // Pokazujemy krótką informację o usunięciu
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notatka usunięta')),
                      );
                    },
                    child: ListTile(
                      title: Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        note.createdAt.toString(),   // Opcjonalnie pokazujemy czas utworzenia
                      ),
                      onTap: () {
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
                        },
                    ),
                  );
                },
              );
            },
          ),
          // Przyciski dodawania nowej notatki
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Otwieramy dialog do wpisania treści i czekamy na wynik
              final content = await _showAddDialog(context);
              if (content != null && content.isNotEmpty) {
                // Dodajemy notatkę przez model stanu
                context.read<NotesModel>().addNote(content);
                // Informujemy użytkownika, że dodano notatkę
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notatka dodana')),
                );
              }
            },
            child: const Icon(Icons.add),       // Ikona plusika
          ),
        );
      },
    );
  }
}
