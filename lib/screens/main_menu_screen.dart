import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_screen.dart'; // GameScreenへのインポート

// スタートメニュー画面
class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // タイトル
              const Text(
                'AMR治療戦略シミュレーター',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C), // 濃い紫色
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // サブタイトル/説明
              const Text(
                '抗生物質適正使用（AMS）のための戦略的トレーニング',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // ★ スタートボタン ★
              ElevatedButton.icon(
                onPressed: () {
                  // GameScreenへ遷移
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GameScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.medical_services, size: 24),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    '治療シミュレーション開始',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF6A1B9A), // ボタンの色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
              ),
              const SizedBox(height: 40),
              
              // 注意書き
              const Text(
                '※ 本シミュレーターは学習目的であり、現実の医療行為の判断には絶対に使用できません。',
                style: TextStyle(fontSize: 10, color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
