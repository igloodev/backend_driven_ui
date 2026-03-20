import 'package:flutter/material.dart';
import 'examples/whatsapp_clone_full.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backend-Driven UI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Use onGenerateRoute for backend-driven navigation
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
