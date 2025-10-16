import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// AIのメッセージを表示するウィジェットクラス
class AiMessage extends StatelessWidget {
  /// コンストラクタ
  ///
  /// @param key ウィジェットのキー
  /// @param text 表示するメッセージテキスト
  /// @param isStreaming ストリーミング中かどうか
  const AiMessage({
    super.key,
    required this.text,
    this.isStreaming = false,
  });

  /// 表示するメッセージテキスト
  final String text;

  /// ストリーミング中かどうか
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 背景色
            borderRadius: BorderRadius.circular(16), // 角丸
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MarkdownBody(
                        data: text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(
                          Theme.of(context).copyWith(
                            textTheme: Theme.of(context).textTheme.apply(
                                  bodyColor: FcColors.black,
                                  displayColor: FcColors.black,
                                ),
                          ),
                        ),
                      ),
                      if (isStreaming) ...[
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(minHeight: 2),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
