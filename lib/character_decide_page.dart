import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'park_page.dart'; // Navigator.pushNamed を使うので直接は不要なことも

// CharacterDecidePage を StatefulWidget に変更
class CharacterDecidePage extends StatefulWidget {
  final List<int> answers;

  const CharacterDecidePage({super.key, required this.answers});

  @override
  State<CharacterDecidePage> createState() => _CharacterDecidePageState();
}

class _CharacterDecidePageState extends State<CharacterDecidePage> {
  late String _characterName; // 診断されたキャラクター名を保持
  late Map<String, dynamic> _displayCharacterData; // 表示するキャラクターデータを保持

  // キャラクターの全データ定義 (buildメソッドから移動)
  // initStateで使うため、Stateクラスのメンバにするか、外に定義します。
  // ここではStateクラスのメンバとして定義する例。
  final Map<String, dynamic> _characterFullData = {
    "剣士": {
      "image": 'assets/character_swordman.png',
      "name": "剣士",
      "personality":
          "文武両道でバランス感覚に優れ、計画的に物事を進める努力家。リーダーシップも兼ね備え、学業もサークルも手を抜かない優等生タイプ。",
      "skills": ["GPAマスタリー", "タイムマネジメント術", "グループリーダーシップ"],
      "items": ["成績優秀者の証", "多機能スケジュール帳", "折れない心"],
    },
    "魔女": {
      "image": 'assets/character_wizard.png',
      "name": "魔女",
      "personality":
          "強い探求心と知的好奇心を持ち、特定の分野を深く掘り下げて研究するタイプ。夜型でマイペース。独自の価値観と世界観を持つ孤高の探求者。",
      "skills": ["ディープリサーチ", "集中詠唱", "叡智の探求"],
      "items": ["古の魔導書", "深夜のコーヒー", "静寂のマント"],
    },
    "商人": {
      "image": 'assets/character_merchant.png',
      "name": "商人",
      "personality":
          "コミュニケーション能力が高く、要領が良い実利主義者。情報収集と人脈形成に長け、常にコスパと効率を重視。バイト経験も豊富で世渡り上手。",
      "skills": ["情報収集ネットワーク", "交渉の極意", "バイト時給アップ術"],
      "items": ["お得情報メモ", "多機能スマートフォン", "黄金の計算機"],
    },
    "ゴリラ": {
      "image": 'assets/character_gorilla.png',
      "name": "ゴリラ",
      "personality":
          "エネルギッシュな体育会系。朝型で、気合と根性と持ち前の体力で困難を乗り越える。考えるより行動が先。仲間思いで頼れる兄貴・姉御肌。",
      "skills": ["フィジカルMAX", "気合注入シャウト", "1限皆勤"],
      "items": ["プロテインシェイカー", "大量のバナナ", "汗と涙のジャージ"],
    },
    "冒険家": {
      "image": 'assets/character_adventurer.png',
      "name": "冒険家",
      "personality":
          "好奇心旺盛でフットワークが軽い自由人。未知の体験や新しい出会いを求め、計画に縛られず直感と柔軟性で行動する。リスクを恐れず挑戦し、変化を楽しむ。",
      "skills": ["ワールドウォーク", "即興サバイバル術", "未知との遭遇"],
      "items": ["使い古したバックパック", "方位磁石（たまに狂う）", "冒険日誌"],
    },
    "神": {
      "image": 'assets/character_god.png',
      "name": "神",
      "personality":
          "学業、活動、人間関係、全てにおいて高水準で完璧。欠点が見当たらず、周囲を圧倒するカリスマ性を持つ。まさに生きる伝説。",
      "skills": ["全知全能", "パーフェクトオールラウンド", "オーラ"],
      "items": ["光り輝く学生証", "未来予知ノート", "後光"],
    },
    "カス大学生": {
      "image": 'assets/character_takuji.png',
      "name": "カス大学生",
      "personality":
          "学業や活動へのモチベーションが著しく低く、計画性もない。日々を惰性で過ごし、楽な方へ流されがち。ギリギリの状況をなぜか生き抜く。",
      "skills": ["奇跡の単位取得", "遅刻ギリギリ回避術", "再履修の誓い"],
      "items": ["謎のシミがついたレジュメ", "エナジードリンクの空き缶", "鳴らない目覚まし時計"],
    },
    "エラー：回答数が不足しています": {
      "image": 'assets/character_unknown.png',
      "name": "診断エラー",
      "personality": "回答データに問題がありました。もう一度診断を試してみてください。",
      "skills": ["再診断"],
      "items": ["？"],
    },
  };

