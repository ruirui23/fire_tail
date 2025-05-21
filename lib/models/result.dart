//クイズの正解数や障害物をよけた回数など、プレイ結果を保存するプログラム。
import 'package:flutter/foundation.dart';
class Result extends ChangeNotifier {
  String playerName = '主';   
  int chosenId = 0;      // 選んだヒノアラシ
  int quizCorrect = 0;   // クイズ正解数
  int collisions  = 0; 

 void setPlayerName(String name) {
    playerName = name.trim().isEmpty ? '主' : name;
    notifyListeners();
  }
  void setChosen(int id) { chosenId = id; notifyListeners(); }
  void setCollisions(int n) {  collisions = n; notifyListeners(); }
  void setQuizCorrect(int n) { quizCorrect = n; notifyListeners(); }
}