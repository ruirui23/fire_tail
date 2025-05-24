import '../models/game_mode.dart';

/// シークレットのヒノアラシ画像を返す
String secretHinorashiAsset(GameMode mode) =>
    mode == GameMode.hard
        ? 'assets/images/purple.png'   // ハード
        : 'assets/images/green.png'; // ノーマル
