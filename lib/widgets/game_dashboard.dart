import 'package:flutter/material.dart';
import '../state/game_state.dart';

class GameDashboard extends StatelessWidget {
  final GameState gameState;
  const GameDashboard({required this.gameState, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoPanel(context),
          const SizedBox(height: 10),
          _buildRiskMeters(),
        ],
      ),
    );
  }

  // 患者情報と診断状況の表示
  Widget _buildInfoPanel(BuildContext context) {
    final bool isDiagnosisKnown = gameState.turnsUntilDiagnosis <= 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('敵 (初期推測): ${gameState.currentEnemy.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('感受性スコア: ${gameState.currentSensitivityScore.toStringAsFixed(2)}', style: TextStyle(color: isDiagnosisKnown ? Colors.red : Colors.grey)),
            Text('患者制約: ${gameState.currentCase.renalFunctionPenalty > 1.0 ? '腎機能低下' : '標準'}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(isDiagnosisKnown ? '診断確定済' : '診断まで: ${gameState.turnsUntilDiagnosis}T',
                style: TextStyle(color: isDiagnosisKnown ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
            Text('原則遵守点: ${gameState.principleComplianceScore}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  // 3大リスクメーターの表示
  Widget _buildRiskMeters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMeter('重症度', gameState.currentSeverity, 100, Colors.red),
        _buildMeter('耐性リスク', gameState.currentResistanceRisk, 10, Colors.orange),
        _buildMeter('副作用コスト', gameState.currentSideEffectCost, 70, Colors.blue),
      ],
    );
  }

  Widget _buildMeter(String title, double value, double max, Color color) {
    // 視覚的な進捗バーの最大値を max で設定
    final double normalizedValue = (value / max).clamp(0.0, 1.0);
    
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: normalizedValue,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text('${value.toInt()}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}