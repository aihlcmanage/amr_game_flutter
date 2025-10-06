import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart'; 
import '../models/enums.dart'; 
import '../models/weapon_data.dart'; // WeaponDataとWEAPON_DATAの定義があることを期待
import 'result_screen.dart'; 
import 'case_selection_screen.dart'; 
import '../models/models.dart'; // AntibioticWeaponの型解決のため追加

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
              _buildWeaponActions(ref), // 兵器選択ボタン (横スクロール)
              const SizedBox(height: 20),
              _buildSupportActions(ref, state), // サポートボタン (並列配置)
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

  // ★修正: 兵器選択ボタンを横スクロールに戻す
  Widget _buildWeaponActions(WidgetRef ref) {
    
    // WEAPON_DATAをAntibioticWeapon型として取得
    final weapons = WEAPON_DATA.cast<AntibioticWeapon>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⚔️ 投薬アクション (兵器選択)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        
        // 横スクロール可能なListViewでボタンを並べる
        SizedBox(
          height: 50, // ボタンの高さに応じて調整
          child: ListView(
            scrollDirection: Axis.horizontal,
            // ❌ 存在しないspacingパラメーターを削除
            children: weapons.map((weapon) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0), // ボタン間のスペース
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(gameNotifierProvider.notifier).applyTreatment(weapon); 
                  },
                  // カテゴリの色付けは保持する
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(weapon.category), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16), // 横幅を節約
                  ),
                  child: Text(weapon.name, style: const TextStyle(fontSize: 14)), 
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  // カテゴリ名を日本語で返すヘルパー関数
  String _getCategoryName(WeaponCategory category) {
    // lib/models/enums.dartで定義されている Access, Watch, Reserve に修正
    switch (category) {
      case WeaponCategory.Access: 
        return 'Access (初動/軽装)';
      case WeaponCategory.Watch: 
        return 'Watch (監視/中等度)';
      case WeaponCategory.Reserve: 
        return 'Reserve (最終/重篤)';
      default:
        // 未定義のカテゴリをnameで表示
        return category.name; 
    }
  }

  // カテゴリごとに色を返すヘルパー関数
  Color _getCategoryColor(WeaponCategory category) {
    // lib/models/enums.dartで定義されている Access, Watch, Reserve に修正
    switch (category) {
      case WeaponCategory.Access: 
        return Colors.green.shade600;
      case WeaponCategory.Watch: 
        return Colors.blue.shade600;
      case WeaponCategory.Reserve: 
        return Colors.red.shade600; // Reserveは危険度が高いので赤系に
      default:
        return Colors.grey;
    }
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
