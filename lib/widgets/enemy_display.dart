import 'package:flutter/material.dart';
import '../state/game_state.dart';

class EnemyDisplay extends StatelessWidget {
  final GameState gameState;
  const EnemyDisplay({required this.gameState, super.key});

  @override
  Widget build(BuildContext context) {
    final double severity = gameState.currentSeverity;
    
    // 敵の色を決定: 重症度が高いほど赤く
    final Color enemyColor = Color.lerp(
      Colors.green.shade300, 
      Colors.red.shade700, 
      (severity / 100.0).clamp(0.0, 1.0)
    )!;
    
    // サイズを決定: 重症度が高いほど大きく (80%〜120%)
    final double normalizedSeverity = (severity - 50).clamp(0, 50) / 50; // 50〜100を0〜1に正規化
    final double scaleFactor = 0.8 + (normalizedSeverity * 0.4); 
    
    // 80%を超えたら背景に危険アラート色を出す
    final Color backgroundColor = severity >= 80 
      ? Colors.red.withOpacity(0.15) 
      : Colors.grey.shade50;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 敵のシンボル表示（例: 🦠 アイコン）
          AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: scaleFactor,
            curve: Curves.easeOut,
            child: Icon(
              Icons.blur_circular, // バクテリアのイメージとして
              size: 80.0,
              color: enemyColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '標的菌 (推測): ${gameState.currentEnemy.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '重症度目標: 10%以下',
            style: TextStyle(fontSize: 12, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }
}