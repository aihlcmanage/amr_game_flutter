import '../models/models.dart';
import '../models/enums.dart'; // WeaponCategoryの型に必要

class GameState {
  final PatientCase currentCase;             // 現在の症例データ
  final BacterialEnemy currentEnemy;         // 現在の敵データ
  
  final double currentSeverity;              // 現在の重症度 (0〜100)
  final double currentResistanceRisk;        // 現在の耐性リスクゲージ (累積値)
  final double currentSideEffectCost;        // 現在の副作用コスト (累積値)
  final double currentSensitivityScore;      // 現在の敵の感受性 (1.0から低下)
  
  final int currentTurn;                    // 現在のターン数
  final int turnsUntilDiagnosis;            // 検査結果までの残りターン
  final List<String> logMessages;           // 投薬結果やフィードバックのログ
  final int principleComplianceScore;       // 原則遵守ポイント
  final WeaponCategory? lastWeaponCategory; // ★修正: 直前の武器カテゴリ

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
    this.lastWeaponCategory,
  });
  
  // 状態を変更するためのコピーメソッド (copyWithを完全に実装)
  GameState copyWith({
    PatientCase? currentCase,
    BacterialEnemy? currentEnemy,
    double? currentSeverity,
    double? currentResistanceRisk,
    double? currentSideEffectCost,
    double? currentSensitivityScore,
    int? currentTurn,
    int? turnsUntilDiagnosis,
    List<String>? logMessages,
    int? principleComplianceScore,
    WeaponCategory? lastWeaponCategory,
  }) {
    return GameState(
      currentCase: currentCase ?? this.currentCase,
      currentEnemy: currentEnemy ?? this.currentEnemy,
      currentSeverity: currentSeverity ?? this.currentSeverity,
      currentResistanceRisk: currentResistanceRisk ?? this.currentResistanceRisk,
      currentSideEffectCost: currentSideEffectCost ?? this.currentSideEffectCost,
      currentSensitivityScore: currentSensitivityScore ?? this.currentSensitivityScore,
      currentTurn: currentTurn ?? this.currentTurn,
      turnsUntilDiagnosis: turnsUntilDiagnosis ?? this.turnsUntilDiagnosis,
      logMessages: logMessages ?? this.logMessages,
      principleComplianceScore: principleComplianceScore ?? this.principleComplianceScore,
      lastWeaponCategory: lastWeaponCategory ?? this.lastWeaponCategory,
    );
  }
}