import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../state/game_notifier.dart';
import 'game_screen.dart';

class CaseSelectionScreen extends ConsumerWidget {
  const CaseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('症例選択')),
      body: ListView.builder(
        itemCount: CASE_DATA.length,
        itemBuilder: (context, index) {
          final caseData = CASE_DATA[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text(caseData.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('初期重症度: ${caseData.initialSeverity}, 腎機能ペナルティ: x${caseData.renalFunctionPenalty.toStringAsFixed(1)}'),
              trailing: const Icon(Icons.play_arrow),
              onTap: () {
                // GameNotifierを使ってゲームを初期化し、画面遷移
                ref.read(gameNotifierProvider.notifier).startGame(caseData);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}