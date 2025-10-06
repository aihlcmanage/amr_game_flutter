import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../widgets/game_dashboard.dart'; 
import '../widgets/action_cards.dart'; 
import '../widgets/log_panel.dart'; 
import '../widgets/enemy_display.dart'; 
import 'result_screen.dart';

// ConsumerStatefulWidgetを維持
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // State側では遷移制御フラグのみを保持
  bool _isNavigationPending = false; 

  @override
  void initState() {
    super.initState();
    
    // initState内でref.listenを使って状態変化を監視し、遷移処理を確実に行う
    // ★ 状態変化を監視するメインのロジックをここに移動
    final notifier = ref.read(gameNotifierProvider.notifier);

    // isGameOverの状態だけを監視
    ref.listen<bool>(
      // notifierのisGameOverゲッターの状態を監視
      gameNotifierProvider.select((state) => notifier.isGameOver),
      (previous, nextIsGameOver) {
        // nextIsGameOverがtrueになり、かつ遷移処理中でない場合に処理を実行
        if (nextIsGameOver && !_isNavigationPending) {
          
          // 遷移処理中であることをマーク
          // このsetStateはlistenコールバック内で安全に呼び出せる
          setState(() {
            _isNavigationPending = true; 
          });

          // ログ記録をここで実行
          notifier.recordEndGameLog();
          
          // ResultScreenへ遷移し、ゲーム画面をスタックから削除
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ResultScreen()),
          );
        }
      },
    );
  }

  // didChangeDependenciesと_checkAndNavigateIfGameOverは不要になるため削除（今回は残してあります）
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 依存関係の変更時に特に遷移の再チェックは不要
  }
  
  // _checkAndNavigateIfGameOverはref.listenに置き換わるため、ここでは残しますが、
  // 実際にはinitState内のref.listenが主な役割を果たします。
  void _checkAndNavigateIfGameOver() {
    // 監視ロジックがinitState内のref.listenに移ったため、このメソッドは事実上不要になりました。
    // 互換性のため残しますが、空にしておきます。
  }

  @override
  Widget build(BuildContext context) {
    // 状態の監視
    final gameState = ref.watch(gameNotifierProvider);
    
    // 遷移中は、結果評価中の画面を表示してユーザー操作を防ぐ
    if (_isNavigationPending) {
      return const Scaffold(body: Center(child: Text('治療結果を評価中...')));
    }
    
    // ゲームオーバー状態でもActionCardsが表示されないようにチェックを追加 (ActionCards内部にも必要ですが、保険として)
    if (ref.read(gameNotifierProvider.notifier).isGameOver) {
      // isNavigationPendingがtrueになるまでのわずかな時間、画面フリーズを防ぐためにローディング表示
      return const Scaffold(body: Center(child: Text('治療結果を評価中...')));
    }

    // ギブアップボタンの処理
    final VoidCallback onSurrender = () {
        // Notifierの状態を変更し、ゲームオーバーを確定
        ref.read(gameNotifierProvider.notifier).surrender();
        // ★ ギブアップ後、initStateのref.listenが即座にこれを検出して遷移処理を行う
        // ここでの addPostFrameCallback は不要になります
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('治療ターン: ${gameState.currentTurn} - ${gameState.currentCase.name}'),
        automaticallyImplyLeading: false, 
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.flag, color: Colors.grey),
            label: const Text('ギブアップ', style: TextStyle(color: Colors.grey, fontSize: 13)),
            // 既にゲームオーバーの場合はボタンを無効化
            onPressed: ref.read(gameNotifierProvider.notifier).isGameOver ? null : onSurrender, 
          ),
        ],
      ),
      body: Column(
        children: [
          // 外部ウィジェットを使用 (これらのウィジェットが定義されている必要があります)
          GameDashboard(gameState: gameState),
          EnemyDisplay(gameState: gameState),
          Expanded(
            child: LogPanel(logMessages: gameState.logMessages),
          ),
          // ActionCardsはゲームオーバー時に非表示にするロジックを内部に持つ必要がある
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
