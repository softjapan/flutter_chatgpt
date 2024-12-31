import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_chatgpt/model/chatmodel.dart';

/// ユーザーの入力を受け付けるウィジェット
class UserInput extends ConsumerWidget {
  /// コンストラクタ
  ///
  /// @param key ウィジェットのキー
  /// @param chatcontroller テキスト入力を制御するコントローラー
  const UserInput({
    super.key,
    required this.chatcontroller,
  });

  /// テキスト入力を制御するコントローラー
  final TextEditingController chatcontroller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 5,
          right: 5,
        ),
        decoration: const BoxDecoration(
          color: FcColors.white,
          border: Border(
            top: BorderSide(
              color: FcColors.white,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'images/user-question.svg', // ユーザーアバターの画像
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                onFieldSubmitted: (e) {
                  ref.read(chatProvider).sendChat(e); // 入力されたテキストを送信
                  chatcontroller.clear(); // 入力フィールドをクリア
                },
                controller: chatcontroller,
                textInputAction: TextInputAction.send,
                style: const TextStyle(
                  color: FcColors.black,
                ),
                decoration: const InputDecoration(
                  focusColor: FcColors.gray,
                  filled: true,
                  fillColor: FcColors.white,
                  suffixIcon: Icon(
                    Icons.send,
                    color: FcColors.gray,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FcColors.gray,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FcColors.gray,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
