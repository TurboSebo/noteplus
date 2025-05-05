import 'package:flutter/material.dart';

// Importujemy klasę Notebook, żeby móc korzystać z jej właściwości.
import '../../models/notebook.dart';

// NotebookTile dziedziczy po StatelessWidget - nie posiada stanu i nie zmienia wyglądu wewnętrznie.
class NotebookTile extends StatelessWidget {
  final Notebook notebook;   // Przechowuje dane pojedynczego notatnika.
  final VoidCallback onTap; // Funkcja wywoływana po krótkim wciśnięciu.
  final VoidCallback onLongPress; // Funkcja wywoływana po dłuższym przytrzymaniu.

  // Konstruktor przyjmujący obowiązkowe parametry i przekazujący je dalej do klasy bazowej.
  const NotebookTile({
    Key? key,
    required this.notebook,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) { 
    return ListTile( // ListTile to gotowy widget do wyświetlania tytułu, podtytułu i obsługi kliknięć.
      title: Text(notebook.title), // Główny tytuł notatnika. Używamy notebook.name, żeby wyświetlić nazwę notatnika.
      trailing: Icon(Icons.chevron_right), // Ikona strzałki wskazująca, że można kliknąć.
      onTap: onTap,// Obsługa kliknięcia.
      onLongPress: onLongPress,      // Obsługa dłuższego przytrzymania.

    );
  }
}