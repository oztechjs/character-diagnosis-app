import 'package:flutter/material.dart';
import 'dart:math'; // For max/min
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore を使うために必要
import 'character_decide_page.dart';

// 各質問の選択肢を定義 (ドロップダウン用) - これは変更なしなので、そのまま使います
final Map<int, List<String>> questionOptions = {
  9: [
    '(A) 強い不安を感じ、できるだけ避けたい',
    '(B) 少し不安はあるが、面白そうなら挑戦してみたい',
    '(C) ワクワクする！むしろ積極的に挑戦したい',
    '(D) まずは誰かが成功するのを見てから判断したい',
  ],
  10: [
    '(A) 完璧な計画を立てるまで行動に移せない',
    '(B) 大まかな計画を立て、あとは状況に合わせて進める',
    '(C) 思い立ったら即行動！計画は後から考えるか、なくてもOK',
    '(D) 誰かに計画を立ててもらうか、指示に従うことが多い',
  ],
  11: [
    '(A) 一つのことを深く掘り下げていくのが好き',
    '(B) 広く浅く、色々なことに触れてみたい',
    '(C) 実用的なことや結果に繋がりやすいものに興味が湧く',
    '(D) あまり物事に強い興味を持つことは少ない',
  ],
  12: [
    '(A) とにかく気合と根性で正面から突破しようと試みる',
    '(B) 状況を分析し、計画を立て直したり、別の方法を探したりする',
    '(C) 友人や信頼できる人に相談してアドバイスを求める、または協力を仰ぐ',
    '(D) 時間を置く、諦める、または他のことに意識を向ける',
  ],
  13: [
    '(A) 早朝～午前中',
    '(B) 日中（午前～夕方）',
    '(C) 夕方～夜にかけて',
    '(D) 深夜～明け方',
    '(E) 特に決まっていない／日によって大きく変動する',
  ],
  14: [
    '(A) 0回（頼んだことはない）',
    '(B) 1〜2回程度',
    '(C) 3〜5回程度',
    '(D) 6回以上',
    '(E) 頼む相手がいない／頼むという発想がなかった',
  ],
};

class CharacterQuestionPage extends StatefulWidget {
  @override
  _CharacterQuestionPageState createState() => _CharacterQuestionPageState();
}

class _CharacterQuestionPageState extends State<CharacterQuestionPage> {
  final List<String> questions = [
    '週に何コマ授業を履修していますか？（0〜25）',
    'その中で、1限に入っているコマ数は何回ですか？（0〜5）',
    '週に何回バイトをしていますか？（0〜6）',
    '週に何回サークルや部活に参加していますか？（0〜5）',
    '週に空きコマは何コマありますか？（0〜10）',
    '集中力には自信がありますか？（1＝すぐ気が散る、10＝超集中型）',
    'ストレス耐性はどれくらいありますか？（1＝すぐ病む、10＝鋼メンタル）',
    '学業・活動へのモチベーションは？（1＝やる気なし、10＝燃えている）',
    '自分の生活がどれくらい忙しいと感じますか？（1＝余裕、10＝超多忙）',
    '未知の体験への態度を選んでください。',
    '何か新しいことを始めようとするとき、あなたのスタイルは？',
    '新しいことや興味のあることに対して、あなたはどちらに近いですか？',
    '解決が難しい問題や大きな壁に直面した時、あなたはまずどうしますか？',
    'あなたが最も活動的になったり、集中できたりする時間帯はいつ頃ですか？',
    '（この一週間で）授業の代筆を友人に頼んだことは、おおよそ何回くらいありますか？',
  ];

  final List<int> maxValues = [
    25,
    5,
    6,
    5,
    10,
    10,
    10,
    10,
    10,
    (questionOptions[9]?.length ?? 1) - 1,
    (questionOptions[10]?.length ?? 1) - 1,
    (questionOptions[11]?.length ?? 1) - 1,
    (questionOptions[12]?.length ?? 1) - 1,
    (questionOptions[13]?.length ?? 1) - 1,
    (questionOptions[14]?.length ?? 1) - 1,
  ];

