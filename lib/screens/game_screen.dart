import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../widgets/game_dashboard.dart'; 
import '../widgets/action_cards.dart'; 
import '../widgets/log_panel.dart'; 
import '../widgets/enemy_display.dart'; 
import 'result_screen.dart';

// ConsumerStatefulWidgetに変更
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // ゲームオーバー時の遷移を制御するフラグ
  bool _isNavigationPending = false; 

  @override
  void initState() {
    super.initState();
    
    // ウィジェットが描画された後に一度だけチェックを予約
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigateIfGameOver();
    });
  }

  // 状態が変更されたときにチェックを再予約
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // didChangeDependenciesは頻繁に呼び出されるため、setState内のロジックはここではなく
    // build後に予約したコールバック内で実行するのが安全
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndNavigateIfGameOver();
    });
  }
  
  // ゲームオーバー判定と遷移のロジック（ビルドサイクル外で実行される）
  void _checkAndNavigateIfGameOver() {
    // contextがマウントされていない場合や、既に遷移中の場合は処理しない
    if (!mounted || _isNavigationPending) return; 

    // Notifierを参照し、状態を取得
    final notifier = ref.read(gameNotifierProvider.notifier);
    
    if (notifier.isGameOver) {
      // 遷移処理中であることをマーク
      setState(() {
          _isNavigationPending = true; 
      });
      
      // ログ記録をここで実行
      notifier.recordEndGameLog();
      
      // ResultScreenへ遷移
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 状態の監視
    final gameState = ref.watch(gameNotifierProvider);
    
    // 遷移中は、結果評価中の画面を表示してユーザー操作を防ぐ
    if (_isNavigationPending) {
      return const Scaffold(body: Center(child: Text('治療結果を評価中...')));
    }

    // ギブアップボタンの処理
    final VoidCallback onSurrender = () {
        // Notifierの状態を変更し、ゲームオーバーを確定
        ref.read(gameNotifierProvider.notifier).surrender();
        // 状態変更後に、ビルド後に遷移チェックを確実に行う
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndNavigateIfGameOver();
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
            onPressed: onSurrender,
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
