import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatgpt/constants.dart';

/// ユーザーのメッセージを表示するウィジェットクラス
class UserMessage extends StatelessWidget {
  /// コンストラクタ
  ///
  /// @param key ウィジェットのキー
  /// @param text 表示するメッセージテキスト
  const UserMessage({
    super.key,
    required this.text,
  });

  /// 表示するメッセージテキスト
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: FcColors.green, // メッセージの背景色
                borderRadius: BorderRadius.circular(16), // 角丸の半径
              ),
              child: SelectionArea(
                // テキスト選択時のコールバック
                onSelectionChanged: (content) async {
                  // 選択されたテキストがある場合
                  if (content != null) {
                    // クリップボードにコピー
                    await Clipboard.setData(
                        ClipboardData(text: content.plainText));
                  }
                },
                child: Text(
                  text, // 表示するメッセージテキスト
                  style: const TextStyle(
                    color: FcColors.white, // テキストの色
                    fontSize: 18, // フォントサイズ
                    fontWeight: FontWeight.w700, // フォントの太さ
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
