import '../models/models.dart';

class GameState {
  final PatientCase currentCase;
  final BacterialEnemy currentEnemy;
  
  final double currentSeverity;              // 現在の重症度 (0〜100)
  final double currentResistanceRisk;        // 現在の耐性リスクゲージ (累積値)
  final double currentSideEffectCost;        // 現在の副作用コスト (累積値)
  final double currentSensitivityScore;      // 現在の敵の感受性 (1.0から低下)
  
  final int currentTurn;                    // 現在のターン数
  final int turnsUntilDiagnosis;            // 検査結果までの残りターン
  final List<String> logMessages;           // 投薬結果やフィードバックのログ
  final int principleComplianceScore;       // 原則遵守ポイント

  // コンストラクタ（初期化用）
  GameState({
    required this.currentCase,
    required this.currentEnemy,
    this.currentSeverity = 50.0,
    this.currentResistanceRisk = 0.0,
    this.currentSideEffectCost = 0.0,
    this.currentSensitivityScore = 1.0,
    this.currentTurn = 1,
    this.turnsUntilDiagnosis = 0,
    this.logMessages = const [],
    this.principleComplianceScore = 0,
  });
  
  // 状態を変更するためのコピーメソッド (Riverpod/Freezed使用を想定)
  GameState copyWith({
    // ... 各フィールドのコピーメソッド定義
  }) {
    return GameState(
      currentCase: currentCase,
      currentEnemy: currentEnemy,
      // ... 変更が必要なフィールドのみを上書き
      currentSeverity: currentSeverity,
      // ... 
    );
  }
}