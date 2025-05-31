import 'package:flutter/material.dart';
import 'dart:math'; // For max/min
import 'package:cloud_firestore/cloud_firestore.dart';
import 'character_decide_page.dart';

// 各質問の選択肢を定義 (ドロップダウン用 - インデックス11から16)
final Map<int, List<String>> questionOptions = {
  11: [
    '(A) 強い不安を感じ、できるだけ避けたい',
    '(B) 少し不安はあるが、面白そうなら挑戦してみたい',
    '(C) ワクワクする！むしろ積極的に挑戦したい',
    '(D) まずは誰かが成功するのを見てから判断したい',
  ],
  12: [
    '(A) 完璧な計画を立てるまで行動に移せない',
    '(B) 大まかな計画を立て、あとは状況に合わせて進める',
    '(C) 思い立ったら即行動！計画は後から考えるか、なくてもOK',
    '(D) 誰かに計画を立ててもらうか、指示に従うことが多い',
  ],
  13: [
    '(A) 一つのことを深く掘り下げていくのが好き',
    '(B) 広く浅く、色々なことに触れてみたい',
    '(C) 実用的なことや結果に繋がりやすいものに興味が湧く',
    '(D) あまり物事に強い興味を持つことは少ない',
  ],
  14: [
    '(A) とにかく気合と根性で正面から突破しようと試みる',
    '(B) 状況を分析し、計画を立て直したり、別の方法を探したりする',
    '(C) 友人や信頼できる人に相談してアドバイスを求める、または協力を仰ぐ',
    '(D) 時間を置く、諦める、または他のことに意識を向ける',
  ],
  15: [
    '(A) 早朝～午前中',
    '(B) 日中（午前～夕方）',
    '(C) 夕方～夜にかけて',
    '(D) 深夜～明け方',
    '(E) 特に決まっていない／日によって大きく変動する',
  ],
  16: [
    '(A) 一応授業を聞いている',
    '(B) スマートフォンやPCでゲームをする',
    '(C) 他の授業の課題や作業を進める',
    '(D) 寝る',
  ],
};

class CharacterQuestionPage extends StatefulWidget {
  @override
  _CharacterQuestionPageState createState() => _CharacterQuestionPageState();
}

class _CharacterQuestionPageState extends State<CharacterQuestionPage> {
  final List<String> questions = [
    'Q1: 週に何コマ授業を履修してる？（0〜25コマ）',
    'Q2: 1限に何コマ入ってる？（0〜5回）',
    'Q3: 一週間で何コマくらい蹴ってるの？（0〜25コマ）',
    'Q4: 一週間で何コマくらい代筆頼んだ？（0〜25回）',
    'Q5: 週に何日バイトしてる？（0〜6回）',
    'Q6: 週に何日サークルや部活に参加してる？（0〜5回）',
    'Q7: 週に空きコマは何コマある？（0〜10コマ）',
    'Q8: 集中力には自信ある？（1:すぐ気が散る 〜 10:超集中型）',
    'Q9: ストレスに強い？（1:すぐ病む 〜 10:鋼メンタル）',
    'Q10: 学業・活動へのモチベーションは？（1:やる気なし 〜 10:燃えている）',
    'Q11: 自分はどれくらい忙しいと思う？（1:余裕 〜 10:超多忙）',
    'Q12: 未知の体験への態度を教えて',
    'Q13: 何か新しいことを始めようとするとき、あなたのスタイルは？',
    'Q14: 新しいことや興味のあることに対して、あなたはどっちに近い？',
    'Q15: 解決が難しい問題や大きな壁に直面した時、あなたはまずどうする？',
    'Q16: あなたが最も活動的になったり、集中できたりする時間帯はいつ？',
    'Q17: ゆるい授業中（楽単など）は普段何して過ごすことが多い？',
  ];

  final List<int> maxValues = [
    25,
    5,
    25,
    25,
    6,
    5,
    10,
    10,
    10,
    10,
    10,
    (questionOptions[11]?.length ?? 1) - 1,
    (questionOptions[12]?.length ?? 1) - 1,
    (questionOptions[13]?.length ?? 1) - 1,
    (questionOptions[14]?.length ?? 1) - 1,
    (questionOptions[15]?.length ?? 1) - 1,
    (questionOptions[16]?.length ?? 1) - 1,
  ];

  late List<int> answers;

  @override
  void initState() {
    super.initState();
    answers = List.generate(questions.length, (index) {
      if (index >= 7 && index <= 10) {
        return 1;
      }
      return 0;
    });
  }

