//ヒノアラシの性格・属性・選択された情報のプログラム
class Hinorashi {
  final int id;
  final String imageAsset;
  final String assetPath;   // ← ここを追加
  const Hinorashi(this.id, this.imageAsset, this.assetPath);
  static const options = [
    Hinorashi(0, 'assets/images/red.png', 'assets/images/red.png'),
    Hinorashi(1, 'assets/images/blue.png', 'assets/images/blue.png'),
    Hinorashi(2, 'assets/images/purple.png', 'assets/images/purple.png'),
  ];
}