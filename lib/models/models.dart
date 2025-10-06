import 'enums.dart';

// --------------------------------------------------
// 1. 武器（抗菌薬）の定義 - バランス調整
// --------------------------------------------------
class AntibioticWeapon {
  final String id;
  final String name; 
  final WeaponCategory category;
  final double damageBase;             
  final double resistanceRiskFactor;   // ★修正: リスク係数を調整
  final double sideEffectCost;         // ★修正: コストを調整
  final ResistanceMechanism? counterMechanism;
  final double reboundSeverityFactor;  // ★追加: 反動による重症度増加係数 (1.0で反動なし)

  const AntibioticWeapon({
    required this.id, required this.name, required this.category, 
    required this.damageBase, required this.resistanceRiskFactor, 
    required this.sideEffectCost, this.counterMechanism,
    this.reboundSeverityFactor = 1.0, // デフォルトは反動なし
  });
}

const List<AntibioticWeapon> WEAPON_DATA = [
  // Access (低リスク, わずかに強化)
  AntibioticWeapon(id: 'W001', name: '矢(アロー)', category: WeaponCategory.Access, damageBase: 11, resistanceRiskFactor: 0.05, sideEffectCost: 2), // 10→11
  AntibioticWeapon(id: 'W007', name: '雷(サンダー)', category: WeaponCategory.Access, damageBase: 13, resistanceRiskFactor: 0.08, sideEffectCost: 3), // 12→13
  
  // Watch (中リスク)
  AntibioticWeapon(id: 'W002', name: '剣(ソード)', category: WeaponCategory.Watch, damageBase: 25, resistanceRiskFactor: 0.15, sideEffectCost: 5),
  AntibioticWeapon(id: 'W004', name: 'ハンマー', category: WeaponCategory.Watch, damageBase: 5, resistanceRiskFactor: 0.10, sideEffectCost: 4, counterMechanism: ResistanceMechanism.BetaLactamase),
  AntibioticWeapon(id: 'W005', name: '槍(スピア)', category: WeaponCategory.Watch, damageBase: 20, resistanceRiskFactor: 0.18, sideEffectCost: 10),
  
  // Reserve (高リスク, ペナルティ大幅強化)
  // ★修正: リスクとコストを増加、反動ペナルティを追加
  AntibioticWeapon(id: 'W003', name: '必殺:メテオ', category: WeaponCategory.Reserve, damageBase: 45, resistanceRiskFactor: 0.80, sideEffectCost: 25, reboundSeverityFactor: 1.3), 
  AntibioticWeapon(id: 'W009', name: '鎖(バインド)', category: WeaponCategory.Reserve, damageBase: 35, resistanceRiskFactor: 0.70, sideEffectCost: 20, counterMechanism: ResistanceMechanism.TargetModification, reboundSeverityFactor: 1.2),
];

// --------------------------------------------------
// 2. 敵（細菌集団）の定義 - HP増加
// --------------------------------------------------
class BacterialEnemy {
  final String id;
  final String name; 
  final double severityIncreaseRate;        
  final ResistanceMechanism primaryResistance; 
  final double initialSensitivityScore;     
  final bool isIntracellular;               
  final double resistanceAcquisitionRate;   

  const BacterialEnemy({
    required this.id, required this.name, required this.severityIncreaseRate, 
    required this.primaryResistance, 
    this.initialSensitivityScore = 1.0, 
    this.isIntracellular = false,       
    this.resistanceAcquisitionRate = 1.0,
  });
}

const List<BacterialEnemy> ENEMY_DATA = [
  // ★修正: 初期HPが高くなるように severityIncreaseRate を調整 (間接的にHPを増加させる)
  BacterialEnemy(id: 'E001', name: '感受性(S)増殖者', severityIncreaseRate: 12, primaryResistance: ResistanceMechanism.None, resistanceAcquisitionRate: 0.8), // 10→12
  BacterialEnemy(id: 'E004', name: '防御酵素の要塞', severityIncreaseRate: 21, primaryResistance: ResistanceMechanism.BetaLactamase, initialSensitivityScore: 0.3, resistanceAcquisitionRate: 1.2), // 18→21
  BacterialEnemy(id: 'E007', name: '貪食細胞の逃亡者', severityIncreaseRate: 10, primaryResistance: ResistanceMechanism.None, isIntracellular: true, resistanceAcquisitionRate: 1.0),
  BacterialEnemy(id: 'E008', name: '多重耐性の悪夢(MDRP)', severityIncreaseRate: 35, primaryResistance: ResistanceMechanism.EffluxPump, initialSensitivityScore: 0.1, resistanceAcquisitionRate: 2.0), // 30→35
];

// --------------------------------------------------
// 3. 症例（シチュエーション）の定義
// --------------------------------------------------
class PatientCase {
  final String id;
  final String name; 
  final String enemyId;                  
  final double initialSeverity;          // ★修正: 初期重症度を1.2倍に調整 (50→60など)
  final double renalFunctionPenalty;     
  final bool isAllergyRestrict;          
  final double resistanceStartBoost;     
  final int diagnosisDelayTurns;         

  const PatientCase({
    required this.id, required this.name, required this.enemyId, 
    required this.initialSeverity, required this.renalFunctionPenalty,
    this.isAllergyRestrict = false, 
    this.resistanceStartBoost = 0.0,
    this.diagnosisDelayTurns = 0,
  });
}

const List<PatientCase> CASE_DATA = [
  PatientCase(id: 'C001', name: '標準症例', enemyId: 'E001', initialSeverity: 60, renalFunctionPenalty: 1.0), // 50→60
  PatientCase(id: 'C003', name: '高齢者(腎機能低下)', enemyId: 'E004', initialSeverity: 72, renalFunctionPenalty: 1.8), // 60→72
  PatientCase(id: 'C004', name: 'アレルギー既往', enemyId: 'E002', initialSeverity: 66, renalFunctionPenalty: 1.0, isAllergyRestrict: true), // 55→66
  PatientCase(id: 'C006', name: '敗血症疑い', enemyId: 'E001', initialSeverity: 108, renalFunctionPenalty: 1.0, diagnosisDelayTurns: 2), // 90→108 (初期重症)
  PatientCase(id: 'C005', name: '広域薬使用歴あり', enemyId: 'E001', initialSeverity: 60, renalFunctionPenalty: 1.0, resistanceStartBoost: 0.3),
];