import 'package:flutter/material.dart';
import 'dart:math'; // For max/min
import 'package:cloud_firestore/cloud_firestore.dart';
import 'character_decide_page.dart';

// 各質問の選択肢を定義 (ドロップダウン用 - 新しいインデックス10から19)
final Map<int, List<String>> questionOptions = {
  10: [
    '(A) 強い不安を感じ、できるだけ避けたい',
    '(B) 少し不安はあるが、面白そうなら挑戦してみたい',
    '(C) ワクワクする！むしろ積極的に挑戦したい',
    '(D) まずは誰かが成功するのを見てから判断したい',
  ], // Q11 未知の体験 (旧Q12)
  11: [
    '(A) 完璧な計画を立てるまで行動に移せない',
    '(B) 大まかな計画を立て、あとは状況に合わせて進める',
    '(C) 思い立ったら即行動！計画は後から考えるか、なくてもOK',
    '(D) 誰かに計画を立ててもらうか、指示に従うことが多い',
  ], // Q12 計画と実行 (旧Q13)
  12: [
    '(A) 一つのことを深く掘り下げていくのが好き',
    '(B) 広く浅く、色々なことに触れてみたい',
    '(C) 実用的なことや結果に繋がりやすいものに興味が湧く',
    '(D) あまり物事に強い興味を持つことは少ない',
  ], // Q13 興味関心 (旧Q14)
  13: [
    '(A) とにかく気合と根性で正面から突破しようと試みる',
    '(B) 状況を分析し、計画を立て直したり、別の方法を探したりする',
    '(C) 友人や信頼できる人に相談してアドバイスを求める、または協力を仰ぐ',
    '(D) 時間を置く、諦める、または他のことに意識を向ける',
  ], // Q14 困難への対処 (旧Q15)
  14: [
    '(A) 早朝～午前中',
    '(B) 日中（午前～夕方）',
    '(C) 夕方～夜にかけて',
    '(D) 深夜～明け方',
    '(E) 特に決まっていない／日によって大きく変動する',
  ], // Q15 活動時間帯 (旧Q16)
  15: [
    '(A) 一応授業を聞いている',
    '(B) スマートフォンやPCでゲームをする',
    '(C) 他の授業の課題や作業を進める',
    '(D) 寝る',
  ], // Q16 ゆるい授業中 (旧Q17)
  16: [
    // ★★★ 新しい質問 Q17 (価値観/動機) ★★★
    '(A) 安定と秩序、計画通りの達成感',
    '(B) 知的好奇心の充足、新しい知識や真理の探求',
    '(C) 実利的な成果、効率的な成功や利益',
    '(D) 新しい経験、スリルと自由、予測不可能な楽しさ',
    '(E) 困難を乗り越えること、自分自身への挑戦と成長',
    '(F) できるだけ心穏やかに、ストレスなく過ごすこと',
  ],
  17: [
    // ★★★ 新しい質問 Q18 (グループワークリスク) ★★★
    '(A) リスクはあっても、挑戦しがいがあるので積極的に引き受ける',
    '(B) 成功の確証が持てないなら、堅実にこなせる他の役割を選ぶ',
    '(C) 他のメンバーの様子を見て、安全そうであれば検討する',
    '(D) 面倒なことや責任が重いことは極力避けたい',
  ],
  18: [
    // ★★★ 新しい質問 Q19 (エネルギー回復) ★★★
    '(A) 一人で静かに過ごし、自分の趣味や好きなことに没頭する',
    '(B) 気の合う仲間と集まってワイワイ騒いだり、おしゃべりしたりする',
    '(C) とにかくたくさん寝る',
    '(D) 新しい場所に出かけたり、気分転換になるような活動をする',
  ],
  19: [
    // ★★★ 新しい質問 Q20 (1ヶ月自由時間) ★★★
    '(A) 普段できないような壮大な計画（長期旅行、スキル習得など）を実行する',
    '(B) 自分の興味のある分野の研究や創作活動に完全に没頭する',
    '(C) 新しいビジネスのアイデアを練ったり、人脈作りに時間を費やす',
    '(D) とにかく体を動かす！合宿やトレーニング、アウトドア活動三昧',
    '(E) 何もせず、ひたすら寝たりゲームをしたりしてのんびり過ごす',
    '(F) 特に何も決めず、その時々の気分で面白そうなことをする',
  ],
};

