//ヒノアラシの性格やスタイルを選択する(起)画面
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/hinoarashi.dart';
import '../models/result.dart';
import '../widgets/hinoarashi_card.dart';

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ヒノアラシを選ぼう')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: Hinorashi.options.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            // スコア管理などで Provider を使いたいならここは残して OK
            context.read<Result>().setChosen(i);

            // ★ 選択 ID を extra に乗せて /game へ遷移
            context.go('/game', extra: i);
          },
          child: HinorashiCard(hino: Hinorashi.options[i]),
        ),
      ),
    );
  }
}