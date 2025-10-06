import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../utils/scoring_calculator.dart';
import 'case_selection_screen.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final scoreResult = ScoringCalculator.calculateFinalScore(gameState);

    return Scaffold(
      appBar: AppBar(title: const Text('治療結果と評価')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              scoreResult['feedback'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 30),
            _buildScoreItem('総合スコア', scoreResult['totalScore'], Colors.teal),
            _buildScoreItem('基本救命点 (迅速性)', scoreResult['rescueScore'], Colors.green),
            _buildScoreItem('原則遵守ボーナス', scoreResult['principleBonus'], Colors.orange),
            _buildScoreItem('累積ペナルティ (リスク)', scoreResult['totalPenalty'], Colors.red),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 症例選択画面に戻る
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const CaseSelectionScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('次の症例に進む'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String title, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}