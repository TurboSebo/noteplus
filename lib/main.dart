import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notebooks_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/notebook.dart';
import 'routes.dart';
import 'models/note.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized(); // Umożliwia korzystanie z widgetów przed uruchomieniem aplikacji.
  await Hive.initFlutter(); // Inicjalizuje Hive z obsługą Fluttera.
  Hive.registerAdapter(NotebookAdapter()); // Rejestruje adapter dla klasy Notebook, aby Hive mógł zrozumieć, jak przechowywać i odczytywać obiekty tej klasy.
  await Hive.openBox<Notebook>('notebooks'); // Otwiera pudełko (box) o nazwie 'notebooks', które będzie przechowywać obiekty Notebook. 
  
  // Zarejestruj adapter dla Note, jeśli jeszcze tego nie zrobiłeś:
  Hive.registerAdapter(NoteAdapter());
  // Otwórz pudełko 'notes':
  await Hive.openBox<Note>('notes');

  runApp(
  ChangeNotifierProvider(
    create: (_) => NotebooksModel(),
    child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotePlus',
      onGenerateRoute: generateRoute,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      

    );
  }
}

