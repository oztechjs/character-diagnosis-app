import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 追加
import 'firebase_options.dart'; // 追加
import 'character_question_page.dart'; // あなたの質問ページのパス

void main() async {
  // async に変更
  WidgetsFlutterBinding.ensureInitialized(); // 追加
  await Firebase.initializeApp(
    // 追加
    options: DefaultFirebaseOptions.currentPlatform, // 追加
  ); // 追加
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'キャラクター診断 ver3.0',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        // スライダーのポップアップラベルの文字色などを設定
        sliderTheme: SliderThemeData(
          valueIndicatorTextStyle: TextStyle(color: Colors.white),
          valueIndicatorColor: Colors.orange[700]?.withOpacity(0.8),
        ),
      ),
      home: CharacterQuestionPage(), // 最初のページ
    );
  }
}
