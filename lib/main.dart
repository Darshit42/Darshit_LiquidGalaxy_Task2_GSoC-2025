import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/homepage.dart';
import 'pages/settingspage.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LG App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.blue[50],
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.blue[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.blue[900]),
          prefixIconColor: Colors.blue[600],
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Colors.blue[900]),
          bodyMedium: TextStyle(color: Colors.blue[700]),
        ),
        iconTheme: IconThemeData(color: Colors.blue[600]),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[100],
          foregroundColor: Colors.blue[900],
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.blue[900]),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
