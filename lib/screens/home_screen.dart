import 'package:flutter/material.dart';
import 'package:noteplus/widgets/notebook_tile.dart';
import 'package:provider/provider.dart';
import '../models/notebook.dart';
import '../providers/notebooks_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pozwalamy używać NotebooksModel
    final model = context.watch<NotebooksModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje notesy'),
      ),
      drawer: const Drawer(
        child: SafeArea(child: Text('Tu będzie menu')),
      ),
      // Lista o długości liczby notatników w modelu
      body: ListView.builder(
        itemCount: model.notebooks.length,
        itemBuilder: (context, index) {
          final notebook = model.notebooks[index];
          // Upewniamy się, że przekazujemy poprawne parametry do NotebookTile
          return NotebookTile(
            notebook: notebook,
            onTap: () {
              print('Otwieram notatnik ${notebook.title}');
              // ewentualnie: Navigator.pushNamed(context, '/notebook', arguments: notebook);
            },
            onLongPress: () {
              print('Usuwam notatnik ${notebook.title}');
              // ewentualnie: model.deleteNotebook(notebook);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('Dodaję nowy notatnik');
          String? newTitle; // Zmienna do przechowywania wpisanego tytułu
          final title = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Dodaj nowy notatnik'),
              content: TextField(
                decoration: const InputDecoration(hintText: 'Nazwa notatnika'),
                // Gdy użytkownik wpisuje tekst, zapisujemy go do newTitle
                onChanged: (value) => newTitle = value,
                // Wciśnięcie Entera skończy wprowadzanie tytułu
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Anuluj'),
                ),
                // Tutaj finalizujemy wprowadzony tekst przyciskiem "Dodaj"
                TextButton(
                  onPressed: () => Navigator.pop(context, newTitle),
                  child: const Text('Dodaj'),
                ),
              ],
            ),
          );
          // Sprawdzamy, czy tytuł nie jest pusty
          if (title != null && title.isNotEmpty) {
            // Tutaj można np. dodać notatnik do modelu:
            // model.addNotebook(Notebook(title: title, ...));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}