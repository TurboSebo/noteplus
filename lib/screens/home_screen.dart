import 'package:flutter/material.dart';
import 'package:noteplus/widgets/notebook_tile.dart';
import 'package:provider/provider.dart';
import '../models/notebook.dart';
import '../providers/notebooks_model.dart';

const List<Color> kNotebookColors = [
  Color(0xFF81D4FA), // błękitny
  Color(0xFF2196F3), // niebieski
  Color(0xFFB2FF59), // jasnozielony
  Color(0xFF9E9E9E), // szary
  Color(0xFFFFA726), // pomarańczowy
  Color(0xFF4CAF50), // zielony
  Color(0xFF424242), // ciemnoszary
  Color(0xFF9C27B0), // purpurowy
];

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
              onTap: () {
                // Otwieramy ekran z notatkami, przekazując notebook.id jako argument
                print('Otwieram notatnik ${notebook.title}');
                Navigator.pushNamed(context, '/notes', arguments: notebook.id);
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
          final controller = TextEditingController();
          Color? selectedColor = kNotebookColors[0]; // Domyślny kolor notatnika

          String? newTitle;
          // Wyświetlamy okno dialogowe z polem tekstowym do wpisania nazwy notatnika
          
          final title = await showDialog<String>(
            context: context,
            builder: (ctx){
              return StatefulBuilder(builder: (ctx, setState){
                return AlertDialog(
                  title: const Text('Dodaj nowy notatnik'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Tytuł notatnika',
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      // Wyświetlamy kolory do wyboru
                      Wrap(
                        spacing: 8.0,
                        children: kNotebookColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color; // Ustawiamy wybrany kolor
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: color,
                              radius: 20,
                              child: selectedColor == color
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx), // Zamykamy okno dialogowe
                      child: const Text('Anuluj'),
                    ),
                    TextButton(
                      onPressed: () {
                        newTitle = controller.text.trim(); // Pobieramy tytuł z pola tekstowego
                        Navigator.pop(ctx, newTitle); // Zamykamy okno dialogowe i zwracamy tytuł
                      },
                      child: const Text('Dodaj'),
                    ),
                  ],
                ); // Zamknięcie AlertDialog
              }); // Zamknięcie StatefulBuilder
            }, // Zamknięcie builder w showDialog
          ); // Zamknięcie showDialog

          // Jeśli użytkownik wpisał poprawną nazwę, dodajemy notatnik do modelu
          if (title != null && title.isNotEmpty) {
            notebooksModel.addNotebook(title.trim(), selectedColor!);
          }
        }, // Zamknięcie onPressed FloatingActionButton
        child: const Icon(Icons.add),
      ), 
    );
  } // Zamknięcie build
} // Zamknięcie HomeScreen