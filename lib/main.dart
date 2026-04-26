import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://vqhsrrlofnyccjxkgmmn.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxaHNycmxvZm55Y2NqeGtnbW1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NzA1MzcsImV4cCI6MjA5MjA0NjUzN30.4OQ_8ZybM6DcwaTd3jMHH5BXv5hbwFtLEESBbFOQ7ag',
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
    rethrow;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoring Stock Tyre',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HomePage(),
    );
  }
}