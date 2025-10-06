import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../widgets/game_dashboard.dart'; 
import '../widgets/action_cards.dart';   
import '../widgets/log_panel.dart';      
import '../widgets/enemy_display.dart'; // ★追加
import 'result_screen.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final isGameOver = ref.read(gameNotifierProvider.notifier).isGameOver; 

    // ゲームオーバー判定と画面遷移
    if (isGameOver) {
      Future.microtask(() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ResultScreen())));
      return const Scaffold(body: Center(child: Text('治療結果を評価中...')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('治療ターン: ${gameState.currentTurn} - ${gameState.currentCase.name}'),
        automaticallyImplyLeading: false, 
      ),
      body: Column(
        children: [
          // 画面上部：リスクメーター
          GameDashboard(gameState: gameState),
          
          // 中央上部: 敵のイメージ表示 (視覚化) ★追加
          EnemyDisplay(gameState: gameState),

          // 中央下部：情報ログ
          Expanded(child: LogPanel(logMessages: gameState.logMessages)),
          
          // 画面下部：アクションバー（投薬選択）
          ActionCards(gameState: gameState),
          
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('※ 本画面はシミュレーションです。現実の治療判断には使用できません。', style: TextStyle(color: Colors.grey, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}