class CharacterQuestionPage extends StatefulWidget {
  @override
  _CharacterQuestionPageState createState() => _CharacterQuestionPageState();
}

class _CharacterQuestionPageState extends State<CharacterQuestionPage> {
  // 質問リスト (全20問 - 新しい順序)
  final List<String> questions = [
    'Q1: 週に何コマ授業あるの？（0〜25コマ）', // index 0
    'Q2: 1限は何コマ埋まってる？（0〜5コマ）', // index 1
    'Q3: 週何コマくらい飛んでる？（友達に代筆頼んだりも含む）（0〜25コマ）', // index 2 (新・統合)
    'Q4: 週に何日バイトをしてる？（0〜6日）', // index 3 (旧Q5)
    'Q5: 週に何日サークルや部活に参加してる？（0〜5日）', // index 4 (旧Q6)
    'Q6: 週に空きコマは何コマある？（0〜10コマ）', // index 5 (旧Q7)
    'Q7: 集中力には自信がある？（1:すぐ気が散る 〜 10:超集中型）', // index 6 (旧Q8)
    'Q8: ストレス耐性はどれくらいある？（1:すぐ病む 〜 10:鋼メンタル）', // index 7 (旧Q9)
    'Q9: 学業・活動へのモチベーションは？（1:やる気なし 〜 10:燃えている）', // index 8 (旧Q10)
    'Q10: 自分の生活がどれくらい忙しいと思う？（1:余裕 〜 10:超多忙）', // index 9 (旧Q11)
    'Q11: 未知の体験への態度を選んでね。', // index 10 (旧Q12)
    'Q12: 何か新しいことを始めようとするとき、あなたのスタイルは？', // index 11 (旧Q13)
    'Q13: 新しいことや興味のあることに対して、あなたはどちらに近い？', // index 12 (旧Q14)
    'Q14: 解決が難しい問題や大きな壁に直面した時、あなたはまずどうする？', // index 13 (旧Q15)
    'Q15: あなたが最も活動的になったり、集中できたりする時間帯はいつ？', // index 14 (旧Q16)
    'Q16: ゆるい授業中（楽単など）は何をして過ごすことが多い？', // index 15 (旧Q17)
    'Q17: あなたが最も価値を置くもの（または、行動する上で最も重視する動機）は以下のどれに近い？', // index 16 (新規1)
    'Q18: グループワークで、誰もやりたがらないが成功すれば大きな評価を得られる役割があるよね。あなたならどうする？', // index 17 (新規2)
    'Q19: 疲れたりストレスが溜まったりした時、どうやってエネルギーを回復する？', // index 18 (新規3)
    'Q20: もし1ヶ月間、全ての義務から解放されて自由に過ごせるとしたら、主に何をする？', // index 19 (新規4)
  ];

  // スライダー用の最大値
  final List<int> maxValues = [
    25, // Q1
    5, // Q2
    25, // Q3 (飛んだ/代筆コマ数)
    6, // Q4
    5, // Q5
    10, // Q6
    10, // Q7
    10, // Q8
    10, // Q9
    10, // Q10
    // ドロップダウンは選択肢の数で制御 (questionOptionsのキーは新しいインデックスに対応)
    (questionOptions[10]?.length ?? 1) - 1, // Q11
    (questionOptions[11]?.length ?? 1) - 1, // Q12
    (questionOptions[12]?.length ?? 1) - 1, // Q13
    (questionOptions[13]?.length ?? 1) - 1, // Q14
    (questionOptions[14]?.length ?? 1) - 1, // Q15
    (questionOptions[15]?.length ?? 1) - 1, // Q16
    (questionOptions[16]?.length ?? 1) - 1, // Q17
    (questionOptions[17]?.length ?? 1) - 1, // Q18
    (questionOptions[18]?.length ?? 1) - 1, // Q19
    (questionOptions[19]?.length ?? 1) - 1, // Q20
  ];

  late List<int> answers;

