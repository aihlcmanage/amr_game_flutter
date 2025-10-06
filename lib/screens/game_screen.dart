import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../widgets/game_dashboard.dart'; 
import '../widgets/action_cards.dart';   
import '../widgets/log_panel.dart';      
import 'result_screen.dart'; // ステップ7で作成

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GameStateとGameNotifierを監視
    final gameState = ref.watch(gameNotifierProvider);
    final isGameOver = ref.read(gameNotifierProvider.notifier).isGameOver; 

    // ゲームオーバー判定と画面遷移
    if (isGameOver) {
      // ゲーム終了処理と画面遷移
      // Future.microtask を使用して build メソッド完了後に遷移を確実に行う
      Future.microtask(() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ResultScreen())));
      return const Scaffold(body: Center(child: Text('治療結果を評価中...')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('治療ターン: ${gameState.currentTurn} - ${gameState.currentCase.name}'),
        automaticallyImplyLeading: false, // 戻るボタンを非表示
      ),
      body: Column(
        children: [
          // 画面上部：リスクメーター
          GameDashboard(gameState: gameState),
          
          // 中央：敵と情報ログ
          Expanded(child: LogPanel(logMessages: gameState.logMessages)),
          
          // 画面下部：アクションバー（投薬選択）
          ActionCards(gameState: gameState),
          
          // 常時表示される安全確認メッセージ
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('※ 本画面はシミュレーションです。現実の治療判断には使用できません。', style: TextStyle(color: Colors.grey, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}