import 'package:flutter/material.dart';
import 'screens/terceros_screen.dart';

void main() {
  runApp(const FoodChainApp());
}

class FoodChainApp extends StatelessWidget {
  const FoodChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodChain Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Aquí le decimos que la pantalla de inicio es la de Terceros
      home: TercerosScreen(), 
    );
  }
}
