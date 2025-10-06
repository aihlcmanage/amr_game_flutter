import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// NOTE: CaseSelectionScreenが使用するモデルとデータリストをインポート
import '../models/models.dart'; 
import '../models/enemy_case_data.dart'; // ★この行を追加！CASE_DATAを定義しているファイル

// 以前のやり取りで定義したゲームNotifierをインポート
import '../state/game_notifier.dart'; 
import 'game_screen.dart'; // ゲーム画面への遷移用と仮定

// ★修正: StatelessWidgetではなく、ConsumerWidgetにする
class CaseSelectionScreen extends ConsumerWidget {
  const CaseSelectionScreen({super.key});

  @override
  // ★修正: ConsumerWidgetなので、buildメソッドは(context, ref)を受け取る
  Widget build(BuildContext context, WidgetRef ref) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('症例選択'),
      ),
      body: ListView.builder(
        // ★修正: CASE_DATAをインポートしたことで参照可能になる
        itemCount: CASE_DATA.length, 
        itemBuilder: (context, index) {
          final caseData = CASE_DATA[index]; // ★修正: CASE_DATAをインポートしたことで参照可能になる

          // ★修正: Consumerで囲む必要なし。CaseSelectionScreen自体がConsumerWidgetになったため
          return CaseCard(
            caseData: caseData,
            onSelect: () {
              // GameNotifierで新しいゲームを開始
              ref.read(gameNotifierProvider.notifier).startGame(caseData);
              
              // ゲーム画面へ遷移 (GameScreenは仮称)
              // pushReplacementではなく、単純なpushで戻れるようにしておくのが一般的かもしれません
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GameScreen()),
              );
            },
          );
        },
      ),
    );
  }
}

// 症例を表示するためのダミーカード
// ★修正: CaseCardはrefを必要としないため、StatelessWidgetのままでOK
class CaseCard extends StatelessWidget {
  // 以前のやり取りから、PatientCaseモデルが存在すると仮定
  final PatientCase caseData; 
  final VoidCallback onSelect;

  const CaseCard({required this.caseData, required this.onSelect, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(caseData.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        // ★修正: num型であればtoInt()は不要なはず。もし必要なら再度調整します。
        // ★ただし、CaseCardはTextStyleを適用していないため、TextStyleを追加しました。
        subtitle: Text('初期重症度: ${caseData.initialSeverity}', style: const TextStyle(color: Colors.black54)),
        trailing: ElevatedButton(
          onPressed: onSelect,
          child: const Text('選択'),
        ),
      ),
    );
  }
}
