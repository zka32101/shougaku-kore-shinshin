import 'package:flutter/material.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../data/taiku_questions.dart';
import '../providers/taiku_providers.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

// ─── ステージ導入テキスト（低学年・高学年） ───

const _stageIntros = <int, (String, String)>{
  1: (
    'スポーツには きまり（ルール）があります。ルールをしれば もっとたのしく あそべます！ しんぱん（ルールをみはるひと）のしごとも しろう。',
    'スポーツはルールで成り立っています。試合の進め方、反則の種類、審判の役割など、正しいルールを理解することでより深くスポーツを楽しめます。',
  ),
  2: (
    'うごくことは からだにとってもいいことです！ うんどうのまえの「ウォーミングアップ」と、あとの「クールダウン」がなぜだいじかも まなびましょう。',
    '体を動かすことは健康維持に欠かせません。ウォームアップで怪我を予防し、クールダウンで疲労回復を早める。基本的な体の動かし方の科学を学びます。',
  ),
  3: (
    'たべものが からだをつくります！ スポーツのまえとあとに なにを たべると いいかな？ えいようとスポーツのかんけいを しらべよう。',
    'パフォーマンスを高める食事の組み立て方を学びます。炭水化物・タンパク質・脂質の役割と補給のタイミングを知って、体を上手にコントロールしましょう。',
  ),
  4: (
    'なかまといっしょにスポーツするときは チームワークがだいじ！ ポジションのやくわりや、さくせんのたて方を まなびましょう。',
    'チームスポーツの醍醐味はチームワークとコミュニケーションにあります。ポジション・フォーメーション・サインプレーなど、組織的な連携の仕組みを理解します。',
  ),
  5: (
    'じしんや たいふう、こうずいのときは どうすれば いい？ じぶんのいのちをまもる「ぼうさい」のちしきを まなびましょう。',
    '自然災害の種類と正しい対応を学びます。ハザードマップで危険箇所を把握し、避難経路・非常用持ち出し品・自助・共助・公助の仕組みを理解します。',
  ),
  6: (
    'みずのそばではきけんがいっぱい！ おぼれている人をみたら どうすれば いい？ AEDのつかいかたも しろう。',
    '水難事故は毎年多くの命を奪います。浮いて待つ（ういてまつ）の方法、AEDの正しい使い方、心肺蘇生法（CPR）など、命を救う知識を身につけます。',
  ),
  7: (
    'やさい・たんぱくしつ・えいよう…バランスよく たべると からだがげんきになるよ！ さんだいえいようそのやくわりを まなびましょう。',
    '三大栄養素（炭水化物・タンパク質・脂質）と五大栄養素（＋ビタミン・ミネラル）の違い、食品群の組み合わせ、食育の意義を学びます。',
  ),
  8: (
    'アスリートは なにをたべているの？ きんにくがそだつしくみや、よるねることのだいじさを しらべよう！',
    '一流アスリートの食事管理と科学的なトレーニング方法を学びます。筋肉の成長・回復に必要な栄養補給のタイミング、超回復の仕組みを理解します。',
  ),
  9: (
    'スポーツにかんけいするしごとは たくさんあります！ せんしゅだけじゃない、いろんなしごとを しらべてみよう。',
    'スポーツ業界のキャリアは多岐にわたります。選手・指導者・審判・スポーツアナリスト・スポーツ医学・メディアなど、多様な職業を探索します。',
  ),
  10: (
    'かがくとスポーツってどんなかんけい？ センサーやAIが スポーツをかえています！ スポーツかがくのせかいを のぞいてみよう。',
    'スポーツ科学の最前線を学びます。運動生理学・バイオメカニクス・スポーツ心理学・GPSトラッキング・モーションキャプチャなどの技術が現代スポーツを支えています。',
  ),
  11: (
    'けんこうでいることとしごとはつながっています。ライフスキルをみにつけて、みらいにいかそう！',
    '生涯を通じた健康管理とキャリア設計の関係を学びます。ライフスキル・レジリエンス・デュアルキャリアの考え方を学び、スポーツを通じた人間形成を理解します。',
  ),
  12: (
    'せかいのスポーツとにほんのスポーツ。オリンピックやパラリンピックのれきし、スポーツで せかいとつながろう！',
    'オリンピック・パラリンピックの歴史と精神、スポーツ外交、SDGsとスポーツの関係、AIが変えるスポーツの未来について学びます。',
  ),
  13: (
    'ねることは からだと あたまを なおしてくれます！ まいにち たくさん ねることで げんきに そだちます。',
    '睡眠と成長の科学を学びます。成長ホルモン・メラトニン・体内時計・睡眠負債など、睡眠の質が学力・体力・メンタルに直結する仕組みを理解します。',
  ),
  14: (
    'こころのけんこうも からだのけんこうと おなじくらいだいじ！ ストレスのたいしょほうを みにつけよう。',
    '心の健康とストレスマネジメントを学びます。セロトニン・マインドフルネス・アンガーマネジメント・レジリエンスなど、感情を上手に扱うスキルを習得します。',
  ),
  15: (
    'てをあらうことや きそくただしいせいかつで びょうきをふせごう！ ワクチンのしくみも まなびましょう。',
    '感染症・生活習慣病・衛生管理を学びます。ウイルスと細菌の違い、ワクチンの仕組み、むし歯・受動喫煙・薬物乱用防止など小学生に必須の保健知識を習得します。',
  ),
  16: (
    'ひや はさみ、でんき、くすり…いえのなかにもきけんがあります。きけんをしって、じぶんのからだをまもりましょう！',
    '家庭・外出先に潜む危険を理解します。火・刃物・電気・ガス・薬など身近な危険物の正しい扱い方、やけどの応急手当、交通安全、プライベートゾーンの保護など生活安全の基礎を習得します。',
  ),
  17: (
    'しらないひと、ネット、いじめ…まわりにはいろんなきけんがあります。「いかのおすし」をつかって、じぶんをまもろう！',
    '犯罪被害から身を守る知識を身につけます。不審者対応（いかのおすし）・SNS上の危険・性被害の対処・いじめの相談・防犯ブザーの使い方など、現代の子どもに必須の防犯スキルを習得します。',
  ),
  18: (
    'もしものとき、あわてないために。119番・AED・CPRのやりかたを まなんで、たいせつないのちをまもろう！',
    '緊急時に適切な行動を取れるよう学びます。119番・110番の使い方、AED操作・心肺蘇生法（CPR）・骨折・やけど・止血などの応急手当、地震・火事の避難行動、熱中症対応を習得します。',
  ),
  19: (
    'ちきゅうは わたしたちみんなのもの。プラごみをへらしたり、でんきをせつやくしたりして、みらいにつなごう！',
    '地球温暖化・SDGs・生物多様性・プラスチック問題・食品ロス・再生可能エネルギーなど、環境問題の原因と解決策を学びます。自分たちにできることを考え、持続可能な社会のために行動する力を育てます。',
  ),
  20: (
    'お金って なに？ どうすれば かしこく つかえる？ おこづかいをつかって、お金のきほんを まなぼう！',
    'お金の役割・稼ぎ方・使い方・貯め方・税金の仕組みを学びます。「必要なものとほしいもの」の違い、キャッシュレスの仕組み、複利の力など、将来に役立つ金融リテラシーの基礎を身につけます。',
  ),
  21: (
    'みんなちがって、みんないい。ひとのきもちをかんがえて、やさしいきもちで せかいをみてみよう！',
    '人権・差別・多様性・共感・道徳的判断力を学びます。いじめの本質・LGBTQ+・異文化理解・ボランティア精神・約束を守ることの意義など、社会を生きる上で最も大切な価値観を育てます。',
  ),
  22: (
    'リサイクルってなに？ SDGsってなに？ ちきゅうをまもるために、ぼくたちにできることをかんがえよう！',
    'リサイクル・分別・節電・フードロス・SDGsなど、環境を守るための実践的な行動を学びます。「もったいない」の精神から循環型社会まで、地球の未来を自分ごととして考える視点を育てます。',
  ),
  23: (
    'ちきゅうがあつくなっている！ おんだんかをとめるために、エネルギーのことをかんがえよう！',
    '地球温暖化のしくみ・再生可能エネルギー・カーボンニュートラル・パリ協定など、気候変動問題の本質と解決策を学びます。個人・企業・国際社会それぞれの役割を理解し、行動できる力を養います。',
  ),
  24: (
    'お金はどうやってふえる？ ぎんこう・とうし・けいざいのしくみをかんがえよう！',
    '銀行・利息・投資・インフレ・複利・為替など、経済の基本的な仕組みを学びます。お金を「使う」だけでなく「増やす・守る」視点を持ち、経済格差や社会的企業まで発展的な金融リテラシーを身につけます。',
  ),
  25: (
    'ぜいきんはなんのため？ ねんきんやしゃかいほけんのしくみをかんがえよう！',
    '税金の種類・社会保険・年金・国の借金・最低賃金・経済格差など、社会を支える仕組みを学びます。「自分が払う税金が何に使われるか」を理解し、社会の一員として主体的に関わる市民性を育てます。',
  ),
  26: (
    'すべての人がたいせつ。じんけん・たようせい・LGBTQについて、しっかりかんがえよう！',
    '人権・差別・多様性・ジェンダー・インクルーシブ教育・ヘイトスピーチ・難民など、現代社会の人権問題を学びます。アンコンシャス・バイアスに気づき、すべての人の尊厳を守る力を育てます。',
  ),
  27: (
    'せかいから せんそうをなくすには？ へいわについてふかくかんがえよう！',
    '平和主義・核兵器・国連・国際人道法・ジェノサイド・軍縮・構造的暴力・市民的不服従など、平和と安全保障の本質を学びます。歴史から学び、積極的に平和を構築する市民としての視点を養います。',
  ),
  28: (
    'いろをまぜると どうなる？ えをかくコツや びじゅつのせかいをしろう！',
    '色の三原色・混色・暖色と寒色・遠近法・コラージュ・版画などの図工の基礎技法を学びます。補色・彩度・抽象画と具象画の違いなど、美術鑑賞の深め方も理解します。',
  ),
  29: (
    'はさみやボンドをつかって、じぶんだけの さくひんをつくろう！',
    'はさみ・粘土・彫刻・設計図・シンメトリーなど工作の基礎を学びます。バウハウス・パブリックアート・著作権・インスタレーションなど現代アートと社会の接点も理解します。',
  ),
  30: (
    'ドレミをおぼえて うたったり がっきをひこう！おんがくのせかいへようこそ！',
    '音符・リズム・テンポ・強弱記号・音階・合唱・リコーダーなど音楽の基礎を学びます。和音・音楽の三要素・ベートーベン・転調・雅楽など音楽の深い世界も探求します。',
  ),
  31: (
    'バイオリン・トランペット・たいこ、いろんながっきをしろう！',
    'ピアノ・バイオリン・金管楽器・打楽器・和太鼓・オーケストラの配置など楽器の世界を学びます。長調と短調・ワールドミュージック・即興演奏・ジャズ・音楽著作権・交響曲の構造も理解します。',
  ),
  32: (
    'ほうちょうのもちかたや りょうりのじゅんびをおぼえよう！',
    '包丁の使い方・ご飯の炊き方・五大栄養素・食中毒予防・旬・一汁三菜・食品表示・フードロスなど食生活の知識を学びます。地産地消・食文化の継承など食と社会のつながりも理解します。',
  ),
  33: (
    'たまむすびやなみぬいをおぼえて、ソーイングにちょうせん！',
    '玉結び・なみ縫い・ボタン付け・洗濯表示・アイロンがけなど裁縫と被服の基礎を学びます。整理整頓・掃除・エコな生活・消費生活・家事分担・住まいの安全・ユニバーサルデザインも理解します。',
  ),
  34: (
    'コンピュータへのめいれい「プログラム」をつくってみよう！',
    'プログラム・順次・ループ・条件分岐・デバッグ・センサー・AIの仕組みなどプログラミングの基礎概念を学びます。プログラミング的思考・ビッグデータ・IoT・クラウド・変数など発展的な内容も理解します。',
  ),
  35: (
    'パスワードのまもりかた、ネットのあんぜんなつかいかたをしろう！',
    '個人情報の守り方・フィッシング詐欺・著作権・SNSの安全な使い方・情報モラル・デジタルデバイドなどデジタルリテラシーを学びます。個人情報保護法・マルウェア・AI倫理・デジタルウェルビーイングも理解します。',
  ),
};

