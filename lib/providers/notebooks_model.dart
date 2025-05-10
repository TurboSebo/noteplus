import 'package:flutter/material.dart';
import '../models/notebook.dart';
import 'package:flutter/foundation.dart'; // Import podstawowych narzędzi Fluttera

// Klasa NotebooksModel zarządza listą notatników. Dziedziczy po ChangeNotifier, co umożliwia informowanie widżetów o zmianach w stanie.
class NotebooksModel extends ChangeNotifier {
  final List<Notebook> _notebooks = [];   // Prywatna lista notatników. Nazwa zaczynająca się od "_" oznacza, że zmienna jest prywatna.
  
  NotebooksModel() {
    print('NotebooksModel: _notebooks: $_notebooks'); // Debugowanie - wyświetlenie zawartości listy notatników w konsoli.
  }
  // Getter, który zwraca niezmienną listę notatników. Dzięki temu nie można zmienić listy bezpośrednio spoza tej klasy.
  List<Notebook> get notebooks => List.unmodifiable(_notebooks);

  // Metoda dodaje nowy notatnik do listy. title - tytuł notatnika, który chcemy dodać.
  // Po dodaniu wywoływana jest metoda notifyListeners(), która informuje widżety o aktualizacji.
  void addNotebook(String title, Color color) {   // Metoda dodaje nowy notatnik do listy. title - tytuł notatnika, który chcemy dodać.
    try {
      if (title.isEmpty) {   // Sprawdzamy, czy tytuł nie jest pusty. Jeśli tak, rzucamy wyjątek.
        throw Exception('Title cannot be empty');
      }
      if (title.length > 20) {   // Sprawdzamy, czy tytuł nie jest za długi. Jeśli tak, rzucamy wyjątek.
        throw Exception('Title cannot be longer than 20 characters');
      }
    } catch (e) {
      print('Error: $e');   // W przypadku błędu wyświetlamy go w konsoli.
      return;   // Zatrzymujemy dalsze wykonywanie metody, aby nie dodawać notatnika z błędnym tytułem.
    }
    final notebook = Notebook.create(title, color);     // Tworzymy nowy notatnik przy pomocy metody fabrycznej Notebook.create. Przekazujemy tytuł jako argument, a metoda generuje unikalny identyfikator.
    _notebooks.add(notebook);     // Dodajemy nowy notatnik do prywatnej listy.
    notifyListeners(); // Powiadamiamy wszystkie widżety nasłuchujące zmiany o zaktualizowaniu listy.
  }
    
  void removeNotebook(String id) {   // Metoda usuwa notatnik z listy. id - unikalny identyfikator notatnika, który ma zostać usunięty. Po usunięciu również informujemy widżety o zmianie stanu.
    try {
      if (id.isEmpty) {   // Sprawdzamy, czy id nie jest puste. Jeśli tak, rzucamy wyjątek.
        throw Exception('ID cannot be empty');
      }
    } catch (e) {
      print('Error: $e');   
      return;  
    }
    _notebooks.removeWhere((notebook) => notebook.id == id);     // Usuwamy notatnik, którego id pasuje do podanego argumentu.
    notifyListeners();     /* notifyListeners() informuje wszystkie widżety nasłuchujące o zmianie stanu. 
    Dzięki temu widżety mogą się zaktualizować i odzwierciedlić zmiany w interfejsie użytkownika.  
    notifyListeners() jest wywoływane po każdej zmianie w modelu, aby zaktualizować widżety. */

  }
}
