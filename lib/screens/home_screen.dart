import 'package:flutter/material.dart';
import 'package:noteplus/widgets/notebook_tile.dart';
import 'package:provider/provider.dart';
import '../models/notebook.dart';
import '../providers/notebooks_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Używamy Provider, aby pobrać obiekt NotebooksModel, który zawiera listę notatników
    final model = context.watch<NotebooksModel>();
    return Scaffold(
      appBar: AppBar(  // Pasek aplikacji z tytułem
        title: const Text('Twoje notesy'),
      ),
    
      drawer: const Drawer(   // Panel boczny (drawer) – miejsce na menu
        child: SafeArea(child: Text('Tu będzie menu')),
      ),
     
      body: SafeArea(  // Główna zawartość ekranu – wyświetlamy notatniki w formie siatki
        child: GridView.builder(
          padding: const EdgeInsets.all(8.0), // Odstęp wokół całej siatki
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Ustawia liczbę kolumn w siatce
            crossAxisSpacing: 8.0, // Odstęp między kolumnami
            mainAxisSpacing: 8.0, // Odstęp między wierszami
            childAspectRatio: 0.8, // Proporcje (szerokość : wysokość) kafelka
          ),
          itemCount: model.notebooks.length, // Liczba notatników do wyświetlenia
          itemBuilder: (context, index) {
            final notebook = model.notebooks[index];  // Pobieramy pojedynczy notatnik z listy na danej pozycji
            return NotebookTile(
              notebook: notebook, 
              onTap: () { // Callback wywoływany przy krótkim dotknięciu kafelka
                print('Otwieram notatnik ${notebook.title}');
              },
              onLongPress: () {   // Callback wywoływany przy długim przytrzymaniu kafelka
                showDialog(  // Wyświetlamy okno dialogowe potwierdzające usunięcie notatnika
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Usuwanie notatnika'),
                    content: Text(
                        'Notatnik ${notebook.title} zostanie usunięty. Czy chcesz kontynuować?'),
                    actions: [
                      // Przycisk "Anuluj" – zamyka okno dialogowe
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Anuluj'),
                      ),
                      // Przycisk "Usuń" – usuwa notatnik i zamyka dialog
                      TextButton(
                        onPressed: () {
                          print('Usuwam notatnik ${notebook.title}');
                          model.removeNotebook(notebook.id); // Usuwamy notatnik, przekazując jego unikalny identyfikator
                          Navigator.pop(context); // Zamykamy okno dialogowe
                          ScaffoldMessenger.of(context).showSnackBar(  // Wyświetlamy krótką wiadomość o usunięciu
                            SnackBar(
                              content: Text(
                                  'Notatnik ${notebook.title} został usunięty'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('Usuń'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      // Przycisk zmiennopływowy dodający nowy notatnik
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('Okno dialogowe o dodaniu notatnika');
          // Pobieramy instancję NotebooksModel, aby dodać nowy notatnik
          final notebooksModel = context.read<NotebooksModel>();

          String? newTitle;
          // Wyświetlamy okno dialogowe z polem tekstowym do wpisania nazwy notatnika
          final title = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Dodaj nowy notatnik'),
              content: TextField(
                decoration:
                    const InputDecoration(hintText: 'Nazwa notatnika'),
                // Aktualizujemy zmienną newTitle z bieżącą wartością wpisaną przez użytkownika
                onChanged: (value) => newTitle = value,
                // Umożliwiamy zatwierdzenie wpisanej nazwy przez przycisk Enter
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
              actions: [
                // Przycisk "Anuluj" – zamyka okno dialogowe bez dodawania notatnika
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Anuluj'),
                ),
                // Przycisk "Dodaj" – zamyka dialog i zwraca wpisaną nazwę
                TextButton(
                  onPressed: () => Navigator.pop(context, newTitle),
                  child: const Text('Dodaj'),
                ),
              ],
            ),
          );

          // Jeśli użytkownik wpisał poprawną nazwę, dodajemy notatnik do modelu
          if (title != null && title.isNotEmpty) {
            notebooksModel.addNotebook(title.trim());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}