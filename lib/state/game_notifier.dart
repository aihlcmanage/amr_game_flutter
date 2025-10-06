import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../models/enums.dart';
import '../utils/logic_calculator.dart';
import 'game_state.dart';

// GameNotifierのインスタンスを提供するProvider
final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  // 初期状態は仮のデータで設定（startGameで上書きされる）
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
    // 敗北条件
    if (state.currentSeverity >= 100.0) {
      return true;
    }
    // 勝利条件 (重症度が安全域で、かつ最低3ターンは治療が行われた場合)
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
    
    // 選択された症例に合わせて状態を初期化
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
    );
  }

  // --------------------------------------------------
  // 2. 投薬アクション
  // --------------------------------------------------

  void applyTreatment(AntibioticWeapon weapon) {
    if (isGameOver) return; // ゲームオーバー時は処理しない

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
    
    if (state.turnsUntilDiagnosis <= 0) { // 検査結果が出ている場合
        if (state.lastWeaponCategory != null && 
            state.lastWeaponCategory != WeaponCategory.Access && 
            weapon.category == WeaponCategory.Access) 
        {
            // De-escalation成功
            newPrincipleComplianceScore += 200; 
            educationLog = '✅ 成功！Access薬へ**ステップダウン**しました。原則遵守ボーナス (+200)。';
        } else if (weapon.category != WeaponCategory.Access) {
             // 検査結果が出ているのに広域を継続
            educationLog = '💡 思考: 広域薬の継続は、耐性リスクを不必要に高めます。切り替えを検討してください。';
        }
    } else {
         // 検査結果待ち（初期治療）期間
         if (weapon.category == WeaponCategory.Reserve) {
             educationLog = '🚨 警告: 検査結果待ちにReserve薬を使用。過剰な治療は避けてください！';
         }
    }

    // --- (D) 状態更新（ターン終了処理を含む）---
    
    // 敵の増殖による重症度増加
    final double severityIncrease = currentEnemy.severityIncreaseRate;
    
    // 新しい重症度 (ダメージ減少後、敵の増殖分増加)
    final double newSeverity = (state.currentSeverity - finalDamage).clamp(0.0, 100.0) + severityIncrease;
    
    // ログメッセージの生成
    final List<String> newLogs = [
      '治療実施: ${weapon.name} を投薬。重症度を ${finalDamage.toInt()} 減少。',
      '⚠️ 警告: 耐性リスク $riskIncrease.toStringAsFixed(2) 加算。副作用コスト $costIncrease.toStringAsFixed(1) 増加。',
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
      lastWeaponCategory: weapon.category, // 最後に使用した武器を記録
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
      // 感染源制御は重症度を大きく下げ、耐性リスクをリセットする
      final double severityReduction = 40.0;
      log = '✅ 感染源制御実施！重症度を ${severityReduction.toInt()} 減少させ、耐性リスクをリセットしました。';
      
      state = state.copyWith(
        currentSeverity: (state.currentSeverity - severityReduction).clamp(0.0, 100.0),
        currentResistanceRisk: 0.0,
        logMessages: [log, ...state.logMessages],
      );
    }
    
    // サポートアクション後もターンは進行する
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