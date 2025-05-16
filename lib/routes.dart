import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/note_detail_screen.dart';

/* Funkcja generateRoute służy do generowania tras (nawigacji) w aplikacji.
MaterialApp korzysta z tej funkcji, aby wiedzieć, jaki ekran wyświetlić na podstawie nazwy trasy. */
RouteFactory generateRoute = (settings) {
  switch (settings.name) { // settings.name zawiera nazwę trasy, którą chcemy wyświetlić. Używamy instrukcji switch, aby obsłużyć różne ścieżki.
    case '/':   // Gdy nazwa trasy to '/' (domyślna, główna strona), zwracamy MaterialPageRoute, która buduje ekran HomeScreen.
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case '/notes':
      final notebookId = settings.arguments as String; // Dla trasy '/notes' oczekujemy, że przekazany zostanie argument - identyfikator notatnika. rzutujemy argument na typ String.  
      return MaterialPageRoute( // Zwracamy MaterialPageRoute, która buduje ekran NotesScreen, przekazując notebookId.
        builder: (context) => NotesScreen(notebookId: notebookId),
      );
    case '/note':
      // Dla trasy '/note' oczekujemy przekazania obu parametrów: noteId i notebookId
      final args = settings.arguments as Map<String, String>;
      final noteId = args['noteId']!;
      final notebookId = args['notebookId']!;
      return MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          noteId: noteId,
          notebookId: notebookId,
        ),
      );
    default: // Jeśli trasa nie jest obsługiwana, zwracamy null, co powoduje wyświetlenie domyślnego ekranu błędu przez Fluttera.
      return null;
  }
};
