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
    // initStateからref.listenを削除
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ここも不要
  }
  
  // このメソッドも使わないが、build内でチェックを行う
  void _checkAndNavigateIfGameOver() {
    // 監視ロジックがbuild/postFrameCallbackに移ったため、このメソッドは事実上不要になりました。
  }

  // ★ 遷移ロジックをビルド後に実行する
  void _performNavigationCheck(WidgetRef ref) {
    if (!mounted || _isNavigationPending) return;

    final notifier = ref.read(gameNotifierProvider.notifier);

    // isGameOverの状態を直接チェック
    if (notifier.isGameOver) {
      // 遷移処理中であることをマーク
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
  }


  @override
  Widget build(BuildContext context) {
    // 状態の監視
    final gameState = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier); // Notifierの参照も取得

    // ★ ビルドが完了した直後に画面遷移チェックを実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performNavigationCheck(ref);
    });
    
    // 遷移中は、結果評価中の画面を表示してユーザー操作を防ぐ
    if (_isNavigationPending) {
      return const Scaffold(body: Center(child: Text('治療結果を評価中...')));
    }
    
    // ゲームオーバー状態でもActionCardsが表示されないようにチェックを追加
    if (notifier.isGameOver) {
      // isNavigationPendingがtrueになるまでのわずかな時間、画面フリーズを防ぐためにローディング表示
      return const Scaffold(body: Center(child: Text('治療結果を評価中...')));
    }

    // ギブアップボタンの処理
    final VoidCallback onSurrender = () {
        // Notifierの状態を変更し、ゲームオーバーを確定
        notifier.surrender();
        // ギブアップ直後に遷移チェックを予約する
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _performNavigationCheck(ref);
        });
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
            onPressed: notifier.isGameOver ? null : onSurrender, 
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
