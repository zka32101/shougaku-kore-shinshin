/// フレームワーク §1: 層3 - 学習内容リテラシー
enum ContentLiteracyType {
  /// 基礎リテラシー: 読む・数える・理解する
  fundamental,

  /// 生活リテラシー: 日常応用・判断・選択
  practical,

  /// 批判的リテラシー: 評価・批評・創造
  critical,
}

extension ContentLiteracyTypeExt on ContentLiteracyType {
  String get label {
    switch (this) {
      case ContentLiteracyType.fundamental: return '基礎リテラシー';
      case ContentLiteracyType.practical: return '生活リテラシー';
      case ContentLiteracyType.critical: return '批判的リテラシー';
    }
  }

  String get description {
    switch (this) {
      case ContentLiteracyType.fundamental: return '読む・数える・理解する';
      case ContentLiteracyType.practical: return '日常応用・判断・選択';
      case ContentLiteracyType.critical: return '評価・批評・創造';
    }
  }
}

/// フレームワーク §5: 各教科の段階（1-12）
/// 体育（taiku）が 35 段階を使うため、literacy_core 本来の 12 段階から拡張。
/// 1〜12 の並びと意味は変えていない。
enum LiteracyStage {
  stage1, stage2, stage3, stage4, stage5, stage6,
  stage7, stage8, stage9, stage10, stage11, stage12,
  stage13, stage14, stage15, stage16, stage17, stage18,
  stage19, stage20, stage21, stage22, stage23, stage24,
  stage25, stage26, stage27, stage28, stage29, stage30,
  stage31, stage32, stage33, stage34, stage35,
}

extension LiteracyStageExt on LiteracyStage {
  int get number => index + 1;

  /// 段階→学年グループのマッピング（6段階ずつ: 低→中→高）
  ContentLiteracyType get contentType {
    if (number <= 4) return ContentLiteracyType.fundamental;
    if (number <= 8) return ContentLiteracyType.practical;
    return ContentLiteracyType.critical;
  }
}
