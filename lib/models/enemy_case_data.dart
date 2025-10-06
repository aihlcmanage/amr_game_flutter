// lib/models/enemy_case_data.dart (敵と症例データ)
import 'models.dart';
import 'enums.dart';

// --------------------------------------------------
// 敵（細菌集団）のデータリスト (4種類)
// --------------------------------------------------
const List<BacterialEnemy> ENEMY_DATA = [
  BacterialEnemy(id: 'E001', name: '感受性(S)増殖者', severityIncreaseRate: 12, primaryResistance: ResistanceMechanism.None, resistanceAcquisitionRate: 0.8),
  BacterialEnemy(id: 'E004', name: '防御酵素の要塞', severityIncreaseRate: 21, primaryResistance: ResistanceMechanism.BetaLactamase, initialSensitivityScore: 0.3, resistanceAcquisitionRate: 1.2), 
  BacterialEnemy(id: 'E007', name: '貪食細胞の逃亡者', severityIncreaseRate: 10, primaryResistance: ResistanceMechanism.None, isIntracellular: true, resistanceAcquisitionRate: 1.0),
  BacterialEnemy(id: 'E008', name: '多重耐性の悪夢(MDRP)', severityIncreaseRate: 35, primaryResistance: ResistanceMechanism.EffluxPump, initialSensitivityScore: 0.1, resistanceAcquisitionRate: 2.0), 
];

// --------------------------------------------------
// 症例（シチュエーション）のデータリスト (5種類)
// --------------------------------------------------
const List<PatientCase> CASE_DATA = [
  PatientCase(id: 'C001', name: '標準症例', enemyId: 'E001', initialSeverity: 60, renalFunctionPenalty: 1.0), 
  PatientCase(id: 'C003', name: '高齢者(腎機能低下)', enemyId: 'E004', initialSeverity: 72, renalFunctionPenalty: 1.8), 
  PatientCase(id: 'C004', name: 'アレルギー既往', enemyId: 'E002', initialSeverity: 66, renalFunctionPenalty: 1.0, isAllergyRestrict: true), // NOTE: E002はENEMY_DATAにないため注意
  PatientCase(id: 'C006', name: '敗血症疑い', enemyId: 'E001', initialSeverity: 108, renalFunctionPenalty: 1.0, diagnosisDelayTurns: 2), 
  PatientCase(id: 'C005', name: '広域薬使用歴あり', enemyId: 'E001', initialSeverity: 60, renalFunctionPenalty: 1.0, resistanceStartBoost: 0.3),
];