import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart'; 
import '../models/enums.dart'; 
import '../models/weapon_data.dart'; 
import 'result_screen.dart'; 
import 'case_selection_screen.dart'; 

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // GameState全体を監視
    final state = ref.watch(gameNotifierProvider);

    // ----------------------------------------------------
    // 【重要】isGameOver状態の監視と画面遷移ロジック
    // ----------------------------------------------------
    // Notifierのインスタンスを取得
    final notifier = ref.read(gameNotifierProvider.notifier);

    // isGameOverの状態だけを監視
    ref.listen<bool>(
      gameNotifierProvider.select((state) => notifier.isGameOver), // Notifierのゲッターを参照
      (previous, nextIsGameOver) {
        // nextIsGameOverがtrueになり、かつpreviousがfalseから変わった瞬間を捉える
        if (nextIsGameOver && !previous!) {
          
          // ゲーム終了時のログを記録
          notifier.recordEndGameLog();
          
          // 結果画面へ遷移し、ゲーム画面をスタックから削除
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ResultScreen()),
          );
        }
      },
    );


    return Scaffold(
      appBar: AppBar(
        title: Text('治療ターン: ${state.currentTurn} - ${state.currentCase.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: 'ギブアップ',
            // Notifierのゲッターを直接呼び出し
            onPressed: notifier.isGameOver ? null : () { 
              notifier.surrender();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ステータス表示エリア
            _buildStatusDisplay(state),
            const SizedBox(height: 20),
            
            // ログエリア
            _buildLogArea(state),
            const SizedBox(height: 20),
            
            // アクションボタンエリア
            // Notifierのゲッターを直接呼び出し
            if (!notifier.isGameOver) ...[ 
              _buildWeaponActions(ref),
              const SizedBox(height: 20),
              _buildSupportActions(ref, state),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'ゲーム終了！結果は自動的に評価されます。',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- UI Helper Functions ---

  Widget _buildStatusDisplay(GameState state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('症例: ${state.currentCase.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('標的菌: ${state.currentEnemy.name}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('重症度: ${state.currentSeverity.toStringAsFixed(0)}% (目標 10%以下)'),
            Text('耐性リスク: ${state.currentResistanceRisk.toStringAsFixed(1)}'),
            Text('副作用コスト: ${state.currentSideEffectCost.toStringAsFixed(1)}'),
            Text('診断まで残り: ${state.turnsUntilDiagnosis}T', style: TextStyle(color: state.turnsUntilDiagnosis > 0 ? Colors.red : Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeaponActions(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⚔️ 兵器アクション (投薬)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: WEAPON_DATA.map((weapon) {
            return ElevatedButton(
              onPressed: () {
                ref.read(gameNotifierProvider.notifier).applyTreatment(weapon);
              },
              child: Text(weapon.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSupportActions(WidgetRef ref, GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🛠️ サポートアクション', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              // 診断が完了していない場合のみ「精密検査」ボタンを有効にする
              onPressed: state.turnsUntilDiagnosis > 0 ? () {
                ref.read(gameNotifierProvider.notifier).performSupportAction(SupportAction.Inspection);
              } : null,
              child: const Text('精密検査'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                ref.read(gameNotifierProvider.notifier).performSupportAction(SupportAction.SourceControl);
              },
              child: const Text('感染源制御'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogArea(GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📋 治療ログ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListView.builder(
            reverse: true, 
            itemCount: state.logMessages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(state.logMessages[index], style: const TextStyle(fontSize: 12)),
              );
            },
          ),
        ),
      ],
    );
  }
}
