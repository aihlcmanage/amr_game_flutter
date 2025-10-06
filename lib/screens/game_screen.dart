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
    
    // ゲームオーバー判定と画面遷移ロジックを、ビルドサイクルの後に実行するように遅延
    Future.microtask(() {
      final notifier = ref.read(gameNotifierProvider.notifier);
      if (notifier.isGameOver) {
        
        // ★修正: 画面遷移の前に、分離したログ記録メソッドを呼び出す
        notifier.recordEndGameLog();
        
        // ResultScreenへ遷移
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ResultScreen()));
      }
    });

    // isGameOver判定が遅延されたため、ここではローディング画面を表示
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