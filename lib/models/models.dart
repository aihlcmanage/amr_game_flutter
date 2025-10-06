// lib/models/models.dart
import 'enums.dart'; 
import 'weapon_data.dart'; // WEAPON_DATAの定義は別ファイルに任せる

// --------------------------------------------------
// 1. 武器（抗菌薬）の定義 - 構造を最新版に統一
// --------------------------------------------------
class AntibioticWeapon {
  final String id;
  final String name; 
  final WeaponCategory category;
  final double damageBase;             
  final double resistanceRiskFactor;   
  final double sideEffectCost;         // コストは sideEffectCost に統一
  final ResistanceMechanism? counterMechanism; // 特殊効果のターゲット
  final double reboundSeverityFactor;  // 反動による重症度増加係数 (1.0で反動なし)

  const AntibioticWeapon({
    required this.id, required this.name, required this.category, 
    required this.damageBase, required this.resistanceRiskFactor, 
    required this.sideEffectCost, this.counterMechanism,
    this.reboundSeverityFactor = 1.0, 
  });
  
  // 以前のコードとの互換性のため、cost ゲッターを追加 (game_notifierで使用)
  double get cost => sideEffectCost; 
}


// --------------------------------------------------
// 2. 敵（細菌集団）の定義
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

// --------------------------------------------------
// 3. 症例（シチュエーション）の定義
// --------------------------------------------------
class PatientCase {
  final String id;
  final String name; 
  final String enemyId;                  
  final double initialSeverity;          
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

// NOTE: 以前定義されていた WEAPON_DATA, ENEMY_DATA, CASE_DATA のリストは
//       このファイルから削除し、対応するデータファイルへ移動します。