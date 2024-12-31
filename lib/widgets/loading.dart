import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ローディング中を表示するウィジェット
class Loading extends StatelessWidget {
  /// コンストラクタ
  ///
  /// @param key ウィジェットのキー
  /// @param text 表示するテキスト
  const Loading({
    super.key,
    required this.text,
  });

  /// 表示するテキスト
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FcColors.gray,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent, // アバターの背景色
                ),
                child: SvgPicture.asset(
                  'images/ai-avatar.svg', // AIアバターの画像
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              text, // 表示するテキスト
              style: const TextStyle(
                color: FcColors.white, // テキストの色
                fontSize: 16, // フォントサイズ
                fontWeight: FontWeight.w700, // フォントの太さ
              ),
            ),
          ),
        ],
      ),
    );
  }
}
