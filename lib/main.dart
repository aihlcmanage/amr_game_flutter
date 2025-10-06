import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_disclaimer_screen.dart'; // ステップ4-2で作成

void main() {
  runApp(
    // Riverpodを有効化
    const ProviderScope(
      child: AmrGameApp(),
    ),
  );
}

class AmrGameApp extends StatelessWidget {
  const AmrGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '抗菌薬リスク管理トレーナー',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 最初に免責事項画面を表示
      home: const SplashDisclaimerScreen(),
    );
  }
}