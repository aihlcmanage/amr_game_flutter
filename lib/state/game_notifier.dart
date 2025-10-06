import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../models/enums.dart';
import '../utils/logic_calculator.dart';
import 'game_state.dart';

// 目標ターン数を定数として定義 (10ターンを超過したら警告)
const int TARGET_TURN_FOR_WARNING = 10;
// 膠着状態と見なす最大許容ターン数
const int MAX_ALLOWED_TURN = TARGET_TURN_FOR_WARNING * 2; // 20ターン

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
    // 敗北条件 1: 重症度 100%
    if (state.currentSeverity >= 100.0) {
      return true;
    }
    
    // ★修正: 敗北条件 2: 膠着状態での強制終了 (純粋な判定のみ、状態変更は行わない)
    if (state.currentSeverity > 10.0 && state.currentTurn > MAX_ALLOWED_TURN) {
        return true;
    }

    // 勝利条件: 重症度10%以下かつ最低3ターン経過
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
    
    // 敵の増殖による重症度増加の基本値
    double severityIncrease = currentEnemy.severityIncreaseRate;
    
    // Reserve薬の反動ペナルティ (副作用による体調悪化)
    if (weapon.reboundSeverityFactor > 1.0) {
        severityIncrease *= weapon.reboundSeverityFactor;
        educationLog += ' 副作用反動により、重症度増加速度が ${weapon.reboundSeverityFactor.toStringAsFixed(1)} 倍になりました。';
    }
    
    // 新しい重症度 (ダメージ減少後、敵の増殖分増加)
    final double newSeverity = (state.currentSeverity - finalDamage).clamp(0.0, 100.0) + severityIncrease;
    
    // ログメッセージの生成
    final List<String> newLogs = [
      '💉 投薬: ${weapon.name} | Dmg: ${finalDamage.toInt()} | Risk: ${riskIncrease.toStringAsFixed(2)} | Cost: ${costIncrease.toStringAsFixed(1)}',
      if (educationLog.isNotEmpty) educationLog,
      if (newSensitivity < state.currentSensitivityScore) '🚨 ペナルティ: 耐性獲得の閾値を超えました。感受性が ${newSensitivity.toStringAsFixed(2)} に低下！',
      ...state.logMessages,
    ];
    
    // --- (E) 目標ターン超過チェック ---
    final int nextTurn = state.currentTurn + 1;
    if (nextTurn == TARGET_TURN_FOR_WARNING + 1) {
        final String warning = '🚨 指導医からの助言: 既に${TARGET_TURN_FOR_WARNING}ターンを超過しています。治療が長期化するとコストが増大します。速やかな重症度の改善またはゲームの終結を目指しましょう。';
        newLogs.insert(0, warning); // ログの先頭に追加
    }


    state = state.copyWith(
      currentSeverity: newSeverity,
      currentResistanceRisk: newResistanceRisk,
      currentSideEffectCost: state.currentSideEffectCost + costIncrease,
      currentSensitivityScore: newSensitivity,
      currentTurn: nextTurn,
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
  
  // --------------------------------------------------
  // 5. ギブアップ機能と膠着敗北時のログ記録
  // --------------------------------------------------
  
  void recordEndGameLog() {
    if (state.currentSeverity >= 100.0) {
      // 敗北 100%
      state = state.copyWith(
          logMessages: ['🚨 判定: 重症度が100%に達し、治療失敗と判定されました。', ...state.logMessages]
      );
    } else if (state.currentSeverity > 10.0 && state.currentTurn > MAX_ALLOWED_TURN) {
      // 敗北 膠着状態
      state = state.copyWith(
          logMessages: ['🚨 判定: 治療が長期化し、許容ターン数を超えました。治療失敗と判定されます。', ...state.logMessages]
      );
    } else if (state.currentSeverity <= 10.0) {
      // 勝利
      state = state.copyWith(
          logMessages: ['✅ 判定: 重症度が10%以下となり、治療成功と判定されました。', ...state.logMessages]
      );
    }
  }

  void surrender() {
    if (isGameOver) return;
    
    // ギブアップを敗北として処理するため、重症度を100%に設定
    state = state.copyWith(
      currentSeverity: 100.0,
      logMessages: ['⛔️ ギブアップ: プレイヤーが治療を断念しました。治療失敗として評価されます。', ...state.logMessages],
    );
  }
}