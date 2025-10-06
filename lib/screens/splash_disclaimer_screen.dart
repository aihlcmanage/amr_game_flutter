import 'package:flutter/material.dart';
import 'case_selection_screen.dart'; // 次の画面

class SplashDisclaimerScreen extends StatelessWidget {
  const SplashDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('重要警告')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text(
              '⚠️ 本ゲームは教育ツールであり、現実の臨床判断の代わりにはなりません。実際の治療は必ず指導医の監督下で行ってください。',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // 同意後に症例選択画面へ遷移
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const CaseSelectionScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('同意してゲームを開始', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}