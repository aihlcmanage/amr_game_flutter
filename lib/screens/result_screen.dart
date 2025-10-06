import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import 'case_selection_screen.dart'; // 症例選択画面に戻るため

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);

    // スコア計算の仮ロジック
    final isSuccess = state.currentSeverity <= 10.0 && state.currentTurn >= 3;
    final baseScore = isSuccess ? 1000 : 0;
    final turnPenalty = state.currentTurn * 10;
    final costPenalty = state.currentSideEffectCost.toInt();
    final totalScore = baseScore + state.principleComplianceScore - turnPenalty - costPenalty;
    
    // 結果メッセージ
    String resultMessage;
    Color resultColor;

    if (isSuccess) {
      resultMessage = '✅ 治療成功！優れた判断でした。';
      resultColor = Colors.green.shade700;
    } else if (state.currentSeverity >= 100.0) {
      resultMessage = '🚨 治療失敗... 重症度が回復しませんでした。';
      resultColor = Colors.red.shade700;
    } else {
      resultMessage = '⚠️ 治療長期化... ターン制限を超過しました。';
      resultColor = Colors.orange.shade700;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('治療結果と評価'),
        automaticallyImplyLeading: false, // 戻るボタンを非表示
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined, size: 60, color: resultColor),
                  const SizedBox(height: 16),
                  Text(
                    resultMessage,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: resultColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildScoreRow('総合スコア', totalScore.toString(), totalScore >= 500 ? Colors.blue : Colors.red),
                  _buildScoreRow('ターン数', state.currentTurn.toString(), Colors.black),
                  _buildScoreRow('副作用コスト', state.currentSideEffectCost.toStringAsFixed(1), Colors.red),
                  _buildScoreRow('原則遵守ボーナス', state.principleComplianceScore.toString(), Colors.green),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // 症例選択画面に戻る (GameScreenはスタックから削除済み)
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const CaseSelectionScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('次の症例へ進む / 選択画面へ', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildScoreRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
