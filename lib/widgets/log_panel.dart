import 'package:flutter/material.dart';

class LogPanel extends StatelessWidget {
  final List<String> logMessages;
  const LogPanel({required this.logMessages, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView.builder(
        reverse: true, // 新しいログが下に来るように反転
        itemCount: logMessages.length,
        itemBuilder: (context, index) {
          final message = logMessages[index];
          // ログメッセージの背景色: 最新のログを目立たせる
          final bool isNew = index < 3; 
          
          return Container(
            margin: const EdgeInsets.only(bottom: 6.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isNew ? Colors.blue.shade50 : Colors.transparent, // 最新ログは薄い青
              borderRadius: BorderRadius.circular(4),
              border: index == 0 ? Border.all(color: Colors.blue.shade200) : null, // 最上部を強調
            ),
            child: Text(
              _formatLogMessage(message),
              style: TextStyle(
                fontSize: 13, // 文字サイズを拡大
                color: _getLogColor(message),
                fontWeight: _isImportant(message) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
  
  // ログメッセージのプレフィックスに応じて色を決定
  Color _getLogColor(String message) {
    if (message.startsWith('🚨')) return Colors.red.shade700;
    if (message.startsWith('✅')) return Colors.green.shade700;
    if (message.startsWith('💡')) return Colors.blue.shade700;
    if (message.startsWith('⚠️')) return Colors.orange.shade700;
    return Colors.black87;
  }

  // ログメッセージの内容に応じて太字を適用するか判断
  bool _isImportant(String message) {
    return message.startsWith('🚨') || message.startsWith('✅') || message.contains('ステップダウン');
  }

  // ログメッセージの絵文字置換とフォーマット
  String _formatLogMessage(String message) {
    return message
        .replaceAll('治療実施', '💉 治療')
        .replaceAll('警告: 耐性リスク', '⚠️ リスク')
        .replaceAll('副作用コスト', '💊 コスト')
        .replaceAll('💡 思考', '🧠 助言');
  }
}