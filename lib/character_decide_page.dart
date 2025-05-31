import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart'; // No longer needed here

class CharacterDecidePage extends StatelessWidget {
  final List<int> answers;

  const CharacterDecidePage({super.key, required this.answers});

  final Map<String, dynamic> _characterFullData = const {
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

  double _normalizeAnswer(int questionIndex, int rawAnswer) {
    double normalizedScore = 3.0;
    switch (questionIndex) {
      case 0: // Q1 履修コマ数
        if (rawAnswer >= 22)
          normalizedScore = 5.0;
        else if (rawAnswer >= 18)
          normalizedScore = 4.0;
        else if (rawAnswer >= 14)
          normalizedScore = 3.0;
        else if (rawAnswer >= 10)
          normalizedScore = 2.0;
        else
          normalizedScore = 1.0;
        break;
      case 1: // Q2 1限コマ数
        if (rawAnswer >= 5)
          normalizedScore = 5.0;
        else if (rawAnswer == 4)
          normalizedScore = 4.5;
        else if (rawAnswer == 3)
          normalizedScore = 3.5;
        else if (rawAnswer == 2)
          normalizedScore = 2.5;
        else if (rawAnswer == 1)
          normalizedScore = 1.5;
        else
          normalizedScore = 1.0;
        break;
      case 2: // ★ Q3 週に休んだコマ数 (0-25 スライダー)
        if (rawAnswer == 0)
          normalizedScore = 5.0;
        else if (rawAnswer <= 2)
          normalizedScore = 4.0;
        else if (rawAnswer <= 4)
          normalizedScore = 3.0;
        else if (rawAnswer <= 7)
          normalizedScore = 2.0;
        else
          normalizedScore = 1.0;
        break;
      case 3: // ★ Q4 代筆を頼んだ回数 (0-25 スライダー)
        if (rawAnswer == 0)
          normalizedScore = 5.0;
        else if (rawAnswer == 1)
          normalizedScore = 3.5;
        else if (rawAnswer == 2)
          normalizedScore = 2.0;
        else if (rawAnswer == 3)
          normalizedScore = 1.0;
        else
          normalizedScore = 0.5;
        break;
      case 4: // Q5 バイト回数
        if (rawAnswer >= 5)
          normalizedScore = 5.0;
        else if (rawAnswer >= 3)
          normalizedScore = 4.0;
        else if (rawAnswer >= 1)
          normalizedScore = 3.0;
        else
          normalizedScore = 1.5;
        break;
      case 5: // Q6 サークル参加回数
        if (rawAnswer >= 4)
          normalizedScore = 5.0;
        else if (rawAnswer >= 2)
          normalizedScore = 3.5;
        else if (rawAnswer == 1)
          normalizedScore = 2.0;
        else
          normalizedScore = 1.0;
        break;
      case 6: // Q7 空きコマ数
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
      case 7:
      case 8:
      case 9:
      case 10: // Q8-Q11 スライダー (1-10)
        normalizedScore = ((rawAnswer - 1) / 9.0) * 4.0 + 1.0;
        break;
      case 11: // Q12 未知の体験
        const scores_q12 = [1.0, 3.5, 5.0, 1.5];
        normalizedScore = scores_q12[rawAnswer];
        break;
      case 12: // Q13 計画と実行
        const scores_q13 = [5.0, 3.5, 4.5, 1.0];
        normalizedScore = scores_q13[rawAnswer];
        break;
      case 13: // Q14 興味関心
        const scores_q14 = [5.0, 4.5, 4.0, 1.0];
        normalizedScore = scores_q14[rawAnswer];
        break;
      case 14: // Q15 困難への対処
        const scores_q15 = [4.5, 4.0, 3.5, 1.0];
        normalizedScore = scores_q15[rawAnswer];
        break;
      case 15: // Q16 活動時間帯
        const scores_q16 = [4.5, 3.0, 3.5, 5.0, 3.5];
        normalizedScore = scores_q16[rawAnswer];
        break;
      case 16: // Q17 ゆるい授業中の過ごし方
        const scores_q17 = [4.0, 0.5, 3.5, 1.0];
        normalizedScore = scores_q17[rawAnswer];
        break;
    }
    return max(0.5, min(5.0, normalizedScore));
  }

  double _normalizeInverse(int questionIndex, int rawAnswer) {
    double normalizedScore = _normalizeAnswer(questionIndex, rawAnswer);
    return 6.0 - normalizedScore;
  }

  String _diagnoseCharacter(List<int> currentAnswers) {
    if (currentAnswers.length != 17) {
      return "エラー：回答数が不足しています";
    }
    List<double> norm = List.generate(
      currentAnswers.length,
      (i) => _normalizeAnswer(i, currentAnswers[i]),
    );

    double totalClasses = currentAnswers[0].toDouble();
    double skippedClassesRaw = currentAnswers[2].toDouble(); // Q3の生の値
    double skippedPercentage =
        (totalClasses > 0)
            ? (skippedClassesRaw / totalClasses)
            : (skippedClassesRaw > 0 ? 1.0 : 0.0);

    double normalizedSkippedRateScore;
    if (skippedPercentage == 0)
      normalizedSkippedRateScore = 5.0;
    else if (skippedPercentage <= 0.1)
      normalizedSkippedRateScore = 4.0;
    else if (skippedPercentage <= 0.25)
      normalizedSkippedRateScore = 3.0;
    else if (skippedPercentage <= 0.50)
      normalizedSkippedRateScore = 2.0;
    else
      normalizedSkippedRateScore = 1.0;

    double knightScore = 0;
    knightScore += norm[0] * 0.2;
    knightScore += norm[1] * 0.7;
    knightScore += norm[5] * 1.0;
    knightScore += norm[7] * 1.2;
    knightScore += norm[8] * 1.0;
    if (currentAnswers[12] == 0)
      knightScore += norm[12] * 1.8;
    else if (currentAnswers[12] == 1)
      knightScore += norm[12] * 1.2;
    knightScore += norm[9] * 1.2;
    knightScore += norm[6] * 0.7;
    if (currentAnswers[14] == 1) knightScore += norm[14] * 1.5;
    knightScore += normalizedSkippedRateScore * 1.2;
    knightScore += norm[3] * 1.0; // Q4代筆しない
    if (currentAnswers[16] == 0) knightScore += norm[16] * 1.2; // Q17ゆる授業(聞く)

    double witchScore = 0;
    witchScore += norm[7] * 2.5;
    if (currentAnswers[13] == 0) witchScore += norm[13] * 2.0;
    if (currentAnswers[15] == 3) witchScore += norm[15] * 2.0;
    if (norm[1] <= 2.0) witchScore += (6.0 - norm[1]) * 0.8;
    witchScore += norm[9] * 1.0;
    if (norm[5] <= 2.0) witchScore += (6.0 - norm[5]) * 0.5;
    if (norm[4] <= 2.0) witchScore += (6.0 - norm[4]) * 0.3;
    if (currentAnswers[16] == 2)
      witchScore += norm[16] * 1.0;
    else if (currentAnswers[16] == 0)
      witchScore += norm[16] * 0.5;

    double merchantScore = 0;
    merchantScore += norm[4] * 1.8;
    merchantScore += _normalizeInverse(6, currentAnswers[6]) * 1.2;
    if (currentAnswers[13] == 2) merchantScore += norm[13] * 1.8;
    merchantScore += norm[10] * 1.0;
    if (currentAnswers[14] == 2) merchantScore += norm[14] * 1.5;
    if (currentAnswers[12] == 1) merchantScore += norm[12] * 1.0;
    if (currentAnswers[16] == 2)
      merchantScore += norm[16] * 2.2; // Q17ゆる授業(他課題)

    double gorillaScore = 0;
    if (currentAnswers[15] == 0) gorillaScore += norm[15] * 1.0;
    gorillaScore += norm[1] * 0.7;
    gorillaScore += norm[8] * 1.0;
    gorillaScore += norm[9] * 0.8;
    gorillaScore += norm[5] * 0.8;
    if (currentAnswers[14] == 0) gorillaScore += norm[14] * 1.5;
    gorillaScore += normalizedSkippedRateScore * 0.5;
    if (currentAnswers[16] == 3)
      gorillaScore -= 0.5; // Q17寝るは少しマイナス
    else if (currentAnswers[16] == 0)
      gorillaScore += 0.5;

    double adventurerScore = 0;
    if (currentAnswers[11] == 2)
      adventurerScore += norm[11] * 3.0;
    else if (currentAnswers[11] == 1)
      adventurerScore += norm[11] * 1.8;
    if (currentAnswers[12] == 2)
      adventurerScore += norm[12] * 2.5;
    else if (currentAnswers[12] == 1)
      adventurerScore += norm[12] * 1.0;
    if (currentAnswers[13] == 1) adventurerScore += norm[13] * 2.2;
    adventurerScore += _normalizeInverse(6, currentAnswers[6]) * 2.0;
    if (currentAnswers[12] == 0) adventurerScore -= 2.5;
    if (currentAnswers[15] == 4) adventurerScore += norm[15] * 2.2;
    if (currentAnswers[16] == 1)
      adventurerScore += norm[16] * 1.0; // Q17ゲーム
    else if (currentAnswers[16] == 3 && norm[10] < 3.0)
      adventurerScore += norm[16] * 0.3; // 忙しくないなら寝るのも自由
    if (normalizedSkippedRateScore <= 2.0 && normalizedSkippedRateScore > 1.0)
      adventurerScore -= 1.0;
    else if (normalizedSkippedRateScore <= 1.0)
      adventurerScore -= 2.5;

    double godScoreSum = 0;
    List<int> godCriteriaIndices = [1, 5, 7, 8, 9];
    for (int idx in godCriteriaIndices) {
      godScoreSum += norm[idx];
    }
    if (currentAnswers[12] == 0) godScoreSum += norm[12];
    if (currentAnswers[14] == 1) godScoreSum += norm[14];
    godScoreSum += norm[0] * 0.1;
    godScoreSum += normalizedSkippedRateScore;
    godScoreSum += norm[3];
    if (currentAnswers[16] == 0) godScoreSum += norm[16];
    if (godScoreSum >= 42.0 && norm[3] >= 3.5) {
      return "神";
    }

    bool isDefinitelyLoserByDaipitsu = norm[3] <= 2.0;
    double reCalclulatedLoserScore = 0;
    reCalclulatedLoserScore += _normalizeInverse(0, currentAnswers[0]) * 0.3;
    reCalclulatedLoserScore += _normalizeInverse(1, currentAnswers[1]);
    reCalclulatedLoserScore += (6.0 - normalizedSkippedRateScore) * 3.0;
    reCalclulatedLoserScore += (6.0 - norm[3]) * 3.5; // Q4代筆
    reCalclulatedLoserScore += _normalizeInverse(6, currentAnswers[6]) * 1.5;
    reCalclulatedLoserScore += _normalizeInverse(7, currentAnswers[7]) * 1.2;
    reCalclulatedLoserScore += _normalizeInverse(8, currentAnswers[8]);
    reCalclulatedLoserScore +=
        (currentAnswers[12] == 3 ? 5.0 : (norm[12] <= 2.0 ? 3.0 : 1.0));
    reCalclulatedLoserScore += _normalizeInverse(9, currentAnswers[9]) * 1.5;
    reCalclulatedLoserScore +=
        (currentAnswers[14] == 3 ? 5.0 : (norm[14] <= 2.0 ? 3.0 : 1.0));
    if (currentAnswers[16] == 1)
      reCalclulatedLoserScore += 5.0; // Q17ゲーム
    else if (currentAnswers[16] == 3)
      reCalclulatedLoserScore += 4.5; // Q17寝る
    if (reCalclulatedLoserScore >= 45.0 ||
        (isDefinitelyLoserByDaipitsu && reCalclulatedLoserScore >= 40.0) ||
        ((6.0 - normalizedSkippedRateScore) >= 4.5 && (6.0 - norm[3]) >= 4.0)) {
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
      double effectiveScore = max(0, score);
      if (effectiveScore > maxScore) {
        maxScore = effectiveScore;
        finalCharacter = character;
      }
    });
    return finalCharacter;
  }

