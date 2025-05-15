import 'package:flutter/material.dart';
import '../models/notebook.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class NotebooksModel extends ChangeNotifier { ///NotebooksModel zarządza kolekcją notatników i synchronizuje je z lokalną bazą Hive.

  late final Box<Notebook> _notebooksBox;   // Pudełko Hive przechowujące obiekty Notebook.
  
  NotebooksModel() {   // Konstruktor inicjalizuje pudełko Hive i ładuje istniejące notatniki.
    _notebooksBox = Hive.box<Notebook>('notebooks');    //  zwraca otwarte pudełko o nazwie 'notebooks'.
    print('Loaded notebooks: ${_notebooksBox.values}'); //wyświetlenie załadowanych notatników w konsoli.
  }

    List<Notebook> get notebooks => _notebooksBox.values.toList();   // Zwraca listę notatników jako niemodyfikowalną listę.

  void addNotebook(String title, Color color) {
    try {   // Walidacja: tytuł nie może być pusty ani za długi.
      if (title.isEmpty) {   
        throw Exception('Title cannot be empty');
      }
      if (title.length > 20) {
        throw Exception('Title cannot be longer than 20 characters');
      }
    } catch (e) {
      print('Error: $e');  // W razie błędu wyświetlamy go w konsoli i przerywamy operację.
      return;
    }
    final nb = Notebook.create(title, color);     // Tworzymy nowy obiekt Notebook z unikalnym ID i zadanym kolorem.
    _notebooksBox.put(nb.id, nb);     // Zapisujemy obiekt w pudełku Hive pod kluczem równym jego ID.
    notifyListeners();  /* notifyListeners() informuje wszystkie widżety nasłuchujące o zmianie stanu. 
    Dzięki temu widżety mogą się zaktualizować i odzwierciedlić zmiany w interfejsie użytkownika.  
    notifyListeners() jest wywoływane po każdej zmianie w modelu, aby zaktualizować widżety. */
  }
    
  void removeNotebook(String id) { // Metoda do usuwania notatnika na podstawie jego ID.
    try {
      if (id.isEmpty) {
        throw Exception('ID cannot be empty');
      }
    } catch (e) {
      print('Error: $e');
      return;
    }
    _notebooksBox.delete(id);
    notifyListeners(); // Powiadamiamy nasłuchujące widgety o zmianie danych.
  }
}