  late List<int> answers;

  @override
  void initState() {
    super.initState();
    answers = List.generate(questions.length, (index) {
      if (index >= 5 && index <= 8) {
        return 1;
      }
      return 0;
    });
  }

  // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
  // ★ CharacterDecidePage から診断ロジックと保存ロジックをこちらに移動 ★
  // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

  Future<void> _saveDiagnosisToFirestore(
    List<int> userAnswers,
    String diagnosedCharacter,
  ) async {
    print('--- Firestoreへの保存処理を開始します (QuestionPageから) ---');
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

  String _diagnoseCharacter(List<int> currentAnswers) {
    // 引数名変更
    if (currentAnswers.length != 15) {
      return "エラー：回答数が不足しています";
    }
    List<double> norm = List.generate(
      currentAnswers.length,
      (i) => _normalizeAnswer(i, currentAnswers[i]),
    );

    double knightScore = 0;
    knightScore += norm[0] * 1.5;
    knightScore += norm[1] * 1.0;
    knightScore += norm[3] * 1.0;
    knightScore += norm[5] * 1.2;
    knightScore += norm[6] * 1.0;
    if (currentAnswers[10] == 0)
      knightScore += norm[10] * 1.5;
    else if (currentAnswers[10] == 1)
      knightScore += norm[10] * 1.2;
    knightScore += norm[7] * 1.2;
    knightScore += _normalizeInverse(4, currentAnswers[4]) * 1.0;
    if (currentAnswers[12] == 1) knightScore += norm[12] * 1.0;

    double witchScore = 0;
    witchScore += norm[5] * 2.5;
    if (currentAnswers[11] == 0) witchScore += norm[11] * 2.0;
    if (currentAnswers[13] == 3) witchScore += norm[13] * 2.0; // 深夜明け方
    witchScore += _normalizeInverse(1, currentAnswers[1]) * 1.0;
    witchScore += norm[7] * 1.0;
    witchScore += _normalizeInverse(3, currentAnswers[3]) * 0.8;
    witchScore += _normalizeInverse(2, currentAnswers[2]) * 0.5;

    double merchantScore = 0;
    merchantScore += norm[2] * 2.0;
    merchantScore += norm[4] * 1.5;
    if (currentAnswers[11] == 2) merchantScore += norm[11] * 1.5; // 実用的
    merchantScore += norm[8] * 1.2;
    if (currentAnswers[12] == 2) merchantScore += norm[12] * 1.2; // 相談協力
    if (currentAnswers[10] == 1) merchantScore += norm[10] * 1.0; // 大まか計画

    double gorillaScore = 0;
    gorillaScore += norm[1] * 2.0;
    gorillaScore += norm[6] * 1.8;
    gorillaScore += norm[7] * 1.5;
    gorillaScore += norm[3] * 1.2;
    if (currentAnswers[13] == 0) gorillaScore += norm[13] * 1.5; // 早朝午前
    gorillaScore += norm[0] * 1.0;
    if (currentAnswers[12] == 0) gorillaScore += norm[12] * 1.5; // 根性
    gorillaScore += norm[5] * 1.0;

    double adventurerScore = 0;
    if (currentAnswers[9] == 2) adventurerScore += norm[9] * 2.5; // ワクワク
    if (currentAnswers[10] == 2) adventurerScore += norm[10] * 2.0; // 即行動
    if (currentAnswers[11] == 1) adventurerScore += norm[11] * 1.5; // 広く浅く
    adventurerScore += norm[4] * 1.0; // 空きコマ
    if (currentAnswers[10] == 0)
      adventurerScore +=
          _normalizeInverse(10, currentAnswers[10]) * 0.8; // 完璧計画なら減点
    if (currentAnswers[13] == 4) adventurerScore += norm[13] * 1.5; // 不定

    double godScore = 0;
    godScore += norm[0];
    godScore += norm[1];
    godScore += norm[3];
    godScore += norm[5];
    godScore += norm[6];
    godScore += norm[7];
    if (currentAnswers[10] == 0) godScore += norm[10];
    if (currentAnswers[12] == 1) godScore += norm[12];
    if (godScore >= 30.0 && norm[14] >= 4.0) {
      // norm[14] >= 4.0 は代筆0回か頼めない/発想なし
      return "神";
    }

    bool isDefinitelyLoserByDaipitsu =
        norm[14] <= 1.0; // 代筆3-5回以上 (norm 1.0 or 0.5)
    // 注意: CharacterQuestionPageの代筆の選択肢は (B)1-2回 (C)3-5回 (D)6回以上 になっているので、
    // norm[14]<=1.0 は rawAnswer が 2 (3-5回) または 3 (6回以上) に対応します。
    double reCalclulatedLoserScore =
        _normalizeInverse(0, currentAnswers[0]) +
        _normalizeInverse(1, currentAnswers[1]) +
        norm[4] +
        _normalizeInverse(5, currentAnswers[5]) +
        _normalizeInverse(6, currentAnswers[6]) +
        (currentAnswers[10] == 3
            ? 5.0
            : (_normalizeInverse(10, currentAnswers[10]) * 0.5)) +
        _normalizeInverse(7, currentAnswers[7]) +
        _normalizeInverse(14, currentAnswers[14]) * 1.5 +
        (currentAnswers[12] == 3
            ? 5.0
            : (_normalizeInverse(12, currentAnswers[12]) * 0.5));
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

  Widget _buildQuestionWidget(int index) {
    if (index >= 9) {
      final options = questionOptions[index] ?? [];
      int currentValue = answers[index];
      if (currentValue >= options.length) {
        currentValue = 0;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${index + 1}. ${questions[index]}',
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
    } else {
      bool isOneBased = (index >= 5 && index <= 8);
      double minVal = isOneBased ? 1.0 : 0.0;
      int divisionsVal = maxValues[index] - (isOneBased ? 1 : 0);
      if (divisionsVal <= 0) divisionsVal = 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${index + 1}. ${questions[index]}',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Slider(
            value: answers[index].toDouble(),
            min: minVal,
            max: maxValues[index].toDouble(),
            divisions: divisionsVal,
            label: answers[index].toString(),
            activeColor: Colors.orange[700],
            inactiveColor: Colors.orange[200]?.withOpacity(0.7),
            onChanged: (value) {
              setState(() {
                answers[index] = value.toInt();
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
        title: Text('キャラ診断'),
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
              'assets/question_background_image.png', // ★あなたの背景画像パス
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
                  // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
                  // ★ 「診断結果を見る」ボタンの onPressed を修正 ★
                  // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
                  onPressed: () async {
                    // ★ async を追加
                    // 1. 診断を実行してキャラクター名を取得
                    // `answers` はこのStateクラスのメンバ変数なのでそのまま使える
                    final String characterName = _diagnoseCharacter(answers);

                    // 2. Firestoreにデータを保存 (エラーでない場合)
                    if (characterName != "エラー：回答数が不足しています") {
                      await _saveDiagnosisToFirestore(
                        answers,
                        characterName,
                      ); // ★ awaitで保存
                    } else {
                      print("診断エラーのため、Firestoreへの保存はスキップされました。");
                      // 必要であればユーザーにエラーを伝えるUI処理
                    }

                    // 3. 診断結果ページに遷移
                    // Navigator.push に CharacterDecidePage を渡す際、
                    // CharacterDecidePage側が characterName も受け取れるように修正するか、
                    // あるいは CharacterDecidePage で再度 _diagnoseCharacter を呼び出すかを選択。
                    // ここでは CharacterDecidePage が answers だけを受け取る前提で進めます。
                    // (もし CharacterDecidePage も修正するなら、characterName も渡せます)
                    if (mounted) {
                      // contextが有効か確認
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  CharacterDecidePage(answers: answers),
                          // もしCharacterDecidePageで再診断を避けるなら以下のようにcharacterNameも渡す
                          // builder: (context) => CharacterDecidePage(answers: answers, diagnosedCharacterName: characterName),
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
