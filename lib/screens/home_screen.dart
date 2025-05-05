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
          print('Okno dialogowe o dodaniu notatnika');
          // Pobieramy model wcześniej (zanim wejdziemy w async)
          final notebooksModel = context.read<NotebooksModel>();

          String? newTitle;
          final title = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Dodaj nowy notatnik'),
              content: TextField(
                decoration: const InputDecoration(hintText: 'Nazwa notatnika'),
                onChanged: (value) => newTitle = value,
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Anuluj'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, newTitle),
                  child: const Text('Dodaj'),
                ),
              ],
            ),
          );

          if (title != null && title.isNotEmpty) {
            notebooksModel.addNotebook(title.trim());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}