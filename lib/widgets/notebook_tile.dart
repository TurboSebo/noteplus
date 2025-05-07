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
    super.key,
    required this.notebook,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.blueGrey;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, color: Colors.white), // Ikona notatnika
            const SizedBox(height: 8.0), // Odstęp między ikoną a tytułem
            Text(
              notebook.title,
              style: const TextStyle(color: Colors.white, fontSize: 18.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
}