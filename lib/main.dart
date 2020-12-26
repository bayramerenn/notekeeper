import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/todo_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [
        const Locale('tr'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Todo list',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      home: TodoListScreen(),
    );
  }
}