  @override
  void initState() {
    super.initState();
    // ページが初期化される時に診断を実行し、結果を保存
    _characterName = _diagnoseCharacter(widget.answers);
    _displayCharacterData =
        _characterFullData[_characterName] ?? _characterFullData["剣士"]!;

    // エラーでない場合のみFirestoreに保存
    if (_characterName != "エラー：回答数が不足しています") {
      _saveDiagnosisToFirestore(widget.answers, _characterName);
    }
  }

  // Firestoreへの保存処理 (CharacterDecidePageクラスのメソッドとして定義)
  Future<void> _saveDiagnosisToFirestore(
    List<int> userAnswers,
    String diagnosedCharacter,
  ) async {
    print('--- Firestoreへの保存処理を開始します (initStateから) ---');
    print('回答: $userAnswers');
    print('診断キャラ: $diagnosedCharacter');
    try {
      await FirebaseFirestore.instance.collection('diagnostics').add({
        'answers': userAnswers,
        'character': diagnosedCharacter,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('診断結果をFirestoreに保存しました。');
    } catch (e) {
      print('Firestoreへの保存に失敗しました: $e');
    }
  }

  // _normalizeAnswer, _normalizeInverse, _diagnoseCharacter メソッドは
  // StatefulWidget の State クラス (_CharacterDecidePageState) のメソッドとしてここに移動します。
  // (内容は前回提示したものと同じなので、ここでは省略します。widget.answers でアクセスするように注意)

  // ↓↓↓ _normalizeAnswer, _normalizeInverse, _diagnoseCharacter のコードをここに配置 ↓↓↓
  double _normalizeAnswer(int questionIndex, int rawAnswer) {
    double normalizedScore = 3.0;
    switch (questionIndex) {
      case 0:
        if (rawAnswer >= 20)
          normalizedScore = 5.0;
        else if (rawAnswer >= 16)
          normalizedScore = 4.0;
        else if (rawAnswer >= 12)
          normalizedScore = 3.0;
        else if (rawAnswer >= 8)
          normalizedScore = 2.0;
        else
          normalizedScore = 1.0;
        break;
      case 1:
        if (rawAnswer >= 4)
          normalizedScore = 5.0;
        else if (rawAnswer == 3)
          normalizedScore = 4.0;
        else if (rawAnswer == 2)
          normalizedScore = 3.0;
        else if (rawAnswer == 1)
          normalizedScore = 2.0;
        else
          normalizedScore = 1.0;
        break;
      case 2:
        if (rawAnswer >= 5)
          normalizedScore = 5.0;
        else if (rawAnswer >= 3)
          normalizedScore = 4.0;
        else if (rawAnswer >= 1)
          normalizedScore = 3.0;
        else
          normalizedScore = 1.5;
        break;
      case 3:
        if (rawAnswer >= 4)
          normalizedScore = 5.0;
        else if (rawAnswer >= 2)
          normalizedScore = 3.5;
        else if (rawAnswer == 1)
          normalizedScore = 2.0;
        else
          normalizedScore = 1.0;
        break;
      case 4:
        if (rawAnswer <= 1)
          normalizedScore = 5.0;
        else if (rawAnswer <= 3)
          normalizedScore = 4.0;
        else if (rawAnswer <= 6)
          normalizedScore = 3.0;
        else if (rawAnswer <= 8)
          normalizedScore = 2.0;
        else
          normalizedScore = 1.0;
        break;
      case 5:
        normalizedScore = ((rawAnswer - 1) / 9.0) * 4.0 + 1.0;
        break;
      case 6:
        normalizedScore = ((rawAnswer - 1) / 9.0) * 4.0 + 1.0;
        break;
      case 7:
        normalizedScore = ((rawAnswer - 1) / 9.0) * 4.0 + 1.0;
        break;
      case 8:
        normalizedScore = ((rawAnswer - 1) / 9.0) * 4.0 + 1.0;
        break;
      case 9:
        const unknown_exp_scores = [1.0, 3.0, 5.0, 1.5];
        normalizedScore = unknown_exp_scores[rawAnswer];
        break;
      case 10:
        const plan_style_scores = [5.0, 3.5, 4.5, 1.0];
        normalizedScore = plan_style_scores[rawAnswer];
        break;
      case 11:
        const interest_style_scores = [5.0, 4.5, 4.0, 1.0];
        normalizedScore = interest_style_scores[rawAnswer];
        break;
      case 12:
        const difficulty_coping_scores = [4.5, 4.0, 3.5, 1.0];
        normalizedScore = difficulty_coping_scores[rawAnswer];
        break;
      case 13:
        const activity_time_scores = [5.0, 3.0, 3.5, 5.0, 2.0];
        normalizedScore = activity_time_scores[rawAnswer];
        break;
      case 14:
        const daipitsu_scores = [5.0, 2.5, 1.0, 0.5, 4.0];
        normalizedScore = daipitsu_scores[rawAnswer];
        break;
    }
    return max(0.5, min(5.0, normalizedScore));
  }

  double _normalizeInverse(int questionIndex, int rawAnswer) {
    double normalizedScore = _normalizeAnswer(questionIndex, rawAnswer);
    return (5.0 - normalizedScore) + 1.0;
  }

  String _diagnoseCharacter(List<int> rawAnswersFromWidget) {
    // 引数名を変更 widget.answers と区別するため
    if (rawAnswersFromWidget.length != 15) {
      return "エラー：回答数が不足しています";
    }
    List<double> norm = List.generate(
      rawAnswersFromWidget.length,
      (i) => _normalizeAnswer(i, rawAnswersFromWidget[i]),
    );

    double knightScore = 0;
    knightScore += norm[0] * 1.5;
    knightScore += norm[1] * 1.0;
    knightScore += norm[3] * 1.0;
    knightScore += norm[5] * 1.2;
    knightScore += norm[6] * 1.0;
    if (rawAnswersFromWidget[10] == 0)
      knightScore += norm[10] * 1.5;
    else if (rawAnswersFromWidget[10] == 1)
      knightScore += norm[10] * 1.2;
    knightScore += norm[7] * 1.2;
    knightScore += _normalizeInverse(4, rawAnswersFromWidget[4]) * 1.0;
    if (rawAnswersFromWidget[12] == 1) knightScore += norm[12] * 1.0;

    double witchScore = 0;
    witchScore += norm[5] * 2.5;
    if (rawAnswersFromWidget[11] == 0) witchScore += norm[11] * 2.0;
    if (rawAnswersFromWidget[13] == 3) witchScore += norm[13] * 2.0;
    witchScore += _normalizeInverse(1, rawAnswersFromWidget[1]) * 1.0;
    witchScore += norm[7] * 1.0;
    witchScore += _normalizeInverse(3, rawAnswersFromWidget[3]) * 0.8;
    witchScore += _normalizeInverse(2, rawAnswersFromWidget[2]) * 0.5;

    double merchantScore = 0;
    merchantScore += norm[2] * 2.0;
    merchantScore += norm[4] * 1.5;
    if (rawAnswersFromWidget[11] == 2) merchantScore += norm[11] * 1.5;
    merchantScore += norm[8] * 1.2;
    if (rawAnswersFromWidget[12] == 2) merchantScore += norm[12] * 1.2;
    if (rawAnswersFromWidget[10] == 1) merchantScore += norm[10] * 1.0;

    double gorillaScore = 0;
    gorillaScore += norm[1] * 2.0;
    gorillaScore += norm[6] * 1.8;
    gorillaScore += norm[7] * 1.5;
    gorillaScore += norm[3] * 1.2;
    if (rawAnswersFromWidget[13] == 0) gorillaScore += norm[13] * 1.5;
    gorillaScore += norm[0] * 1.0;
    if (rawAnswersFromWidget[12] == 0) gorillaScore += norm[12] * 1.5;
    gorillaScore += norm[5] * 1.0;

    double adventurerScore = 0;
    if (rawAnswersFromWidget[9] == 2) adventurerScore += norm[9] * 2.5;
    if (rawAnswersFromWidget[10] == 2) adventurerScore += norm[10] * 2.0;
    if (rawAnswersFromWidget[11] == 1) adventurerScore += norm[11] * 1.5;
    adventurerScore += norm[4] * 1.0;
    if (rawAnswersFromWidget[10] == 0)
      adventurerScore += _normalizeInverse(10, rawAnswersFromWidget[10]) * 0.8;
    if (rawAnswersFromWidget[13] == 4) adventurerScore += norm[13] * 1.5;

    double godScore = 0;
    godScore += norm[0];
    godScore += norm[1];
    godScore += norm[3];
    godScore += norm[5];
    godScore += norm[6];
    godScore += norm[7];
    if (rawAnswersFromWidget[10] == 0) godScore += norm[10];
    if (rawAnswersFromWidget[12] == 1) godScore += norm[12];
    if (godScore >= 30.0 && norm[14] >= 4.0) {
      return "神";
    }

    bool isDefinitelyLoserByDaipitsu = norm[14] <= 1.0;
    double reCalclulatedLoserScore =
        _normalizeInverse(0, rawAnswersFromWidget[0]) +
        _normalizeInverse(1, rawAnswersFromWidget[1]) +
        norm[4] +
        _normalizeInverse(5, rawAnswersFromWidget[5]) +
        _normalizeInverse(6, rawAnswersFromWidget[6]) +
        (rawAnswersFromWidget[10] == 3
            ? 5.0
            : (_normalizeInverse(10, rawAnswersFromWidget[10]) * 0.5)) +
        _normalizeInverse(7, rawAnswersFromWidget[7]) +
        _normalizeInverse(14, rawAnswersFromWidget[14]) * 1.5 +
        (rawAnswersFromWidget[12] == 3
            ? 5.0
            : (_normalizeInverse(12, rawAnswersFromWidget[12]) * 0.5));

    if (reCalclulatedLoserScore >= 32.0 ||
        (isDefinitelyLoserByDaipitsu && reCalclulatedLoserScore >= 28.0)) {
      return "カス大学生";
    }

    Map<String, double> scores = {
      "剣士": knightScore,
      "魔女": witchScore,
      "商人": merchantScore,
      "ゴリラ": gorillaScore,
      "冒険家": adventurerScore,
    };

    String finalCharacter = "剣士";
    double maxScore = -double.infinity;
    scores.forEach((character, score) {
      if (score > maxScore) {
        maxScore = score;
        finalCharacter = character;
      }
    });
    return finalCharacter;
  }
  // ↑↑↑ _normalizeAnswer, _normalizeInverse, _diagnoseCharacter のコードはここまで ↑↑↑

  @override
  Widget build(BuildContext context) {
    // _characterName と _displayCharacterData は initState で初期化済みなので、
    // build メソッドではそれらを使用する。
    // String characterName = _diagnoseCharacter(widget.answers); // ここでの再診断は不要
    // final displayCharacterData = _characterFullData[_characterName] ?? _characterFullData["剣士"]!; // initStateで設定済み

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('診断結果'),
        backgroundColor: Colors.brown,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/question_background_image.png', // ★あなたのDecidePage用背景画像パス
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _characterName ==
                              "エラー：回答数が不足しています" // Stateの _characterName を使用
                          ? "おっと！"
                          : "🎓 あなたの履修タイプは…！",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 2.0,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (_displayCharacterData["image"] !=
                        null) // Stateの _displayCharacterData を使用
                      CircleAvatar(
                        radius: 100,
                        backgroundImage: AssetImage(
                          _displayCharacterData["image"],
                        ),
                        backgroundColor: Colors.brown[100],
                      ),
                    const SizedBox(height: 20),
                    Text(
                      _displayCharacterData["name"] ??
                          _characterName, // Stateの変数を使用
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCharacteristicRow(
                              Icons.psychology_alt,
                              "性格",
                              _displayCharacterData["personality"] ?? "---",
                            ),
                            Divider(color: Colors.brown[200]),
                            _buildCharacteristicRow(
                              Icons.star_outline,
                              "スキル",
                              (_displayCharacterData["skills"]
                                          as List<dynamic>?)
                                      ?.join(", ") ??
                                  "---",
                            ),
                            Divider(color: Colors.brown[200]),
                            _buildCharacteristicRow(
                              Icons.backpack_outlined,
                              "持ち物",
                              (_displayCharacterData["items"] as List<dynamic>?)
                                      ?.join(", ") ??
                                  "---",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            "再診断する",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600]?.withOpacity(
                              0.9,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Firestoreへの保存はinitStateで行われたので、ここではナビゲーションのみ
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                '/square',
                                arguments: {
                                  'characterName':
                                      _characterName, // Stateの _characterName を使用
                                  'characterImage':
                                      _displayCharacterData["image"], // Stateの _displayCharacterData を使用
                                },
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.explore_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "広場へ行く",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600]?.withOpacity(
                              0.9,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicRow(IconData icon, String title, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.brown[800], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(fontSize: 15, color: Colors.brown[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
