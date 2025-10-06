import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../widgets/game_dashboard.dart'; 
import '../widgets/action_cards.dart';   
import '../widgets/log_panel.dart';      
import '../widgets/enemy_display.dart'; 
import 'result_screen.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    
    // 状態変更を伴う可能性のあるisGameOverの呼び出しと画面遷移ロジックを、
    // ビルドサイクルの後に実行されるように遅延させる (Riverpodエラー回避の推奨手法)
    Future.microtask(() {
      final notifier = ref.read(gameNotifierProvider.notifier);
      if (notifier.isGameOver) {
        // ゲームオーバーが確定したら、ResultScreenへ遷移
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ResultScreen()));
      }
    });

    // ゲームオーバーが確定した場合、遷移が完了するまでの間はローディング画面を表示
    if (ref.read(gameNotifierProvider.notifier).isGameOver) {
        return const Scaffold(body: Center(child: Text('治療結果を評価中...')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('治療ターン: ${gameState.currentTurn} - ${gameState.currentCase.name}'),
        automaticallyImplyLeading: false, 
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.flag, color: Colors.grey),
            label: const Text('ギブアップ', style: TextStyle(color: Colors.grey, fontSize: 13)),
            onPressed: () {
              ref.read(gameNotifierProvider.notifier).surrender();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          GameDashboard(gameState: gameState),
          EnemyDisplay(gameState: gameState),
          Expanded(
            child: LogPanel(logMessages: gameState.logMessages),
          ),
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