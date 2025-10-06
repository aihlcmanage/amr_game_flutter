import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../models/enums.dart';
import '../utils/logic_calculator.dart';
import 'game_state.dart';

// GameNotifierのインスタンスを提供するProvider
final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final initialCase = CASE_DATA.first;
  final initialEnemy = ENEMY_DATA.firstWhere((e) => e.id == initialCase.enemyId);

  return GameNotifier(
    GameState(
      currentCase: initialCase,
      currentEnemy: initialEnemy,
      currentSeverity: initialCase.initialSeverity,
      turnsUntilDiagnosis: initialCase.diagnosisDelayTurns,
      currentResistanceRisk: initialCase.resistanceStartBoost,
      currentSensitivityScore: initialEnemy.initialSensitivityScore,
    ),
  );
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(GameState initialState) : super(initialState);
  
  // --------------------------------------------------
  // ゲッター (勝利・敗北判定)
  // --------------------------------------------------
  bool get isGameOver {
    if (state.currentSeverity >= 100.0) {
      return true;
    }
    if (state.currentSeverity <= 10.0 && state.currentTurn >= 3) {
      return true;
    }
    return false;
  }
  
  // --------------------------------------------------
  // 1. ゲームの初期化
  // --------------------------------------------------

  void startGame(PatientCase selectedCase) {
    final initialEnemy = ENEMY_DATA.firstWhere((e) => e.id == selectedCase.enemyId);
    
    state = GameState(
      currentCase: selectedCase,
      currentEnemy: initialEnemy,
      currentSeverity: selectedCase.initialSeverity,
      turnsUntilDiagnosis: selectedCase.diagnosisDelayTurns,
      currentResistanceRisk: selectedCase.resistanceStartBoost,
      currentSensitivityScore: initialEnemy.initialSensitivityScore,
      currentTurn: 1,
      logMessages: ['ゲーム開始: ${selectedCase.name} の治療が始まりました。'],
      principleComplianceScore: 0,
      lastWeaponCategory: null,
    );
  }

  // --------------------------------------------------
  // 2. 投薬アクション
  // --------------------------------------------------

  void applyTreatment(AntibioticWeapon weapon) {
    if (isGameOver) return;

    final currentEnemy = state.currentEnemy;
    final currentCase = state.currentCase;
    
    // --- (A) ダメージとコストの計算 ---
    final double finalDamage = LogicCalculator.calculateDamage(
      weapon: weapon, 
      enemy: currentEnemy, 
      currentSensitivity: state.currentSensitivityScore,
      currentCase: currentCase,
    );
    final double costIncrease = LogicCalculator.calculateSideEffectCost(
      weapon: weapon, 
      currentCase: currentCase,
    );
    
    // --- (B) 耐性獲得とリスクの計算 ---
    final double riskIncrease = LogicCalculator.calculateResistanceRiskIncrease(
      weapon: weapon,
      enemy: currentEnemy,
    );
    final double newResistanceRisk = state.currentResistanceRisk + riskIncrease;
    
    // リスク蓄積後の感受性低下判定
    final double newSensitivity = LogicCalculator.calculateNewSensitivity(
      newResistanceRisk, 
      state.currentSensitivityScore,
    );
    
    // --- (C) De-escalation判定とスコア更新 ---
    int newPrincipleComplianceScore = state.principleComplianceScore;
    String educationLog = '';
    
    if (state.turnsUntilDiagnosis <= 0) {
        if (state.lastWeaponCategory != null && 
            state.lastWeaponCategory != WeaponCategory.Access && 
            weapon.category == WeaponCategory.Access) 
        {
            newPrincipleComplianceScore += 200; 
            educationLog = '✅ 成功！Access薬へ**ステップダウン**しました。原則遵守ボーナス (+200)。';
        } else if (weapon.category != WeaponCategory.Access) {
            educationLog = '💡 思考: 広域薬の継続は、耐性リスクを不必要に高めます。切り替えを検討してください。';
        }
    } else {
         if (weapon.category == WeaponCategory.Reserve) {
             educationLog = '🚨 警告: 検査結果待ちにReserve薬を使用。過剰な治療は避けてください！';
         }
    }

    // --- (D) 状態更新（ターン終了処理を含む）---
    
    // 敵の増殖による重症度増加
    double severityIncrease = currentEnemy.severityIncreaseRate;
    
    // ★修正: Reserve薬使用の場合、副作用による体調悪化で重症度増加係数が増える
    if (weapon.reboundSeverityFactor > 1.0) {
        severityIncrease *= weapon.reboundSeverityFactor;
        educationLog += ' 副作用反動により、重症度増加速度が ${weapon.reboundSeverityFactor.toStringAsFixed(1)} 倍になりました。';
    }
    
    // 新しい重症度 (ダメージ減少後、敵の増殖分増加)
    final double newSeverity = (state.currentSeverity - finalDamage).clamp(0.0, 100.0) + severityIncrease;
    
    // ログメッセージの生成
    final List<String> newLogs = [
      '治療実施: ${weapon.name} を投薬。ダメージ: ${finalDamage.toInt()} | リスク: ${riskIncrease.toStringAsFixed(2)} | コスト: ${costIncrease.toStringAsFixed(1)}',
      if (educationLog.isNotEmpty) educationLog,
      if (newSensitivity < state.currentSensitivityScore) '🚨 ペナルティ: 耐性獲得の閾値を超えました。感受性が ${newSensitivity.toStringAsFixed(2)} に低下！',
      ...state.logMessages,
    ];
    
    state = state.copyWith(
      currentSeverity: newSeverity,
      currentResistanceRisk: newResistanceRisk,
      currentSideEffectCost: state.currentSideEffectCost + costIncrease,
      currentSensitivityScore: newSensitivity,
      currentTurn: state.currentTurn + 1,
      turnsUntilDiagnosis: (state.turnsUntilDiagnosis - 1).clamp(0, currentCase.diagnosisDelayTurns),
      logMessages: newLogs,
      principleComplianceScore: newPrincipleComplianceScore,
      lastWeaponCategory: weapon.category,
    );
  }

  // --------------------------------------------------
  // 3. サポートアクション
  // --------------------------------------------------

  void performSupportAction(SupportAction action) {
    if (isGameOver) return;

    String log = '';
    
    if (action == SupportAction.Inspection) {
      final int newDelay = (state.turnsUntilDiagnosis - 1).clamp(0, state.currentCase.diagnosisDelayTurns);
      log = '✅ 検査アクション実施: 診断までの残りターンが $newDelay になりました。';
      state = state.copyWith(
        turnsUntilDiagnosis: newDelay,
        logMessages: [log, ...state.logMessages],
      );
    } 
    else if (action == SupportAction.SourceControl) {
      final double severityReduction = 40.0;
      log = '✅ 感染源制御実施！重症度を ${severityReduction.toInt()} 減少させ、耐性リスクをリセットしました。';
      
      state = state.copyWith(
        currentSeverity: (state.currentSeverity - severityReduction).clamp(0.0, 100.0),
        currentResistanceRisk: 0.0,
        logMessages: [log, ...state.logMessages],
      );
    }
    
    turnProceedAfterSupport();
  }

  // --------------------------------------------------
  // 4. サポートアクション後のターン進行処理
  // --------------------------------------------------

  void turnProceedAfterSupport() {
    final currentEnemy = state.currentEnemy;
    final double severityIncrease = currentEnemy.severityIncreaseRate;
    final double newSeverity = (state.currentSeverity + severityIncrease).clamp(0.0, 100.0);
    
    state = state.copyWith(
      currentSeverity: newSeverity,
      currentTurn: state.currentTurn + 1,
      turnsUntilDiagnosis: (state.turnsUntilDiagnosis - 1).clamp(0, state.currentCase.diagnosisDelayTurns),
    );
  }
}