import '../state/game_state.dart';

class ScoringCalculator {
  static Map<String, dynamic> calculateFinalScore(GameState state) {
    const double basePoints = 1000.0;
    
    // --- 1. 基本救命点 (迅速性) ---
    final double timePenalty = state.currentTurn * 50.0;
    final double rescueScore = basePoints - timePenalty;
    
    // --- 2. 原則遵守ボーナス ---
    final double principleBonus = state.principleComplianceScore.toDouble();
    
    // --- 3. 累積ペナルティ (リスク) ---
    final double sideEffectPenalty = state.currentSideEffectCost * 2.0;
    final double resistancePenalty = state.currentResistanceRisk * 50.0;
    
    // --- 4. 総合スコア ---
    final double finalScore = rescueScore + principleBonus - sideEffectPenalty - resistancePenalty;

    // --- 5. 教育的フィードバックの生成 (ロジック) ---
    String finalFeedback = '';
    if (state.currentSeverity >= 100) {
      finalFeedback = '治療失敗。重症度の管理が間に合いませんでした。迅速かつ強力な初期治療が必要でした。';
    } else if (state.currentResistanceRisk > 5.0) {
      finalFeedback = '治療成功。しかし、高リスク薬の多用により耐性リスクが過剰に蓄積しました。未来への負債です。';
    } else if (state.currentSideEffectCost > 50.0) {
      finalFeedback = '治療成功。しかし、副作用コストが高すぎます。患者背景（腎機能）を考慮した薬剤選択が必要です。';
    } else {
      finalFeedback = '✅ 優秀な治療です！迅速性、コスト効率、原則遵守のバランスが取れています。';
    }
    
    return {
      'totalScore': finalScore.toInt(),
      'rescueScore': rescueScore.toInt(),
      'principleBonus': principleBonus.toInt(),
      'totalPenalty': (sideEffectPenalty + resistancePenalty).toInt(),
      'feedback': finalFeedback,
    };
  }
}