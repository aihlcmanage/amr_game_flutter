// lib/widgets/action_cards.dart のコード全体

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart';
import '../models/models.dart';
import '../models/enums.dart';

class ActionCards extends ConsumerWidget {
  final GameState gameState;
  const ActionCards({required this.gameState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider.notifier);
    
    return Column(
      children: [
        // --- 1. 投薬アクション (WEAPON_DATA) ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          height: 130, // 高さ調整
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: WEAPON_DATA.map((weapon) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildWeaponCard(notifier, weapon, gameState.currentCase.isAllergyRestrict),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 1, thickness: 1),

        // --- 2. サポートアクション (検査/感染源制御) ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // ★修正: MaterialColorを直接渡す
              _buildSupportCard(notifier, SupportAction.Inspection, '検査', Icons.search, Colors.blue),
              _buildSupportCard(notifier, SupportAction.SourceControl, '感染源制御', Icons.clean_hands, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }
  
  // 薬剤カテゴリに応じたアイコン設定
  IconData _getWeaponIcon(AntibioticWeapon weapon) {
    // 臨床的リアリティを意識したアイコン
    switch (weapon.category) {
      case WeaponCategory.Access: return Icons.health_and_safety; // アクセス/安全
      case WeaponCategory.Watch: return Icons.military_tech;     // 監視/強力
      case WeaponCategory.Reserve: return Icons.warning;         // 優先度高/危険
    }
  }

  // 武器カードの生成
  Widget _buildWeaponCard(GameNotifier notifier, AntibioticWeapon weapon, bool isAllergyRestrict) {
    final bool isDisabled = isAllergyRestrict && (weapon.id == 'W002' || weapon.id == 'W007'); 

    Color categoryColor;
    switch (weapon.category) {
      case WeaponCategory.Access: categoryColor = Colors.green.shade700; break;
      case WeaponCategory.Watch: categoryColor = Colors.orange.shade700; break;
      case WeaponCategory.Reserve: categoryColor = Colors.red.shade700; break;
    }
    
    final Color cardColor = categoryColor.withOpacity(0.1);
    final Color textColor = categoryColor;
    
    return Card(
      elevation: 2,
      color: isDisabled ? Colors.grey.shade300 : cardColor,
      child: InkWell(
        onTap: isDisabled ? null : () => notifier.applyTreatment(weapon),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getWeaponIcon(weapon), size: 30, color: isDisabled ? Colors.grey.shade500 : textColor),
              const SizedBox(height: 4),
              Text(weapon.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDisabled ? Colors.grey.shade600 : textColor)),
              Text('(${weapon.category.name})', style: TextStyle(fontSize: 11, color: isDisabled ? Colors.grey.shade600 : textColor)),
              const SizedBox(height: 2),
              Text('D:${weapon.damageBase.toInt()} R:${(weapon.resistanceRiskFactor * 100).toInt()}% C:${weapon.sideEffectCost.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
              if (isDisabled) const Text('🚫 制限', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // サポートカードの生成
  // ★修正: color引数をMaterialColor型として受け取る (または型をMaterialColorに変更)
  Widget _buildSupportCard(GameNotifier notifier, SupportAction action, String label, IconData icon, MaterialColor color) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: color.shade50, // shade50はMaterialColorで定義されているためOK
        child: InkWell(
          onTap: () => notifier.performSupportAction(action),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ★修正: color.shade700がMaterialColorでのみ使用可能
                Icon(icon, size: 20, color: color.shade700),
                const SizedBox(width: 8),
                // ★修正: color.shade700がMaterialColorでのみ使用可能
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color.shade700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}