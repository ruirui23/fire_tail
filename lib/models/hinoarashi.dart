//ヒノアラシの性格・属性・選択された情報のプログラム
class Hinorashi {
  final int id;
  final String imageAsset;
  const Hinorashi(this.id, this.imageAsset);
  static const options = [
    Hinorashi(0, 'assets/images/hinoarashi1.jpg'),
    Hinorashi(1, 'assets/images/hinoarashi2.jpg'),
    Hinorashi(2, 'assets/images/tyebu.png'),
  ];
}