  Future<void> _saveDiagnosisToFirestore(
    List<int> userAnswers,
    String diagnosedCharacter,
  ) async {
    print('--- Firestoreへの保存処理を開始します (QuestionPageから) ---');
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
      case 2: // ★ Q3 週に休んだコマ数 (0-25 スライダー) - ユーザーフィードバックで調整
        if (rawAnswer == 0)
          normalizedScore = 5.0; // 0回 -> 最高点
        else if (rawAnswer <= 2)
          normalizedScore = 4.0; // 1-2回 -> まだ許容範囲
        else if (rawAnswer <= 4)
          normalizedScore = 3.0; // 3-4回 -> 平均的？やや注意
        else if (rawAnswer <= 7)
          normalizedScore = 2.0; // 5-7回 -> 問題あり
        else
          normalizedScore = 1.0; // 8回以上 -> かなり問題
        break;
      case 3: // ★ Q4 代筆を頼んだ回数 (0-25 スライダー) - ユーザーフィードバックで調整
        if (rawAnswer == 0)
          normalizedScore = 5.0; // 0回 -> 最高点
        else if (rawAnswer == 1)
          normalizedScore = 3.5; // 1回 -> 注意 (以前2.5だったのを緩和)
        else if (rawAnswer == 2)
          normalizedScore = 2.0; // 2回 -> 問題あり
        else if (rawAnswer == 3)
          normalizedScore = 1.0; // 3回 -> かなり問題
        else
          normalizedScore = 0.5; // 4回以上 -> ほぼ最低点
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
            : (skippedClassesRaw > 0 ? 1.0 : 0.0); // 総コマ0で休んだら100%

    double normalizedSkippedRateScore; // 0%欠席=5.0点, 50%以上欠席=1.0点
    if (skippedPercentage == 0)
      normalizedSkippedRateScore = 5.0;
    else if (skippedPercentage <= 0.1)
      normalizedSkippedRateScore = 4.0; // 10%以下
    else if (skippedPercentage <= 0.25)
      normalizedSkippedRateScore = 3.0; // 11-25%
    else if (skippedPercentage <= 0.50)
      normalizedSkippedRateScore = 2.0; // 26-50%
    else
      normalizedSkippedRateScore = 1.0; // 51%以上

    // --- 各キャラクタースコア計算 (ユーザーフィードバック反映) ---
    double knightScore = 0;
    knightScore += norm[0] * 0.2; // Q1履修コマ (影響度最小限)
    knightScore += norm[1] * 0.7; // Q2 1限
    knightScore += norm[5] * 1.0; // Q6サークル
    knightScore += norm[7] * 1.2; // Q8集中力
    knightScore += norm[8] * 1.0; // Q9ストレス耐性
    if (currentAnswers[12] == 0)
      knightScore += norm[12] * 1.8; // Q13計画(A:完璧)
    else if (currentAnswers[12] == 1)
      knightScore += norm[12] * 1.2; // Q13計画(B:大まか)
    knightScore += norm[9] * 1.2; // Q10モチベ
    knightScore += norm[6] * 0.7; // Q7空きコマ少ない
    if (currentAnswers[14] == 1) knightScore += norm[14] * 1.5; // Q15困難(B:分析)
    knightScore += normalizedSkippedRateScore * 1.2; // ★自主欠席率低いほどプラス(重要度少しアップ)
    knightScore += norm[3] * 1.0; // ★Q4代筆しないほどプラス(重要度少しアップ)
    if (currentAnswers[16] == 0)
      knightScore += norm[16] * 1.2; // ★Q17ゆる授業(A:聞く)(重要度アップ)

    double witchScore = 0;
    witchScore += norm[7] * 2.5; // Q8集中力
    if (currentAnswers[13] == 0) witchScore += norm[13] * 2.0; // Q14興味(A:深く狭く)
    if (currentAnswers[15] == 3) witchScore += norm[15] * 2.0; // Q16活動(D:深夜)
    if (norm[1] <= 2.0) witchScore += (6.0 - norm[1]) * 0.8;
    witchScore += norm[9] * 1.0; // Q10モチベ
    if (norm[5] <= 2.0) witchScore += (6.0 - norm[5]) * 0.5;
    if (norm[4] <= 2.0) witchScore += (6.0 - norm[4]) * 0.3;
    if (currentAnswers[16] == 2)
      witchScore += norm[16] * 1.0; // ★Q17ゆる授業(C:他課題)少しアップ
    else if (currentAnswers[16] == 0)
      witchScore += norm[16] * 0.5;

    double merchantScore = 0;
    merchantScore += norm[4] * 1.8; // Q5バイト
    merchantScore += _normalizeInverse(6, currentAnswers[6]) * 1.2; // Q7空きコマ多い
    if (currentAnswers[13] == 2)
      merchantScore += norm[13] * 1.8; // Q14興味(C:実用的)
    merchantScore += norm[10] * 1.0; // Q11忙しさ
    if (currentAnswers[14] == 2) merchantScore += norm[14] * 1.5; // Q15困難(C:相談)
    if (currentAnswers[12] == 1)
      merchantScore += norm[12] * 1.0; // Q13計画(B:大まか)
    if (currentAnswers[16] == 2)
      merchantScore += norm[16] * 2.2; // ★Q17ゆる授業(C:他課題) (超重要)

    double gorillaScore = 0; // ★ゴリラ抑制のため全体的に重み見直し
    if (currentAnswers[15] == 0)
      gorillaScore += norm[15] * 1.0; // Q16活動(A:早朝) (重み下げ)
    gorillaScore += norm[1] * 0.7; // Q2 1限 (重み下げ)
    gorillaScore += norm[8] * 1.0; // Q9ストレス (重み下げ)
    gorillaScore += norm[9] * 0.8; // Q10モチベ (重み下げ)
    gorillaScore += norm[5] * 0.8; // Q6サークル (重み下げ)
    if (currentAnswers[14] == 0)
      gorillaScore += norm[14] * 1.5; // Q15困難(A:根性) (これは維持)
    gorillaScore += normalizedSkippedRateScore * 0.5; // Q3休講少ない (影響度少し下げる)
    if (currentAnswers[16] == 3)
      gorillaScore -= 0.5; // Q17ゆる授業(D:寝る)は少しマイナス
    else if (currentAnswers[16] == 0)
      gorillaScore += 0.5; // (A:聞く)

    double adventurerScore = 0; // ★冒険家を出すため全体的に重み見直し・追加
    if (currentAnswers[11] == 2)
      adventurerScore += norm[11] * 3.0; // Q12未知(C:ワクワク) (最重要)
    else if (currentAnswers[11] == 1)
      adventurerScore += norm[11] * 1.8; // Q12未知(B:興味)
    if (currentAnswers[12] == 2)
      adventurerScore += norm[12] * 2.5; // Q13計画(C:即行動) (重要)
    else if (currentAnswers[12] == 1)
      adventurerScore += norm[12] * 1.0; // Q13計画(B:大まか)
    if (currentAnswers[13] == 1)
      adventurerScore += norm[13] * 2.2; // Q14興味(B:広く浅く) (重要)
    adventurerScore +=
        _normalizeInverse(6, currentAnswers[6]) * 2.0; // Q7空きコマ多い (重要)
    if (currentAnswers[12] == 0) adventurerScore -= 2.5; // Q13計画(A:完璧)は大きくマイナス
    if (currentAnswers[15] == 4)
      adventurerScore += norm[15] * 2.2; // Q16活動(E:不定) (重要)
    if (currentAnswers[16] == 1)
      adventurerScore += norm[16] * 1.0; // ★Q17ゆる授業(B:ゲーム) 冒険家的息抜き
    else if (currentAnswers[16] == 3)
      adventurerScore += norm[16] * 0.3; // 寝るも少し許容
    if (normalizedSkippedRateScore <= 2.5 && normalizedSkippedRateScore > 1.0)
      adventurerScore -= 0.8;
    else if (normalizedSkippedRateScore <= 1.0)
      adventurerScore -= 2.0; // サボりすぎは冒険家でもダメ

    // --- レアキャラ判定 ---
    double godScoreSum = 0;
    List<int> godCriteriaIndices = [1, 5, 7, 8, 9];
    for (int idx in godCriteriaIndices) {
      godScoreSum += norm[idx];
    }
    if (currentAnswers[12] == 0) godScoreSum += norm[12];
    if (currentAnswers[14] == 1) godScoreSum += norm[14];
    godScoreSum += norm[0] * 0.1; // Q1はほぼ影響なし
    godScoreSum += normalizedSkippedRateScore; // 自主欠席しない
    godScoreSum += norm[3]; // 代筆しない
    if (currentAnswers[16] == 0) godScoreSum += norm[16]; // ゆる授業でも聞く
    if (godScoreSum >= 42.0 && norm[3] >= 3.5) {
      // 代筆0回か1回程度
      return "神";
    }

    bool isDefinitelyLoserByDaipitsu = norm[3] <= 2.0; // Q4代筆2回以上でかなり黒い
    double reCalclulatedLoserScore = 0;
    reCalclulatedLoserScore += _normalizeInverse(0, currentAnswers[0]) * 0.3;
    reCalclulatedLoserScore += _normalizeInverse(1, currentAnswers[1]);
    reCalclulatedLoserScore +=
        (6.0 - normalizedSkippedRateScore) * 3.0; // ★Q3休講多い(超超重要)
    reCalclulatedLoserScore += (6.0 - norm[3]) * 3.5; // ★Q4代筆多い(超超重要)
    reCalclulatedLoserScore += _normalizeInverse(6, currentAnswers[6]) * 1.5;
    reCalclulatedLoserScore += _normalizeInverse(7, currentAnswers[7]) * 1.2;
    reCalclulatedLoserScore += _normalizeInverse(8, currentAnswers[8]);
    reCalclulatedLoserScore +=
        (currentAnswers[12] == 3 ? 5.0 : (norm[12] <= 2.0 ? 3.0 : 1.0));
    reCalclulatedLoserScore += _normalizeInverse(9, currentAnswers[9]) * 1.5;
    reCalclulatedLoserScore +=
        (currentAnswers[14] == 3 ? 5.0 : (norm[14] <= 2.0 ? 3.0 : 1.0));
    if (currentAnswers[16] == 1)
      reCalclulatedLoserScore += 5.0; // ★Q17ゆる授業(B:ゲーム)
    else if (currentAnswers[16] == 3)
      reCalclulatedLoserScore += 4.5; // ★Q17ゆる授業(D:寝る)

    // 閾値は状況に応じて調整。カス学生は明確な行動で判断。
    if (reCalclulatedLoserScore >= 45.0 ||
        (isDefinitelyLoserByDaipitsu && reCalclulatedLoserScore >= 40.0) ||
        ((6.0 - normalizedSkippedRateScore) >= 4.0 && (6.0 - norm[3]) >= 4.0)) {
      // 最後は欠席と代筆が両方多い場合
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

  Widget _buildQuestionWidget(int index) {
    if (index <= 10) {
      // スライダーはインデックス0から10 (Q1からQ11)
      bool isOneBased = (index >= 7 && index <= 10);
      double minVal = isOneBased ? 1.0 : 0.0;
      if (index == 2 || index == 3) {
        // Q3, Q4 も0始まり
        minVal = 0.0;
        isOneBased = false;
      }
      int divisionsVal = maxValues[index] - (isOneBased ? 1 : 0);
      if (index == 2 || index == 3) {
        divisionsVal = maxValues[index]; // Q3, Q4 の divisions は max - min
      }
      if (divisionsVal <= 0) divisionsVal = 1;

      return Column(
        /* ... スライダーUI ... */
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questions[index],
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Slider(
            value: answers[index].toDouble(),
            min: minVal,
            max: maxValues[index].toDouble(),
            divisions: divisionsVal,
            label: answers[index].toString(),
            activeColor: Colors.orange[700],
            inactiveColor: const Color.fromARGB(
              255,
              11,
              175,
              147,
            )?.withOpacity(0.7),
            onChanged: (value) {
              setState(() {
                answers[index] = value.toInt();
              });
            },
          ),
        ],
      );
    } else {
      // ドロップダウンはインデックス11から16 (Q12からQ17)
      final options = questionOptions[index] ?? [];
      int currentValue = answers[index];
      if (currentValue >= options.length) {
        currentValue = 0;
      }
      return Column(
        /* ... ドロップダウンUI ... */
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questions[index],
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<int>(
            style: TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            dropdownColor: Colors.brown[700],
            value: currentValue,
            isExpanded: true,
            items:
                options.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                answers[index] = value ?? 0;
              });
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('キャラ診断 ver3.0'),
        backgroundColor: Colors.brown,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/question_background_image.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < questions.length; i++) ...[
                  _buildQuestionWidget(i),
                  SizedBox(height: 24),
                ],
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.psychology, color: Colors.white),
                  label: Text(
                    '診断結果を見る',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () async {
                    final String characterName = _diagnoseCharacter(answers);
                    if (characterName != "エラー：回答数が不足しています") {
                      await _saveDiagnosisToFirestore(answers, characterName);
                    } else {
                      print("診断エラーのため、Firestoreへの保存はスキップされました。");
                    }
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  CharacterDecidePage(answers: answers),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
