import '../models/models.dart';
import '../state/game_state.dart';
import '../models/enums.dart'; // 列挙型の型定義に必要

class LogicCalculator {
  
  // --------------------------------------------------
  // 1. ダメージと副作用の計算
  // --------------------------------------------------
  static double calculateDamage({
    required AntibioticWeapon weapon, 
    required BacterialEnemy enemy, 
    required double currentSensitivity,
    required PatientCase currentCase,
  }) {
    double damage = weapon.damageBase * currentSensitivity;
    double resistanceCorrection = 1.0;
    
    // 抵抗メカニズム補正 (一致しない場合はダメージ減)
    if (enemy.primaryResistance != ResistanceMechanism.None && 
        weapon.counterMechanism != enemy.primaryResistance &&
        weapon.category != WeaponCategory.Reserve 
    ) {
      resistanceCorrection = 0.3; // ダメージを70%減
    }
    
    // 組織バリアー補正 (特定の薬が届きにくい場合)
    if (enemy.isIntracellular && weapon.id == 'W002') { 
      resistanceCorrection *= 0.5; 
    }

    return damage * resistanceCorrection;
  }
  
  // --------------------------------------------------
  // 2. 耐性獲得とリスク計算
  // --------------------------------------------------
  static double calculateResistanceRiskIncrease({
    required AntibioticWeapon weapon,
    required BacterialEnemy enemy,
  }) {
    // 武器データから抵抗リスク係数を取得
    double baseRisk = weapon.resistanceRiskFactor * enemy.resistanceAcquisitionRate;
    
    // Reserve薬はresistanceRiskFactor自体が大きく設定されているため、ここでは追加の倍加処理は不要とする。
    // models.dartのデータ定義でリスクをコントロール。
    
    return baseRisk;
  }
  
  static double calculateNewSensitivity(double currentRisk, double currentSensitivity) {
    const double threshold = 5.0; // 耐性獲得の閾値 (変更なし)
    const double sensitivityDrop = 0.1; 
    
    // リスクが閾値を超えた場合にのみ感受性を低下させる
    if (currentRisk >= threshold) {
      return (currentSensitivity - sensitivityDrop).clamp(0.0, 1.0);
    }
    return currentSensitivity;
  }
  
  // --------------------------------------------------
  // 3. 副作用コスト計算
  // --------------------------------------------------
  static double calculateSideEffectCost({
    required AntibioticWeapon weapon, 
    required PatientCase currentCase,
  }) {
    // 腎機能ペナルティを適用
    return weapon.sideEffectCost * currentCase.renalFunctionPenalty;
  }
}