  @override
  Widget build(BuildContext context) {
    final String characterName = _diagnoseCharacter(answers);
    final Map<String, dynamic> displayCharacterData =
        _characterFullData[characterName] ?? _characterFullData["剣士"]!;

    // buildメソッドのUI部分は変更なしなので省略
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
              'assets/question_background_image.png', // ★あなたの背景画像パス
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
                      characterName == "エラー：回答数が不足しています"
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
                    if (displayCharacterData["image"] != null)
                      CircleAvatar(
                        radius: 100,
                        backgroundImage: AssetImage(
                          displayCharacterData["image"],
                        ),
                        backgroundColor: Colors.brown[100],
                      ),
                    const SizedBox(height: 20),
                    Text(
                      displayCharacterData["name"] ?? characterName,
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
                              displayCharacterData["personality"] ?? "---",
                            ),
                            Divider(color: Colors.brown[200]),
                            _buildCharacteristicRow(
                              Icons.star_outline,
                              "スキル",
                              (displayCharacterData["skills"] as List<dynamic>?)
                                      ?.join(", ") ??
                                  "---",
                            ),
                            Divider(color: Colors.brown[200]),
                            _buildCharacteristicRow(
                              Icons.backpack_outlined,
                              "持ち物",
                              (displayCharacterData["items"] as List<dynamic>?)
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
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                '/square',
                                arguments: {
                                  'characterName': characterName,
                                  'characterImage':
                                      displayCharacterData["image"],
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
