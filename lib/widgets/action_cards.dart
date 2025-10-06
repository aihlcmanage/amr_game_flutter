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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          height: 100, // 高さを固定
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: WEAPON_DATA.map((weapon) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildWeaponButton(notifier, weapon, gameState.currentCase.isAllergyRestrict),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 1, thickness: 1),

        // --- 2. サポートアクション (検査/感染源制御) ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSupportButton(notifier, SupportAction.Inspection, '検査 (T-1)'),
              _buildSupportButton(notifier, SupportAction.SourceControl, '感染源制御 (リスク↓)'),
            ],
          ),
        ),
      ],
    );
  }

  // 武器ボタンの生成
  Widget _buildWeaponButton(GameNotifier notifier, AntibioticWeapon weapon, bool isAllergyRestrict) {
    final bool isDisabled = isAllergyRestrict && (weapon.id == 'W002' || weapon.id == 'W007'); // 例: アレルギーで剣と雷を制限

    Color color;
    switch (weapon.category) {
      case WeaponCategory.Access: color = Colors.green; break;
      case WeaponCategory.Watch: color = Colors.orange; break;
      case WeaponCategory.Reserve: color = Colors.red; break;
    }

    return ElevatedButton(
      onPressed: isDisabled ? null : () => notifier.applyTreatment(weapon),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.8),
        disabledBackgroundColor: Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(weapon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(weapon.category.name, style: const TextStyle(fontSize: 10)),
          Text('D:${weapon.damageBase.toInt()} R:${(weapon.resistanceRiskFactor * 100).toInt()}%', style: const TextStyle(fontSize: 9)),
          if (isDisabled) const Text('制限', style: TextStyle(fontSize: 9, color: Colors.black)),
        ],
      ),
    );
  }

  // サポートボタンの生成
  Widget _buildSupportButton(GameNotifier notifier, SupportAction action, String label) {
    return ElevatedButton.icon(
      onPressed: () => notifier.performSupportAction(action),
      icon: Icon(action == SupportAction.Inspection ? Icons.search : Icons.cut, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
    );
  }
}