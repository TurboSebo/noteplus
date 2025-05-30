import 'package:flutter/material.dart';                           // Podstawowe widgety Fluttera
import 'package:provider/provider.dart';                          // Provider – zarządzanie stanem aplikacji
import 'providers/notebooks_model.dart';                          // Model dla listy notatników
import 'package:hive_flutter/hive_flutter.dart';                  // Hive z integracją Fluttera
import 'models/notebook.dart';                                    // Definicja klasy Notebook (Hive Type)
import 'routes.dart';                                             // Funkcja onGenerateRoute dla nawigacji
import 'models/note.dart';                                        // Definicja klasy Note (Hive Type)
import 'models/block.dart';                                       // Definicja bloków tekstowych Quill
import 'package:flutter_quill/flutter_quill.dart';                // Edytor Quill
import 'package:flutter_localizations/flutter_localizations.dart'; // Delegaci lokalizacji i tłumaczeń


// Główna funkcja aplikacji Flutter. Tu inicjalizowany jest Hive i uruchamiamy korzeń widgetów.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();   // Zapewnia dostęp do metod Fluttera przed uruchomieniem UI

  // Inicjalizuje Hive i dodaje adaptory dla zapisów w lokalnej bazie
  await Hive.initFlutter();
  Hive.registerAdapter(NotebookAdapter());  // Adapter dla notatników
  Hive.registerAdapter(NoteAdapter());      // Adapter dla notatek
  Hive.registerAdapter(BlockTypeAdapter()); // Adapter dla typu bloku Quill
  Hive.registerAdapter(BlockAdapter());     // Adapter dla instancji bloków

  // Otwiera “pudełka” Hive do przechowywania obiektów
  await Hive.openBox<Notebook>('notebooks');
  await Hive.openBox<Note>('notes');

  runApp(   // Uruchamiamy aplikację, dostarczając rootowi stan NotebooksModel
    ChangeNotifierProvider( // ChangeNotifierProvider – pozwala na dostęp do modelu w całej aplikacji
      create: (_) => NotebooksModel(),     // Tworzymy instancję modelu notatników
      child: const MainApp(),               // Nasz główny widget aplikacji
    ),
  );
}

// Główny widget aplikacji – konfiguruje MaterialApp
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Delegaci tłumaczeń dla widgetów Material, Cupertino i Quill
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      // Lista wspieranych języków
      supportedLocales: const [
        Locale('en'),
      ],
      title: 'NotePlus',                      // Tytuł aplikacji (np. w przełączniku zadań)
      onGenerateRoute: generateRoute,         // Funkcja zwracająca trasy nawigacyjne
      theme: ThemeData(
        primarySwatch: Colors.blue,           // Główny kolor aplikacji
      ),
      // Możesz też ustawić home: lub initialRoute:, jeśli nie używasz onGenerateRoute
    );
  }
}