// ─── ステージキーワード（各ステージの重要語句） ───

const _stageKeywords = <int, List<(String, String)>>{
  1: [
    ('フェアプレー', '正直にルールを守って正々堂々プレーすること'),
    ('審判（レフェリー）', 'ルールが守られているか確かめる役割の人'),
    ('オフサイド', 'サッカー・ラグビーなどで決められた反則のひとつ'),
    ('得点（スコア）', 'ルールに従って入れた点数の記録'),
    ('競技規則', '各スポーツの公式ルールをまとめた規則集'),
  ],
  2: [
    ('ウォームアップ', '運動前に体を温めて怪我を防ぐ準備運動'),
    ('クールダウン', '運動後に体を徐々に落ち着かせる整理運動'),
    ('有酸素運動', '酸素を使ってエネルギーを作る長時間の運動（ジョギング等）'),
    ('無酸素運動', '短時間に大きな力を出す運動（100m走・筋トレ等）'),
    ('体力', '日常生活・スポーツを行うための基礎的な身体能力'),
  ],
  3: [
    ('グリコーゲン', '筋肉や肝臓に蓄えられるエネルギー源（糖質から作られる）'),
    ('炭水化物（糖質）', '運動のメインエネルギー源となる栄養素'),
    ('タンパク質', '筋肉・血液・免疫の材料となる栄養素'),
    ('補給タイミング', '運動の前後に正しいタイミングで栄養を取ること'),
    ('カーボローディング', '試合前日に糖質を多めに摂るアスリートの食事法'),
  ],
  4: [
    ('フォーメーション', 'チームの選手の並び方・配置（陣形）'),
    ('ポジション', 'チーム内での各選手の役割・担当場所'),
    ('コミュニケーション', '仲間と声をかけ合い意思を伝えること'),
    ('連携プレー', '2人以上の選手が協力して行う作戦プレー'),
    ('チームワーク', 'チーム全員が同じ目標に向かって協力すること'),
  ],
  5: [
    ('ハザードマップ', '洪水・土砂災害などの危険区域を示した地図'),
    ('避難場所', '災害時に安全に逃げ込める公共の場所'),
    ('自助・共助・公助', '自分を守る・近所で助け合う・行政が助ける、の3段階'),
    ('非常用持ち出し袋', '避難時にすぐ持ち出せる防災グッズのセット'),
    ('シェイクアウト', '地震の際にその場で行う「ドロップ・カバー・ホールドオン」行動'),
  ],
  6: [
    ('AED', '心臓が止まった人に電気ショックを与えて救命する機器'),
    ('心肺蘇生法（CPR）', '心臓マッサージ（胸骨圧迫）と人工呼吸による応急手当'),
    ('ういてまつ', '溺れた時に背浮きで浮き続けて救助を待つ行動'),
    ('胸骨圧迫', '心臓の動きを助けるために胸を押し続ける救命処置'),
    ('回復体位', '意識はあるが呼吸が不安定な人を横向きに寝かせる姿勢'),
  ],
  7: [
    ('三大栄養素', '炭水化物・タンパク質・脂質の3つの主要栄養素'),
    ('ビタミン', '体の調子を整える微量栄養素（野菜・果物に多い）'),
    ('ミネラル', '骨・歯・血液の材料となる無機質（カルシウム・鉄等）'),
    ('食育', '食を通じて健康・文化・命を学ぶ教育の取り組み'),
    ('食品ロス', '食べられるのに捨てられてしまう食品のこと'),
  ],
  8: [
    ('超回復', 'トレーニング後の休養中に筋肉が以前より強くなる現象'),
    ('成長ホルモン', '睡眠中に多く分泌され、筋肉の成長・修復を促すホルモン'),
    ('プロテイン', 'タンパク質の英語。運動後の筋肉回復に重要な栄養素'),
    ('PFC バランス', 'タンパク質（P）・脂質（F）・炭水化物（C）の摂取比率'),
    ('水分補給', '運動中の脱水を防ぐために定期的に水・スポーツドリンクを飲むこと'),
  ],
  9: [
    ('デュアルキャリア', '競技と学業・仕事を両立する選手のキャリア設計'),
    ('スポーツアナリスト', 'データで試合・選手を分析する専門職'),
    ('アスレティックトレーナー', '選手の怪我予防・回復をサポートする専門家'),
    ('スポーツ栄養士', 'アスリートの食事計画・栄養管理を行う専門家'),
    ('スポーツ心理士', '選手のメンタル・集中力をサポートする心理の専門家'),
  ],
  10: [
    ('バイオメカニクス', '力学の視点から体の動きを科学的に分析する学問'),
    ('GPS トラッキング', '選手の走行距離・速度・位置をGPSで記録する技術'),
    ('モーションキャプチャ', '体の動きを3Dデータとして記録・分析する技術'),
    ('スポーツ心理学', 'メンタル・集中・やる気など心の側面からスポーツを研究する学問'),
    ('ゾーン（フロー）', '最高の集中状態で最高のパフォーマンスが発揮できる精神状態'),
  ],
  11: [
    ('ライフスキル', 'スポーツで身につく問題解決・目標設定・コミュニケーション能力'),
    ('レジリエンス', '失敗・困難から立ち直り、より強くなれる精神的回復力'),
    ('生涯スポーツ', '年齢を問わず生涯を通じてスポーツを楽しむ考え方'),
    ('健康寿命', '介護が必要なく健康に生活できる期間'),
    ('ウェルビーイング', '身体・精神・社会的に満たされた良い状態（幸福）'),
  ],
  12: [
    ('オリンピック精神', '「より速く・より高く・より強く・共に」という五輪の理念'),
    ('パラリンピック', '障がいのある選手が参加する世界最高峰のスポーツ大会'),
    ('スポーツ外交', 'スポーツを通じて国と国の友好・平和を促進する取り組み'),
    ('SDGs とスポーツ', '持続可能な開発目標とスポーツの役割（健康・平和・平等）'),
    ('スポーツ × AI', 'AIが戦術分析・審判補助・トレーニング支援に活用される未来'),
  ],
  13: [
    ('メラトニン', '暗くなると分泌される眠気を促すホルモン'),
    ('成長ホルモン', '深い睡眠中に分泌され身長・筋肉の成長を促すホルモン'),
    ('体内時計（概日リズム）', '約24時間周期で体の働きをコントロールする生体の仕組み'),
    ('睡眠負債', '毎日の睡眠不足が蓄積した状態。記憶力・免疫力・気分に悪影響'),
    ('ノンレム睡眠', '脳が深く休む段階の眠り。成長ホルモンが多く分泌される'),
  ],
  14: [
    ('ストレス', '心や体に負担・緊張をもたらす刺激や状態'),
    ('セロトニン', '「幸せホルモン」と呼ばれる神経伝達物質。日光・運動で増える'),
    ('マインドフルネス', '今この瞬間に意識を向けありのままを受け入れること'),
    ('レジリエンス', '失敗・困難から立ち直り強くなれる精神的な回復力'),
    ('アンガーマネジメント', '怒りの感情を認識し上手にコントロールする技術（6秒ルール）'),
  ],
  15: [
    ('感染経路', '病原体が人から人へ広がるルート（飛沫・接触・空気感染等）'),
    ('ワクチン（予防接種）', '弱めた病原体で免疫記憶を作り病気を予防する医療技術'),
    ('生活習慣病', '食事・運動・喫煙などの習慣が積み重なって発症する慢性疾患'),
    ('受動喫煙', 'タバコを吸わなくても周囲の煙を吸い込んでしまうこと'),
    ('薬物依存', '薬物を使い続けることで自分の意志でやめられなくなった状態'),
  ],
  16: [
    ('プライベートゾーン', '水着で隠れる体の部分。自分だけの大切な場所'),
    ('やけどの応急手当', '流水で10〜20分冷やすのが基本。バター・氷の直接当てはNG'),
    ('感電', '電気が体に流れることで起こる危険な事故'),
    ('ガス漏れ対応', 'まず換気・火花厳禁・元栓を閉める・屋外で119番'),
    ('子ども110番の家', '緊急時に助けを求められる地域の避難場所（緑プレートが目印）'),
  ],
  17: [
    ('いかのおすし', 'い=いかない・か=乗らない・の=大声・お=大きな声・す=すぐ逃げる・し=知らせる'),
    ('個人情報', '名前・住所・学校・電話番号・顔写真など本人が特定できる情報'),
    ('防犯ブザー', '85〜100デシベルの大音響で危険を周囲に知らせる携帯安全器具'),
    ('オンライン犯罪', 'SNS・ゲームを使った詐欺・脅し・個人情報窃取などの犯罪'),
    ('性被害', '体の大切な場所への不正な接触。あなたは悪くない。必ず大人に話す'),
  ],
  18: [
    ('AED', '心室細動（心臓の停止）に電気ショックを与え正常なリズムに戻す装置'),
    ('心肺蘇生法（CPR）', '胸骨圧迫と人工呼吸で心臓・肺の働きを代わりに行う救命処置'),
    ('止血法', '清潔な布で傷口を強く圧迫し続ける「直接圧迫止血」が基本'),
    ('おはしも', 'お=押さない・は=走らない・し=しゃべらない・も=戻らない（避難ルール）'),
    ('アナフィラキシー', '蜂刺されや食物アレルギーで起こる急激な全身アレルギー反応（要緊急処置）'),
  ],
  19: [
    ('温室効果ガス', 'CO2・メタンなど地球を温める毛布の役割を果たすガス'),
    ('SDGs', '2030年までに達成すべき17の持続可能な開発目標（国連採択2015年）'),
    ('再生可能エネルギー', '太陽光・風力・水力など自然界で繰り返し得られるクリーンエネルギー'),
    ('食品ロス', 'まだ食べられるのに捨てられる食べ物（日本で年間472万トン）'),
    ('カーボンニュートラル', 'CO2排出量と吸収量を差し引きゼロにすること（2050年目標）'),
  ],
  20: [
    ('複利', '利子にもさらに利子がつく「雪だるま式」にお金が増える仕組み'),
    ('消費税', '物を買ったりサービスを受けた時にかかる税金（現在10%、食料品は8%）'),
    ('キャッシュレス', '現金を使わずカード・スマホ・電子マネーで支払う決済方法'),
    ('ニーズとウォンツ', 'ニーズ=必要なもの、ウォンツ=欲しいもの。賢い買い物の判断基準'),
    ('家計', '一家のお金の収入・支出・貯蓄のバランスのこと'),
  ],
  21: [
    ('人権', 'すべての人が生まれながらに持つ尊厳ある生き方をする権利（普遍的・不可侵）'),
    ('多様性（ダイバーシティ）', '様々な個性・文化・考え方を認め尊重し合うこと'),
    ('共感（エンパシー）', '相手の立場に立ってその気持ちを理解しようとする能力'),
    ('公正・公平', '誰に対しても同じ基準で、えこひいきなく接すること'),
    ('LGBTQ+', '性別・恋愛感情の多様なあり方を持つ人たちの総称（人口の約8〜10%）'),
  ],
  22: [
    ('3R', 'リデュース（減らす）・リユース（再使用）・リサイクル（再資源化）の環境行動'),
    ('SDGs', '2030年までに達成すべき17の持続可能な開発目標（国連2015年採択）'),
    ('フードロス', 'まだ食べられるのに捨てられる食品（日本で年約472万トン）'),
    ('もったいない（MOTTAINAI）', '物を大切にする日本の精神・世界に広まった環境概念'),
    ('循環型社会', '廃棄物を資源として活用し、資源を循環させる持続可能な社会'),
  ],
  23: [
    ('地球温暖化', '温室効果ガス増加で地球の平均気温が上昇する現象（+1.1℃以上進行中）'),
    ('再生可能エネルギー', '太陽光・風力・水力など自然から繰り返し得られるクリーンエネルギー'),
    ('カーボンニュートラル', 'CO2排出量と吸収量がつり合い、実質排出量がゼロの状態'),
    ('パリ協定', '気温上昇を1.5℃以内に抑えることを目指す国際気候条約（2015年）'),
    ('マイクロプラスチック', '5mm以下の微細プラスチックで海洋汚染・生態系への脅威'),
  ],
  24: [
    ('複利', '利息にも利息がつく「雪だるま式」の資産増加の仕組み'),
    ('投資', '将来の利益を期待して株式・債券・不動産などにお金を使うこと'),
    ('インフレ', '物価全体が上昇しお金の価値が下がる現象'),
    ('分散投資', 'リスク分散のため複数の資産・地域・産業に投資すること'),
    ('フィンテック', 'Finance＋Technologyで金融サービスのデジタル革新の総称'),
  ],
  25: [
    ('消費税', '商品・サービスの消費にかかる税金（日本：10%、食料品8%）'),
    ('社会保険', '病気・老後・失業などに備えてみんなで支え合う保険制度'),
    ('GDP', '国内総生産：ある国で1年間に生み出された価値の合計（経済規模の指標）'),
    ('累進課税', '収入が多いほど高い税率が適用される格差是正の仕組み'),
    ('ESG投資', '環境・社会・ガバナンスを重視した持続可能な企業への投資'),
  ],
  26: [
    ('アンコンシャス・バイアス', '自分では気づいていない無意識の偏見・先入観'),
    ('ジェンダー', '社会・文化が作り出した性別役割・規範（生物学的性別とは異なる）'),
    ('インクルーシブ教育', '障がいの有無に関わらず全ての子どもが共に学ぶ教育'),
    ('ヘイトスピーチ', '人種・民族・性別等を理由に特定グループへの憎悪を煽る言動'),
    ('難民', '迫害・戦争・紛争を逃れた人（世界約1.1億人・難民条約で保護）'),
  ],
  27: [
    ('平和主義', '戦争放棄・戦力不保持を定めた日本国憲法9条の原則'),
    ('国際人道法', '戦争中でも傷病者・捕虜・民間人を保護するルール（ジュネーブ条約等）'),
    ('構造的暴力', '貧困・差別・不平等など社会構造が人々の可能性を奪う間接的な暴力'),
    ('市民的不服従', '不当な法律・政策に対して非暴力的手段で抵抗する行為'),
    ('人間の安全保障', '国家ではなく個々の人間の生命・生活・尊厳を守ることを目指す概念'),
  ],
  28: [
    ('三原色', '赤・青・黄の3色で、混ぜることで様々な色が作れる基本の色'),
    ('補色', '色相環で正反対の位置にある色（例：赤↔緑）で互いを引き立てる'),
    ('遠近法', '遠いものを小さく、近いものを大きく描いて奥行きを表現する技法'),
    ('印象派', '光と色彩の瞬間的な印象を重視したフランス発の19世紀絵画運動'),
    ('コラージュ', '紙・写真・布などを切り貼りして新しい作品を作るアート技法'),
  ],
  29: [
    ('彩度', '色の鮮やかさ・濃さの度合い（高い＝鮮やか、低い＝くすんでいる）'),
    ('シンメトリー', '左右・上下が鏡のように同じ形の対称性（安定した美しさを生む）'),
    ('バウハウス', '1919年ドイツで芸術と工業技術を統合した革新的デザイン学校'),
    ('パブリックアート', '駅・広場・公園など公共空間に設置されたアート作品'),
    ('インスタレーション', '空間全体を作品として観客が体験する現代アートの形式'),
  ],
  30: [
    ('音符', '音の長さを示す記号（四分音符＝1拍、二分音符＝2拍など）'),
    ('テンポ', '音楽の速さ（Andante：歩く速さ、Allegro：速く、Presto：とても速く）'),
    ('強弱記号', 'p（ピアノ：弱く）・f（フォルテ：強く）など音の強さを指示する記号'),
    ('合唱', '複数の人が声を合わせて歌うこと（二部・三部合唱などがある）'),
    ('雅楽', '奈良時代から伝わる日本の宮廷音楽・舞踊（ユネスコ無形文化遺産）'),
  ],
  31: [
    ('金管楽器', 'トランペット・ホルン・トロンボーンなど唇の振動で音を出す楽器'),
    ('打楽器', '太鼓・シンバル・マリンバなどたたいたり振ったりして音を出す楽器'),
    ('長調・短調', '長調（メジャー：明るい）・短調（マイナー：暗い）の音階の違い'),
    ('即興演奏', '楽譜なしでその場で自由に音楽を創り演奏すること（ジャズの基本）'),
    ('交響曲', 'オーケストラのための大規模な楽曲（通常4楽章で構成）'),
  ],
  32: [
    ('五大栄養素', '炭水化物・脂質・タンパク質・ビタミン・ミネラルの5種類の栄養素'),
    ('一汁三菜', 'ご飯＋汁物1品＋主菜1品＋副菜2品の和食の基本スタイル'),
    ('旬', '食材が最もよく育ちおいしくなる時期（栄養価が高く安く手に入る）'),
    ('フードロス', 'まだ食べられるのに捨てられる食品（日本では年間約522万トン）'),
    ('地産地消', '地元で生産された食材を地元で消費する環境・経済に良い取り組み'),
  ],
  33: [
    ('なみ縫い', '布に針を等間隔に交互に刺して進む最も基本的な手縫いの縫い方'),
    ('玉結び', '縫い始めに糸の端に作るコブ（縫っている間に糸が抜けるのを防ぐ）'),
    ('洗濯表示', '衣類の正しい洗い方・乾燥・アイロン方法を示す記号（JIS規格）'),
    ('消費生活', '商品を選び・買い・使う日常生活（必要性・品質・価格の判断が大切）'),
    ('ユニバーサルデザイン', '年齢・障がいに関わらず誰もが使いやすい設計の考え方'),
  ],
  34: [
    ('アルゴリズム', '問題を解くための手順・方法（料理のレシピも一種のアルゴリズム）'),
    ('条件分岐', '「もし〜なら〇〇する」という条件によって処理を変えるプログラム構造'),
    ('デバッグ', 'プログラムのエラー（バグ）を見つけて修正する作業'),
    ('IoT', 'あらゆる機器がインターネットでつながりデータをやりとりするしくみ'),
    ('AI（人工知能）', '大量のデータからパターンを学習して判断・予測するコンピュータ技術'),
  ],
  35: [
    ('個人情報', '特定の個人を識別できる情報（氏名・住所・電話番号・顔写真など）'),
    ('フィッシング詐欺', '本物そっくりの偽サイトで個人情報やお金をだまし取る詐欺'),
    ('情報モラル', 'ICTを正しく・安全・倫理的に使うための知識・態度・判断力'),
    ('デジタルデバイド', 'ICTにアクセスできる人とできない人の間に生まれる格差・不平等'),
    ('デジタルウェルビーイング', 'ICTが心身の健康・幸福に良い影響をもたらすよう意識的に使う考え方'),
  ],
};