  @override
  void initState() {
    super.initState();
    answers = List.generate(questions.length, (index) {
      if (index >= 6 && index <= 9) {
        // Q7-Q10 (1-10スケール)
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

  // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
  // ★ 診断ロジック (_normalizeAnswer, _diagnoseCharacter) - 最新版 (20問対応) ★
  // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
  double _normalizeAnswer(int questionIndex, int rawAnswer) {
    double normalizedScore = 3.0; // デフォルトスコア
    // スライダー形式 (index 0-9)
    // ドロップダウン形式 (index 10-19)
    switch (questionIndex) {
      case 0: // Q1 履修コマ数 (0-25)
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
      case 1: // Q2 1限コマ数 (0-5)
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
      case 2: // Q3 週に飛んだ/代筆コマ数 (0-25) - 少ないほど高スコア（真面目）
        if (rawAnswer == 0)
          normalizedScore = 5.0; // 0回 -> 最高点
        else if (rawAnswer <= 2)
          normalizedScore = 4.0; // 1-2回 -> まだ許容範囲
        else if (rawAnswer <= 5)
          normalizedScore = 3.0; // 3-5回 -> 平均的？注意
        else if (rawAnswer <= 8)
          normalizedScore = 2.0; // 6-8回 -> 問題あり
        else
          normalizedScore = 1.0; // 9回以上 -> かなり問題
        break;
      // case 3 (旧代筆) は統合されたので削除
      case 3: // Q4 バイト回数 (旧Q5) (0-6)
        if (rawAnswer >= 5)
          normalizedScore = 5.0;
        else if (rawAnswer >= 3)
          normalizedScore = 4.0;
        else if (rawAnswer >= 1)
          normalizedScore = 3.0;
        else
          normalizedScore = 1.5; // 0回
        break;
      case 4: // Q5 サークル参加回数 (旧Q6) (0-5)
        if (rawAnswer >= 4)
          normalizedScore = 5.0;
        else if (rawAnswer >= 2)
          normalizedScore = 3.5;
        else if (rawAnswer == 1)
          normalizedScore = 2.0;
        else
          normalizedScore = 1.0; // 0回
        break;
      case 5: // Q6 空きコマ数 (旧Q7) (0-10) - 少ないほど高スコア
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
      case 6:
      case 7:
      case 8:
      case 9: // Q7-Q10 スライダー (1-10) (旧Q8-Q11)
        normalizedScore = ((rawAnswer - 1) / 9.0) * 4.0 + 1.0;
        break;
      // --- ドロップダウン形式の質問の正規化 (インデックス 10-19) ---
      case 10: // Q11 未知の体験 (旧Q12)
        const scores = [1.0, 3.5, 5.0, 1.5]; // A不安, B興味, Cワクワク, D様子見
        normalizedScore = scores[rawAnswer];
        break;
      case 11: // Q12 計画と実行 (旧Q13)
        const scores = [5.0, 3.5, 4.5, 1.0]; // A完璧, B大まか, C即行動, D他者依存
        normalizedScore = scores[rawAnswer];
        break;
      case 12: // Q13 興味関心 (旧Q14)
        const scores = [5.0, 4.5, 4.0, 1.0]; // A深く狭く, B広く浅く, C実用的, D興味薄
        normalizedScore = scores[rawAnswer];
        break;
      case 13: // Q14 困難への対処 (旧Q15)
        const scores = [4.5, 4.0, 3.5, 1.0]; // A根性, B分析, C相談, D回避
        normalizedScore = scores[rawAnswer];
        break;
      case 14: // Q15 活動時間帯 (旧Q16)
        const scores = [4.5, 3.0, 3.5, 5.0, 3.5]; // A朝, B日中, C夕夜, D深夜, E不定
        normalizedScore = scores[rawAnswer];
        break;
      case 15: // Q16 ゆるい授業中 (旧Q17)
        const scores = [4.0, 1.5, 3.5, 1.0]; // A聞く, Bゲーム, C他課題, D寝る
        normalizedScore = scores[rawAnswer];
        break;
      case 16: // Q17 価値観/動機 (新規)
        // A安定秩序, B知的好奇, C実利成果, D新規経験, E困難克服, Fストレス回避
        const scores_q17 = [3.5, 4.5, 4.0, 5.0, 4.0, 1.5];
        normalizedScore = scores_q17[rawAnswer];
        break;
      case 17: // Q18 グループワークリスク (新規)
        // A挑戦, B堅実, C様子見, D回避
        const scores_q18 = [5.0, 3.0, 2.0, 1.0];
        normalizedScore = scores_q18[rawAnswer];
        break;
      case 18: // Q19 エネルギー回復 (新規)
        // A一人趣味, B仲間ワイワイ, C寝る, D新規活動
        const scores_q19 = [4.0, 4.0, 2.0, 5.0];
        normalizedScore = scores_q19[rawAnswer];
        break;
      case 19: // Q20 1ヶ月自由時間 (新規)
        // A壮大計画, B研究創作, Cビジネス人脈, D体動かす, Eのんびり, F気分で
        const scores_q20 = [4.5, 4.5, 4.0, 4.0, 1.0, 5.0];
        normalizedScore = scores_q20[rawAnswer];
        break;
    }
    return max(0.5, min(5.0, normalizedScore));
  }

  double _normalizeInverse(int questionIndex, int rawAnswer) {
    double normalizedScore = _normalizeAnswer(questionIndex, rawAnswer);
    return 6.0 - normalizedScore;
  }

  String _diagnoseCharacter(List<int> currentAnswers) {
    if (currentAnswers.length != 20) {
      // ★ 20問に対応
      return "エラー：回答数が不足しています";
    }
    List<double> norm = List.generate(
      currentAnswers.length,
      (i) => _normalizeAnswer(i, currentAnswers[i]),
    );

    // Q1(総履修コマ数) と Q3(飛んだ/代筆コマ数) から「実質的欠席率スコア」を計算
    double totalClasses = currentAnswers[0].toDouble(); // Q1の回答
    double skippedOrDaipitsuRaw = currentAnswers[2].toDouble(); // Q3の回答 (0-25)

    double effectiveSkippedPercentage =
        (totalClasses > 0)
            ? (skippedOrDaipitsuRaw / totalClasses)
            : (skippedOrDaipitsuRaw > 0 ? 1.0 : 0.0);

    double nonAttendanceScore; // このスコアが高いほど良い (欠席/代筆が少ない)
    if (effectiveSkippedPercentage == 0)
      nonAttendanceScore = 5.0;
    else if (effectiveSkippedPercentage <= 0.1)
      nonAttendanceScore = 4.0; // 10%以下
    else if (effectiveSkippedPercentage <= 0.25)
      nonAttendanceScore = 3.0; // 11-25%
    else if (effectiveSkippedPercentage <= 0.50)
      nonAttendanceScore = 2.0; // 26-50%
    else
      nonAttendanceScore = 1.0; // 51%以上

    // --- 各キャラクタースコア計算 (20問対応、バランス調整) ---
    // Q1(norm[0])の直接的な影響はほぼ無くす

    double knightScore = 0;
    double baseKnightFactor = 1.0;
    if (norm[8] < 2.5 || norm[6] < 2.5) {
      // Q9モチベかQ7集中力が低い
      baseKnightFactor = 0.4;
    }
    knightScore += norm[1] * 0.5 * baseKnightFactor; // Q2 1限
    knightScore += norm[4] * 0.7 * baseKnightFactor; // Q5サークル
    knightScore += norm[6] * 0.8 * baseKnightFactor; // Q7集中力
    knightScore += norm[7] * 0.7 * baseKnightFactor; // Q8ストレス耐性
    knightScore += norm[8] * 1.0; // Q9モチベ
    knightScore += norm[5] * 0.4 * baseKnightFactor; // Q6空きコマ少ない
    if (currentAnswers[11] == 0 && norm[8] >= 3.0)
      knightScore += norm[11] * 1.8; // Q12計画(A)
    else if (currentAnswers[11] == 1 && norm[8] >= 2.5)
      knightScore += norm[11] * 1.3; // Q12計画(B)
    if (currentAnswers[13] == 1 && norm[8] >= 2.5)
      knightScore += norm[13] * 1.5; // Q14困難(B)
    knightScore += nonAttendanceScore * 1.5; // ★Q3(統合版)欠席/代筆少ない (重要度アップ)
    if (currentAnswers[15] == 0) knightScore += norm[15] * 1.0; // Q16ゆる授業(A:聞く)
    if (currentAnswers[16] == 0)
      knightScore += norm[16] * 0.8; // Q17価値観(A:安定秩序)
    if (currentAnswers[17] == 1) knightScore += norm[17] * 0.7; // Q18リスク(B:堅実)
    if (currentAnswers[19] == 0)
      knightScore += norm[19] * 0.6; // Q20自由時間(A:壮大計画)

    double witchScore = 0;
    witchScore += norm[6] * 2.5; // Q7集中力
    if (currentAnswers[12] == 0) witchScore += norm[12] * 2.0; // Q13興味(A:深く狭く)
    if (currentAnswers[14] == 3) witchScore += norm[14] * 2.0; // Q15活動(D:深夜)
    if (norm[1] <= 2.0) witchScore += (6.0 - norm[1]) * 0.8;
    witchScore += norm[8] * 1.0; // Q9モチベ
    if (norm[4] <= 2.0) witchScore += (6.0 - norm[4]) * 0.5; // Q5サークル少ない
    if (norm[3] <= 2.0) witchScore += (6.0 - norm[3]) * 0.3; // Q4バイト少ない
    if (currentAnswers[15] == 2) witchScore += norm[15] * 0.7; // Q16ゆる授業(C:他課題)
    if (currentAnswers[16] == 1) witchScore += norm[16] * 1.2; // Q17価値観(B:知的好奇)
    if (currentAnswers[18] == 0)
      witchScore += norm[18] * 0.8; // Q19エネルギー(A:一人趣味)
    if (currentAnswers[19] == 1)
      witchScore += norm[19] * 1.0; // Q20自由時間(B:研究創作)

    double merchantScore = 0;
    merchantScore += norm[3] * 1.8; // Q4バイト
    merchantScore += _normalizeInverse(5, currentAnswers[5]) * 1.2; // Q6空きコマ多い
    if (currentAnswers[12] == 2)
      merchantScore += norm[12] * 1.8; // Q13興味(C:実用的)
    merchantScore += norm[9] * 1.0; // Q10忙しさ
    if (currentAnswers[13] == 2) merchantScore += norm[13] * 1.5; // Q14困難(C:相談)
    if (currentAnswers[11] == 1)
      merchantScore += norm[11] * 1.0; // Q12計画(B:大まか)
    if (currentAnswers[15] == 2)
      merchantScore += norm[15] * 2.0; // Q16ゆる授業(C:他課題)
    if (currentAnswers[16] == 2)
      merchantScore += norm[16] * 1.2; // Q17価値観(C:実利)
    if (currentAnswers[17] == 1 || currentAnswers[17] == 2)
      merchantScore += norm[17] * 0.7; // Q18リスク(B堅実/C様子見)
    if (currentAnswers[18] == 1)
      merchantScore += norm[18] * 0.8; // Q19エネルギー(B:仲間)
    if (currentAnswers[19] == 2)
      merchantScore += norm[19] * 1.0; // Q20自由時間(C:ビジネス)

    double gorillaScore = 0;
    if (currentAnswers[14] == 0) gorillaScore += norm[14] * 1.4; // Q15活動(A:早朝)
    gorillaScore += norm[1] * 0.9; // Q2 1限
    gorillaScore += norm[7] * 1.3; // Q8ストレス
    gorillaScore += norm[8] * 1.1; // Q9モチベ
    gorillaScore += norm[4] * 1.0; // Q5サークル
    if (currentAnswers[13] == 0) gorillaScore += norm[13] * 2.2; // Q14困難(A:根性)
    gorillaScore += nonAttendanceScore * 0.8;
    if (currentAnswers[15] == 3)
      gorillaScore -= 0.3;
    else if (currentAnswers[15] == 0)
      gorillaScore += 0.7;
    if (currentAnswers[16] == 4)
      gorillaScore += norm[16] * 1.0; // Q17価値観(E:困難克服)
    if (currentAnswers[18] == 1 || currentAnswers[18] == 2)
      gorillaScore += norm[18] * 0.7; // Q19エネルギー(B仲間/C寝る)
    if (currentAnswers[19] == 3)
      gorillaScore += norm[19] * 1.2; // Q20自由時間(D:体動かす)

    double adventurerScore = 0;
    if (currentAnswers[10] == 2)
      adventurerScore += norm[10] * 2.0; // Q11未知(C:ワクワク)
    else if (currentAnswers[10] == 1)
      adventurerScore += norm[10] * 1.2;
    if (currentAnswers[11] == 2)
      adventurerScore += norm[11] * 2.0; // Q12計画(C:即行動)
    else if (currentAnswers[11] == 1)
      adventurerScore += norm[11] * 1.0;
    if (currentAnswers[12] == 1)
      adventurerScore += norm[12] * 1.8; // Q13興味(B:広く浅く)
    adventurerScore +=
        _normalizeInverse(5, currentAnswers[5]) * 2.0; // Q6空きコマ多い
    if (currentAnswers[11] == 0) adventurerScore -= 1.5; // Q12計画(A:完璧)はマイナス
    if (currentAnswers[14] == 4)
      adventurerScore += norm[14] * 2.0; // Q15活動(E:不定)
    if (currentAnswers[15] == 1)
      adventurerScore += norm[15] * 1.2; // Q16ゆる授業(B:ゲーム)
    if (currentAnswers[16] == 3)
      adventurerScore += norm[16] * 1.5; // Q17価値観(D:新規経験)
    if (currentAnswers[17] == 0)
      adventurerScore += norm[17] * 1.0; // Q18リスク(A:挑戦)
    if (currentAnswers[18] == 3)
      adventurerScore += norm[18] * 1.2; // Q19エネルギー(D:新規活動)
    if (currentAnswers[19] == 0 || currentAnswers[19] == 5)
      adventurerScore += norm[19] * 1.0; // Q20自由時間(A壮大計画/F気分で)
    if (nonAttendanceScore <= 2.5) adventurerScore -= 1.0;

    // --- レアキャラ判定 ---
    double godScoreSum = 0;
    // Q2, Q5(サークル), Q7(集中), Q8(ストレス), Q9(モチベ)
    List<int> godCriteriaIndices = [1, 4, 6, 7, 8];
    for (int idx in godCriteriaIndices) {
      godScoreSum += norm[idx];
    }
    if (currentAnswers[11] == 0) godScoreSum += norm[11]; // Q12計画(A)
    if (currentAnswers[13] == 1) godScoreSum += norm[13]; // Q14困難(B)
    godScoreSum += nonAttendanceScore; // Q3(統合版)欠席/代筆ほぼなし
    if (currentAnswers[15] == 0) godScoreSum += norm[15]; // Q16ゆる授業(A:聞く)
    // 新しい質問も神の判定に加味
    if (currentAnswers[16] == 0 || currentAnswers[16] == 4)
      godScoreSum += norm[16]; // Q17価値観(A安定秩序 or E困難克服)
    if (currentAnswers[17] == 0) godScoreSum += norm[17]; // Q18リスク(A挑戦)
    // 11項目。平均4.3で約47.3点
    if (godScoreSum >= 47.0) {
      return "神";
    }

    double reCalclulatedLoserScore = 0;
    reCalclulatedLoserScore += _normalizeInverse(
      1,
      currentAnswers[1],
    ); // Q2 1限少ない
    reCalclulatedLoserScore +=
        (6.0 - nonAttendanceScore) * 3.5; // ★Q3(統合版)欠席/代筆多い(超超重要)
    reCalclulatedLoserScore +=
        _normalizeInverse(5, currentAnswers[5]) * 1.5; // Q6空きコマ多い
    reCalclulatedLoserScore +=
        _normalizeInverse(6, currentAnswers[6]) * 1.2; // Q7集中力低い
    reCalclulatedLoserScore += _normalizeInverse(
      7,
      currentAnswers[7],
    ); // Q8ストレス低い
    reCalclulatedLoserScore +=
        (currentAnswers[11] == 3
            ? 5.0
            : (norm[11] <= 2.0 ? 3.0 : 1.0)); // Q12計画 D or 低い
    reCalclulatedLoserScore +=
        _normalizeInverse(8, currentAnswers[8]) * 1.5; // Q9モチベ低い
    reCalclulatedLoserScore +=
        (currentAnswers[13] == 3
            ? 5.0
            : (norm[13] <= 2.0 ? 3.0 : 1.0)); // Q14困難 D or 低い
    if (currentAnswers[15] == 1 || currentAnswers[15] == 3)
      reCalclulatedLoserScore += 5.0; // Q16ゆる授業(Bゲーム or D寝る)
    // 新しい質問もカス大学生の判定に加味
    if (currentAnswers[16] == 5)
      reCalclulatedLoserScore += norm[16] * 1.2; // Q17価値観(F:ストレス回避)
    if (currentAnswers[17] == 3)
      reCalclulatedLoserScore += norm[17] * 1.2; // Q18リスク(D:回避)
    if (currentAnswers[18] == 2)
      reCalclulatedLoserScore += norm[18] * 1.0; // Q19エネルギー(C:寝る)
    if (currentAnswers[19] == 4 || currentAnswers[19] == 5)
      reCalclulatedLoserScore += norm[19] * 1.2; // Q20自由時間(Eのんびり/F気分で)
    // 閾値調整 (13項目。平均4.0で52点)
    if (reCalclulatedLoserScore >= 50.0 ||
        ((6.0 - nonAttendanceScore) >= 4.5 &&
            reCalclulatedLoserScore >= 45.0)) {
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
    double maxScore = -double.infinity; // 特徴がない場合も何かは選ばれるように

    // スコアが著しく低い場合のフォールバックを調整
    bool allScoresVeryLow = true;
    scores.forEach((key, value) {
      if (value >= 8.0) {
        // 何かしらのキャラに8点以上のスコアがないと特徴薄いと判断する閾値（要調整）
        allScoresVeryLow = false;
      }
    });

    if (allScoresVeryLow &&
        finalCharacter != "神" &&
        finalCharacter != "カス大学生") {
      // 特徴が薄い場合、どのキャラにも強く当てはまらない。
      // このような場合に、以前は剣士がデフォルトで選ばれやすかった。
      // ここでは、敢えて特定のキャラにせず、例えば「平凡な大学生」のようなタイプを返すか、
      // あるいは、最もましなスコアのキャラにする。
      // 今回は、最も高いスコアが非常に低い場合でも、そのキャラを返す。
      // (ただし、剣士のスコア計算でモチベ低いと点が伸びないようにしているので、デフォルト剣士は減るはず)
    }

    scores.forEach((character, score) {
      double effectiveScore = max(0, score); // マイナススコアは0点扱い
      if (effectiveScore > maxScore) {
        maxScore = effectiveScore;
        finalCharacter = character;
      }
    });
    return finalCharacter;
  }

  Widget _buildQuestionWidget(int index) {
    // ... (変更なし) ...
    if (index <= 9) {
      // スライダーはQ1～Q10 (インデックス0～9)
      bool isOneBased = (index >= 6 && index <= 9); // Q7～Q10 (1-10スケール)
      double minVal = isOneBased ? 1.0 : 0.0;
      if (index == 2) {
        // Q3 (飛んだ/代筆コマ数) も0始まり
        minVal = 0.0;
        isOneBased = false;
      }
      int divisionsVal = maxValues[index] - (isOneBased ? 1 : 0);
      if (index == 2) {
        // Q3 の divisions
        divisionsVal = maxValues[index];
      }
      if (divisionsVal <= 0) divisionsVal = 1;

      return Column(
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
              200,
              27,
              128,
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
      // ドロップダウンはQ11～Q20 (インデックス10～19)
      final options = questionOptions[index] ?? [];
      int currentValue = answers[index];
      if (currentValue >= options.length) {
        currentValue = 0;
      }
      return Column(
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
        title: Text('キャラ診断 ver5.0'),
        backgroundColor: Colors.brown,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        // ... (変更なし) ...
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
                              (context) => CharacterDecidePage(
                                answers: answers,
                                diagnosedCharacterName: characterName,
                              ),
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
