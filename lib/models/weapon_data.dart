// lib/models/weapon_data.dart (データリスト)
import 'models.dart';
import 'enums.dart';

// ゲームで使用する兵器データリスト (全8種類)
const List<AntibioticWeapon> WEAPON_DATA = [
  // Access (矢/雷 -> 歩兵突撃/対空雷撃)
  const AntibioticWeapon(id: 'W001', name: '歩兵突撃', category: WeaponCategory.Access, damageBase: 11, resistanceRiskFactor: 0.05, sideEffectCost: 2), 
  const AntibioticWeapon(id: 'W007', name: '対空雷撃', category: WeaponCategory.Access, damageBase: 13, resistanceRiskFactor: 0.08, sideEffectCost: 3), 
  
  // Watch (剣/ハンマー/槍 -> 巡航ミサイル/防御ハンマー/特殊な槍撃)
  const AntibioticWeapon(id: 'W002', name: '巡航ミサイル', category: WeaponCategory.Watch, damageBase: 25, resistanceRiskFactor: 0.15, sideEffectCost: 5),
  const AntibioticWeapon(id: 'W004', name: '防御ハンマー', category: WeaponCategory.Watch, damageBase: 5, resistanceRiskFactor: 0.10, sideEffectCost: 4, counterMechanism: ResistanceMechanism.BetaLactamase),
  const AntibioticWeapon(id: 'W005', name: '特殊な槍撃', category: WeaponCategory.Watch, damageBase: 20, resistanceRiskFactor: 0.18, sideEffectCost: 10),
  
  // Reserve (メテオ/鎖 -> 必殺：メテオ/最終鎖兵器)
  const AntibioticWeapon(id: 'W003', name: '必殺：メテオ', category: WeaponCategory.Reserve, damageBase: 45, resistanceRiskFactor: 0.80, sideEffectCost: 25, reboundSeverityFactor: 1.3), 
  const AntibioticWeapon(id: 'W009', name: '最終鎖兵器', category: WeaponCategory.Reserve, damageBase: 35, resistanceRiskFactor: 0.70, sideEffectCost: 20, counterMechanism: ResistanceMechanism.TargetModification, reboundSeverityFactor: 1.2),
];