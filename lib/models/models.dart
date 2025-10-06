import 'enums.dart';

// --------------------------------------------------
// 1. 武器（抗菌薬）の定義
// --------------------------------------------------
class AntibioticWeapon {
  final String id;
  final String name; 
  final WeaponCategory category;
  final double damageBase;             // 基礎攻撃力
  final double resistanceRiskFactor;   // 使用時の耐性リスク加算値
  final double sideEffectCost;         // 基礎副作用コスト
  final ResistanceMechanism? counterMechanism; // 特効となる抵抗メカニズム

  const AntibioticWeapon({
    required this.id, required this.name, required this.category, 
    required this.damageBase, required this.resistanceRiskFactor, 
    required this.sideEffectCost, this.counterMechanism,
  });
}

const List<AntibioticWeapon> WEAPON_DATA = [
  // Access (低リスク)
  AntibioticWeapon(id: 'W001', name: '矢(アロー)', category: WeaponCategory.Access, damageBase: 10, resistanceRiskFactor: 0.05, sideEffectCost: 2),
  AntibioticWeapon(id: 'W007', name: '雷(サンダー)', category: WeaponCategory.Access, damageBase: 12, resistanceRiskFactor: 0.08, sideEffectCost: 3),
  
  // Watch (中リスク)
  AntibioticWeapon(id: 'W002', name: '剣(ソード)', category: WeaponCategory.Watch, damageBase: 25, resistanceRiskFactor: 0.15, sideEffectCost: 5),
  AntibioticWeapon(id: 'W004', name: 'ハンマー', category: WeaponCategory.Watch, damageBase: 5, resistanceRiskFactor: 0.10, sideEffectCost: 4, counterMechanism: ResistanceMechanism.BetaLactamase),
  AntibioticWeapon(id: 'W005', name: '槍(スピア)', category: WeaponCategory.Watch, damageBase: 20, resistanceRiskFactor: 0.18, sideEffectCost: 10),
  
  // Reserve (高リスク)
  AntibioticWeapon(id: 'W003', name: '必殺:メテオ', category: WeaponCategory.Reserve, damageBase: 45, resistanceRiskFactor: 0.40, sideEffectCost: 15),
  AntibioticWeapon(id: 'W009', name: '鎖(バインド)', category: WeaponCategory.Reserve, damageBase: 35, resistanceRiskFactor: 0.35, sideEffectCost: 12, counterMechanism: ResistanceMechanism.TargetModification),
];

// --------------------------------------------------
// 2. 敵（細菌集団）の定義
// --------------------------------------------------
class BacterialEnemy {
  final String id;
  final String name; 
  final double severityIncreaseRate;        // 毎ターンの重症度増加係数
  final ResistanceMechanism primaryResistance; // 主要な抵抗メカニズム
  final double initialSensitivityScore;     // 初期感受性スコア (1.0が完全感受性)
  final bool isIntracellular;               // 細胞内寄生（組織バリアーに関連）
  final double resistanceAcquisitionRate;   // 耐性獲得のしやすさ

  const BacterialEnemy({
    required this.id, required this.name, required this.severityIncreaseRate, 
    required this.primaryResistance, 
    this.initialSensitivityScore = 1.0, 
    this.isIntracellular = false,       
    this.resistanceAcquisitionRate = 1.0,
  });
}

const List<BacterialEnemy> ENEMY_DATA = [
  BacterialEnemy(id: 'E001', name: '感受性(S)増殖者', severityIncreaseRate: 10, primaryResistance: ResistanceMechanism.None, resistanceAcquisitionRate: 0.8),
  BacterialEnemy(id: 'E004', name: '防御酵素の要塞', severityIncreaseRate: 18, primaryResistance: ResistanceMechanism.BetaLactamase, initialSensitivityScore: 0.3, resistanceAcquisitionRate: 1.2),
  BacterialEnemy(id: 'E007', name: '貪食細胞の逃亡者', severityIncreaseRate: 8, primaryResistance: ResistanceMechanism.None, isIntracellular: true, resistanceAcquisitionRate: 1.0),
  BacterialEnemy(id: 'E008', name: '多重耐性の悪夢(MDRP)', severityIncreaseRate: 30, primaryResistance: ResistanceMechanism.EffluxPump, initialSensitivityScore: 0.1, resistanceAcquisitionRate: 2.0),
];

// --------------------------------------------------
// 3. 症例（シチュエーション）の定義
// --------------------------------------------------
class PatientCase {
  final String id;
  final String name; 
  final String enemyId;                  // 出現する敵のID
  final double initialSeverity;          // 初期重症度
  final double renalFunctionPenalty;     // 副作用コスト倍率 (1.0以上)
  final bool isAllergyRestrict;          // 特定武器の使用禁止フラグ（雷、剣など）
  final double resistanceStartBoost;     // 初期耐性リスク加算
  final int diagnosisDelayTurns;         // 診断結果が出るまでの遅延ターン

  const PatientCase({
    required this.id, required this.name, required this.enemyId, 
    required this.initialSeverity, required this.renalFunctionPenalty,
    this.isAllergyRestrict = false, 
    this.resistanceStartBoost = 0.0,
    this.diagnosisDelayTurns = 0,
  });
}

const List<PatientCase> CASE_DATA = [
  PatientCase(id: 'C001', name: '標準症例', enemyId: 'E001', initialSeverity: 50, renalFunctionPenalty: 1.0),
  PatientCase(id: 'C003', name: '高齢者(腎機能低下)', enemyId: 'E004', initialSeverity: 60, renalFunctionPenalty: 1.8),
  PatientCase(id: 'C004', name: 'アレルギー既往', enemyId: 'E002', initialSeverity: 55, renalFunctionPenalty: 1.0, isAllergyRestrict: true),
  PatientCase(id: 'C006', name: '敗血症疑い', enemyId: 'E001', initialSeverity: 90, renalFunctionPenalty: 1.0, diagnosisDelayTurns: 2),
  PatientCase(id: 'C005', name: '広域薬使用歴あり', enemyId: 'E001', initialSeverity: 50, renalFunctionPenalty: 1.0, resistanceStartBoost: 0.3),
];