import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart';
import '../models/models.dart';
import '../models/enums.dart';
import '../models/weapon_data.dart'; // WEAPON_DATAのインポート

// 攻撃アクションで使用する新しい兵器名に合わせたアイコン
IconData _getWeaponIcon(WeaponCategory category) {
  switch (category) {
    case WeaponCategory.Access: 
      return Icons.local_hospital; 
    case WeaponCategory.Watch: 
      return Icons.military_tech;     
    case WeaponCategory.Reserve: 
      return Icons.warning;         
  }
}

// サポートアクションで使用するアイコン
IconData _getSupportIcon(SupportAction action) {
  switch (action) {
    case SupportAction.Inspection: 
      return Icons.search;
    case SupportAction.SourceControl: 
      return Icons.delete_sweep; 
  }
}

class ActionCards extends ConsumerWidget {
  final GameState gameState;
  const ActionCards({required this.gameState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider.notifier);
    final bool isGameOver = notifier.isGameOver; 
    
    return Column(
      children: [
        // --- 1. 投薬アクション (WEAPON_DATA) ---
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: const Text('🔥 兵器アクション', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          height: 110, // カードの高さ
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: WEAPON_DATA.map((weapon) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildWeaponCard(notifier, weapon, gameState.currentCase.isAllergyRestrict, isGameOver),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 1, thickness: 1),

        // --- 2. サポートアクション (検査/感染源制御) ---
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSupportCard(notifier, SupportAction.Inspection, '精密検査 (T-1)', isGameOver),
              _buildSupportCard(notifier, SupportAction.SourceControl, '感染源制御 (リスク↓/重症度↓)', isGameOver),
            ],
          ),
        ),
      ],
    );
  }

  // 武器カードの生成
  Widget _buildWeaponCard(GameNotifier notifier, AntibioticWeapon weapon, bool isAllergyRestrict, bool isGameOver) {
    
    // アレルギー制限のID: W002 (巡航ミサイル) と W007 (必殺：メテオ)
    final bool isSpecificAllergyRestrict = isAllergyRestrict && (weapon.id == 'W002' || weapon.id == 'W007'); 
    
    // コストオーバーまたはゲーム終了で操作不能
    // NOTE: sideEffectCostフィールドを使用
    final bool isCostOver = (gameState.currentSideEffectCost + weapon.sideEffectCost) > 100.0;
    final bool isDisabled = isGameOver || isSpecificAllergyRestrict || isCostOver;
    
    Color color;
    switch (weapon.category) {
      case WeaponCategory.Access: color = Colors.green; break;
      case WeaponCategory.Watch: color = Colors.orange; break;
      case WeaponCategory.Reserve: color = Colors.red; break;
    }
    
    final Color cardColor = isDisabled ? Colors.grey.shade300 : color.withOpacity(0.8);
    final Color textColor = isDisabled ? Colors.grey.shade600 : Colors.white;

    return Container(
      width: 120, // カードの幅を固定
      height: 100,
      child: InkWell(
        onTap: isDisabled ? null : () => notifier.applyTreatment(weapon),
        child: Card(
          color: cardColor,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getWeaponIcon(weapon.category), size: 16, color: textColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        weapon.name, // 現代兵器名が表示される
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Dmg:${weapon.damageBase.toInt()} | Risk:${(weapon.resistanceRiskFactor * 100).toInt()}%', 
                  style: TextStyle(fontSize: 10, color: textColor)
                ),
                Text(
                  'コスト: ${weapon.sideEffectCost.toInt()}', // sideEffectCostを表示
                  style: TextStyle(fontSize: 10, color: textColor)
                ),
                if (isDisabled) 
                  Text(
                    isSpecificAllergyRestrict ? 'アレルギー制限' : (isCostOver ? 'コスト超過' : 'ゲーム終了'),
                    style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // サポートボタンの生成
  Widget _buildSupportCard(GameNotifier notifier, SupportAction action, String label, bool isGameOver) {
    final bool isDisabled = isGameOver; 
    
    String buttonLabel = label;
    if (action == SupportAction.Inspection && gameState.turnsUntilDiagnosis <= 0) {
        buttonLabel = '精密検査 (完了)';
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          onPressed: isDisabled ? null : () => notifier.performSupportAction(action),
          icon: Icon(_getSupportIcon(action), size: 18),
          label: Text(
            buttonLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            disabledBackgroundColor: Colors.grey.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ),
        ),
      ),
    );
  }
}