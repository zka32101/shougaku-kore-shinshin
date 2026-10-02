import 'package:audioplayers/audioplayers.dart';

/// ノート名 → assets/taiku/audio/piano/ 内のファイル名
const noteAssetNames = {
  'C': 'C4', 'C#': 'Cs4', 'D': 'D4', 'D#': 'Ds4', 'E': 'E4',
  'F': 'F4', 'F#': 'Fs4', 'G': 'G4', 'G#': 'Gs4', 'A': 'A4', 'A#': 'As4', 'B': 'B4',
};

/// 和音（同時押下）に対応するため複数プレイヤーをラウンドロビンで使う
class PianoPlayer {
  PianoPlayer({int poolSize = 6})
      : _pool = List.generate(poolSize, (_) {
          final player = AudioPlayer();
          player.setReleaseMode(ReleaseMode.stop);
          return player;
        });

  final List<AudioPlayer> _pool;
  int _index = 0;

  Future<void> playTone(String note) async {
    final assetName = noteAssetNames[note];
    if (assetName == null) return;
    final player = _pool[_index];
    _index = (_index + 1) % _pool.length;
    try {
      await player.stop();
      await player.play(AssetSource('taiku/audio/piano/$assetName.wav'));
    } catch (_) {
      // 再生失敗時も演奏体験自体は継続させる
    }
  }

  void dispose() {
    for (final player in _pool) {
      player.dispose();
    }
  }
}
