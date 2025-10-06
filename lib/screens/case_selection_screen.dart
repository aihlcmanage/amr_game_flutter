// lib/screens/case_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// NOTE: CaseSelectionScreenが使用するモデルとデータリストをインポート
import '../models/models.dart'; 
import '../models/enemy_case_data.dart'; // ★この行を追加！CASE_DATAを定義しているファイル

// 以前のやり取りで定義したゲームNotifierをインポート
import '../state/game_notifier.dart'; 
import 'game_screen.dart'; // ゲーム画面への遷移用と仮定

class CaseSelectionScreen extends StatelessWidget {
  const CaseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('症例選択'),
      ),
      body: ListView.builder(
        // ★修正: CASE_DATAをインポートしたことで参照可能になる
        itemCount: CASE_DATA.length, 
        itemBuilder: (context, index) {
          final caseData = CASE_DATA[index]; // ★修正: CASE_DATAをインポートしたことで参照可能になる

          return Consumer(
            builder: (context, ref, child) {
              return CaseCard(
                caseData: caseData,
                onSelect: () {
                  // GameNotifierで新しいゲームを開始
                  ref.read(gameNotifierProvider.notifier).startGame(caseData);
                  
                  // ゲーム画面へ遷移 (GameScreenは仮称)
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// 症例を表示するためのダミーカード (実際のCaseCardウィジェットを置き換えてください)
class CaseCard extends StatelessWidget {
  final PatientCase caseData;
  final VoidCallback onSelect;

  const CaseCard({required this.caseData, required this.onSelect, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(caseData.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('初期重症度: ${caseData.initialSeverity.toInt()}'),
        trailing: ElevatedButton(
          onPressed: onSelect,
          child: const Text('選択'),
        ),
      ),
    );
  }
}