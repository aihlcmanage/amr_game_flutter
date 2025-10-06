import 'package:flutter/material.dart';

class LogPanel extends StatelessWidget {
  final List<String> logMessages;

  const LogPanel({required this.logMessages, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ターンログ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              // ログを最新のものから表示するため逆順に
              reverse: true,
              itemCount: logMessages.length,
              itemBuilder: (context, index) {
                // インデックスを逆転させて最新のログが下に来るようにする
                final reversedIndex = logMessages.length - 1 - index;
                final message = logMessages[reversedIndex];
                
                // 教育的な警告や成功メッセージを色分け
                Color color = Colors.black87;
                if (message.contains('成功')) {
                  color = Colors.green.shade700;
                } else if (message.contains('警告') || message.contains('ペナルティ')) {
                  color = Colors.orange.shade700;
                } else if (message.contains('超過')) {
                  color = Colors.red.shade700;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 13, color: color),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}