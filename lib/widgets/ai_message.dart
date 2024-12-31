import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// レンダリングの状態を表す列挙型
enum RenderingState {
  /// レンダリングされていない状態
  none,

  /// レンダリングが完了した状態
  complete
}

/// AIのメッセージを表示するウィジェットクラス
class AiMessage extends StatefulWidget {
  /// コンストラクタ
  ///
  /// @param key ウィジェットのキー
  /// @param text 表示するメッセージテキスト
  const AiMessage({
    super.key,
    required this.text,
  });

  /// 表示するメッセージテキスト
  final String text;

  @override
  State<AiMessage> createState() => _AiMessageState();
}

class _AiMessageState extends State<AiMessage> {
  RenderingState renderingState = RenderingState.none; // レンダリングの状態
  Size renderSize = Size.zero; // レンダリングされたテキストのサイズ
  GlobalKey textKey = GlobalKey(); // テキストのグローバルキー
  bool _hasRendered = false; // レンダリングが完了したかどうかのフラグ

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
                child: renderingState != RenderingState.complete &&
                        !_hasRendered
                    ? AnimatedTextKit(
                        key: textKey,
                        animatedTexts: [
                          TypewriterAnimatedText(
                            widget.text,
                            textStyle: const TextStyle(
                              color: FcColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        onFinished: () {
                          // アニメーションが終了したときの処理
                          setState(() {
                            _hasRendered = true;
                            renderingState = RenderingState.complete;
                            renderSize = (textKey.currentContext != null
                                ? textKey.currentContext!.size
                                : const Size(300, 100))!;
                          });
                        },
                        totalRepeatCount: 1,
                      )
                    : SizedBox(
                        width: renderSize.width,
                        height: renderSize.height,
                        child: SelectableText.rich(
                          TextSpan(
                              text: widget.text,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: FcColors.black,
                                  )),
                          onSelectionChanged: (selection, cause) async {
                            // テキストが選択されたときの処理
                            if (cause != null &&
                                cause == SelectionChangedCause.longPress) {
                              final selected = widget.text
                                  .substring(selection.start, selection.end);
                              await Clipboard.setData(
                                  ClipboardData(text: selected));
                            }
                          },
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
