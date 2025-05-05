import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notebooks_model.dart';
import 'routes.dart';

void main(){
  runApp(
  ChangeNotifierProvider(
    create: (context) => NotebooksModel(),
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

