//ヒノアラシの情報を表示するカードプログラム（選択画面などで使用）
import 'package:flutter/material.dart';
import '../models/hinoarashi.dart';
class HinorashiCard extends StatelessWidget {
  final Hinorashi hino;
  const HinorashiCard({required this.hino, super.key});
  @override
  Widget build(BuildContext context) => Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(hino.imageAsset, fit: BoxFit.contain),
        ),
      );
}