// ─── ステージ学習・説明画面 ───

class StageLearnScreen extends ConsumerStatefulWidget {
  final int stageNum;
  final String emoji;
  final String title;
  final String theme;
  final Color color;

  const StageLearnScreen({
    super.key,
    required this.stageNum,
    required this.emoji,
    required this.title,
    required this.theme,
    required this.color,
  });

  @override
  ConsumerState<StageLearnScreen> createState() => _StageLearnScreenState();
}

class _StageLearnScreenState extends ConsumerState<StageLearnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grade = ref.watch(gradeLevelProvider);
    final isLow = grade == GradeLevel.low;
    final questions = getQuestionsForStage(widget.stageNum);
    final highlights = _pickHighlights(questions, 5);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: widget.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            UkalabEmoji(widget.emoji, size: 32),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Stage ${widget.stageNum}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FuriganaText(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isLow
                              ? '${questions.length}もんの かいせつが よめるよ'
                              : '全${questions.length}問の解説を読んで理解を深めよう',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
              tabs: [
                Tab(text: isLow ? 'ポイント' : 'まなびポイント'),
                Tab(text: isLow ? 'ぜんもん' : '全問解説'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ─── タブ1: まなびポイント（ハイライト5問）───
            _HighlightsTab(
              stageNum: widget.stageNum,
              highlights: highlights,
              color: widget.color,
              isLow: isLow,
              onStartQuiz: () => _startQuiz(context, ref),
            ),
            // ─── タブ2: 全問解説（全15問）───
            _AllQuestionsTab(
              questions: questions,
              color: widget.color,
              isLow: isLow,
              onStartQuiz: () => _startQuiz(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, WidgetRef ref) {
    ref.read(currentStageProvider.notifier).state = widget.stageNum;
    Navigator.of(context).pushNamed('/quiz');
  }

  List<TaikuQuestion> _pickHighlights(List<TaikuQuestion> all, int count) {
    if (all.length <= count) return all;
    final step = all.length / count;
    return List.generate(
      count,
      (i) => all[(i * step).round().clamp(0, all.length - 1)],
    );
  }
}

// ─── キーワード用語集 ───

class _KeywordsSection extends StatefulWidget {
  final int stageNum;
  final Color color;
  final bool isLow;
  const _KeywordsSection({
    required this.stageNum,
    required this.color,
    required this.isLow,
  });

  @override
  State<_KeywordsSection> createState() => _KeywordsSectionState();
}

class _KeywordsSectionState extends State<_KeywordsSection> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final keywords = _stageKeywords[widget.stageNum];
    if (keywords == null || keywords.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_stories_outlined, color: widget.color, size: 16),
            const SizedBox(width: 5),
            Text(
              widget.isLow ? 'じゅうような ことば' : 'キーワード用語集',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(keywords.length, (i) {
            final (term, def) = keywords[i];
            final isOpen = _expanded == i;
            return GestureDetector(
              onTap: () => setState(() => _expanded = isOpen ? null : i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isOpen
                      ? widget.color
                      : widget.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.color.withValues(alpha: isOpen ? 1 : 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FuriganaText(
                          '📌 $term',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isOpen
                                ? Colors.white
                                : widget.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isOpen
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 14,
                          color: isOpen
                              ? Colors.white
                              : widget.color,
                        ),
                      ],
                    ),
                    if (isOpen) ...[
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: FuriganaText(
                          def, glossary: true,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── ステージ導入カード ───

class _StageIntroCard extends StatelessWidget {
  final int stageNum;
  final Color color;
  final bool isLow;
  const _StageIntroCard({
    required this.stageNum,
    required this.color,
    required this.isLow,
  });

  @override
  Widget build(BuildContext context) {
    final intro = _stageIntros[stageNum];
    if (intro == null) return const SizedBox.shrink();
    final text = isLow ? intro.$1 : intro.$2;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.menu_book_rounded, color: color, size: 15),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FuriganaText(
              text,
              style: TextStyle(
                fontSize: isLow ? 13 : 12.5,
                color: Colors.grey.shade800,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── タブ1: まなびポイント ───

class _HighlightsTab extends StatelessWidget {
  final int stageNum;
  final List<TaikuQuestion> highlights;
  final Color color;
  final bool isLow;
  final VoidCallback onStartQuiz;

  const _HighlightsTab({
    required this.stageNum,
    required this.highlights,
    required this.color,
    required this.isLow,
    required this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                isLow ? 'まなびの ポイント！' : 'このステージのまなびポイント！',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isLow
                ? 'だいじな ${highlights.length}つを まとめたよ'
                : '特に重要な${highlights.length}つのポイントをまとめました',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          // ステージ導入テキスト
          _StageIntroCard(stageNum: stageNum, color: color, isLow: isLow),
          const SizedBox(height: 16),

          // キーワード用語集
          _KeywordsSection(stageNum: stageNum, color: color, isLow: isLow),
          const SizedBox(height: 16),

          // ポイントカード
          for (int i = 0; i < highlights.length; i++) ...[
            _PointCard(
              index: i,
              question: highlights[i],
              color: color,
              isLow: isLow,
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),

          // クイズCTA
          _QuizCTA(color: color, isLow: isLow, onTap: onStartQuiz),
          const SizedBox(height: 12),

          // 全問解説へのヒント
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.list_alt, size: 16, color: Colors.grey.shade500),
              label: Text(
                isLow ? 'ぜんもんの かいせつは「ぜんもん」タブ' : '全問の解説は「全問解説」タブで確認',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  final int index;
  final TaikuQuestion question;
  final Color color;
  final bool isLow;

  const _PointCard({
    required this.index,
    required this.question,
    required this.color,
    required this.isLow,
  });

  static const _nums = ['①', '②', '③', '④', '⑤'];

  @override
  Widget build(BuildContext context) {
    final num = index < _nums.length ? _nums[index] : '●';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // トピック（問題文の短縮版）
                FuriganaText(
                  question.questionText, glossary: true,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // 正解
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade600, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: FuriganaText(
                          question.choices[question.correctIndex],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 解説
                if (question.explanationDetail != null)
                  FuriganaText(
                    question.explanationDetail!, glossary: true,
                    style: TextStyle(
                      fontSize: isLow ? 12 : 12,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── タブ2: 全問解説 ───

class _AllQuestionsTab extends StatelessWidget {
  final List<TaikuQuestion> questions;
  final Color color;
  final bool isLow;
  final VoidCallback onStartQuiz;

  const _AllQuestionsTab({
    required this.questions,
    required this.color,
    required this.isLow,
    required this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books_outlined, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                isLow ? 'ぜんぶの もんだい かいせつ' : '全${questions.length}問の解説',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            isLow ? 'タップすると せつめいが ひらくよ！' : 'タップして解説を確認しよう！',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),

          for (int i = 0; i < questions.length; i++) ...[
            _ExpandableQuestionCard(
              index: i,
              question: questions[i],
              color: color,
              isLow: isLow,
            ),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 24),
          _QuizCTA(color: color, isLow: isLow, onTap: onStartQuiz),
        ],
      ),
    );
  }
}

class _ExpandableQuestionCard extends StatefulWidget {
  final int index;
  final TaikuQuestion question;
  final Color color;
  final bool isLow;

  const _ExpandableQuestionCard({
    required this.index,
    required this.question,
    required this.color,
    required this.isLow,
  });

  @override
  State<_ExpandableQuestionCard> createState() =>
      _ExpandableQuestionCardState();
}

class _ExpandableQuestionCardState extends State<_ExpandableQuestionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final q = widget.question;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded ? color : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー（タップ可能）
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Q${widget.index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FuriganaText(
                        q.questionText, glossary: true,
                        style: TextStyle(
                          fontSize: widget.isLow ? 12 : 12,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: _expanded ? null : 1,
                        overflow:
                            _expanded ? null : TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            // 展開コンテンツ
            if (_expanded) ...[
              Divider(height: 1, color: Colors.grey.shade200),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 正解表示
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.green.shade600, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isLow ? 'こたえ' : '正解',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                FuriganaText(
                                  q.choices[q.correctIndex],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 選択肢一覧
                    const SizedBox(height: 10),
                    Text(
                      widget.isLow ? 'せんたくし：' : '選択肢：',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (int ci = 0; ci < q.choices.length; ci++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Icon(
                              ci == q.correctIndex
                                  ? Icons.circle
                                  : Icons.radio_button_unchecked,
                              size: 10,
                              color: ci == q.correctIndex
                                  ? Colors.green.shade500
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: FuriganaText(
                                q.choices[ci],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ci == q.correctIndex
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                                  fontWeight: ci == q.correctIndex
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // 解説
                    if (q.explanationDetail != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: color, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: FuriganaText(
                                q.explanationDetail!, glossary: true,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // フィードバック（正解時）
                    if (q.feedbackCorrect.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '✨ ${q.feedbackCorrect}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── クイズCTAボタン ───

class _QuizCTA extends StatelessWidget {
  final Color color;
  final bool isLow;
  final VoidCallback onTap;

  const _QuizCTA({
    required this.color,
    required this.isLow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              isLow ? 'クイズに ちょうせん！' : 'クイズに挑戦！',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
