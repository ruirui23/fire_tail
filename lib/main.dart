//アプリの主となる。runApp() を呼び出してアプリを起動
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/result.dart';
import 'router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Result(),
      child: const HinorashiApp(),
    ),
  );
}

class HinorashiApp extends StatelessWidget {
  const HinorashiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'FireTail ',
        theme: ThemeData(
          colorSchemeSeed: Colors.orange,
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      );
}