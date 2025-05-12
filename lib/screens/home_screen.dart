import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fire Tail')),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () => context.go('/choose'),   // ← 起（Choose）へ遷移
          child: const Text('START'),
        ),
      ),
    );
  }
}
