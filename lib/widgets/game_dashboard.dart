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
    
    // 診断状況に応じたフィードバック
    String diagnosisText;
    Color diagnosisColor;
    if (isDiagnosisKnown) {
      diagnosisText = '✅ 診断確定済: De-escalation チャンス!';
      diagnosisColor = Colors.green.shade700;
    } else {
      diagnosisText = '🔍 診断まで: ${gameState.turnsUntilDiagnosis}ターン';
      diagnosisColor = Colors.orange;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('敵 (推測): ${gameState.currentEnemy.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('感受性: ${gameState.currentSensitivityScore.toStringAsFixed(2)}', style: TextStyle(color: gameState.currentSensitivityScore < 0.5 ? Colors.red : Colors.grey)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(diagnosisText, style: TextStyle(color: diagnosisColor, fontWeight: FontWeight.bold, fontSize: 13)),
            Text('原則遵守点: ${gameState.principleComplianceScore}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
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
        _buildMeter('重症度', gameState.currentSeverity, 100, 70, Colors.red),
        _buildMeter('耐性リスク', gameState.currentResistanceRisk, 10, 5.0, Colors.orange),
        _buildMeter('副作用コスト', gameState.currentSideEffectCost, 70, 50, Colors.blue),
      ],
    );
  }

  Widget _buildMeter(String title, double value, double max, double alertThreshold, Color baseColor) {
    final bool isAlert = value >= alertThreshold;
    final double normalizedValue = (value / max).clamp(0.0, 1.0);
    
    // アラート時の色とアニメーション
    Color progressColor = isAlert ? Colors.redAccent : baseColor;

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          // 重症度アラートアニメーション（点滅効果をシミュレート）
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: 8,
            child: LinearProgressIndicator(
              value: normalizedValue,
              backgroundColor: isAlert ? progressColor.withOpacity(0.3) : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title == '重症度' ? '${value.toInt()}%' : value.toStringAsFixed(1), 
            style: TextStyle(color: progressColor, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}