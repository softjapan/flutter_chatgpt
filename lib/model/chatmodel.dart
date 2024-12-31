import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chatgpt/repository/openai_repository.dart';
import 'package:flutter_chatgpt/widgets/ai_message.dart';
import 'package:flutter_chatgpt/widgets/loading.dart';
import 'package:flutter_chatgpt/widgets/user_message.dart';

/// Chat Model
class ChatModel extends ChangeNotifier {
  /// List of messages.
  List<Widget> messages = [];

  /// Message list getter.
  List<Widget> get getMessages => messages;

  /// Sends chat request to OpenAI chat server.
  Future<void> sendChat(String txt) async {
    addUserMessage(txt);

    final response = await OpenAiRepository.sendMessage(prompt: txt);
    if (response['status'] == false) {
      // エラー処理
      messages
        ..removeLast()
        ..add(AiMessage(text: response['message']?.toString() ?? 'エラーが発生しました'));
    } else {
      final content = response['choices'][0]['message']['content'];
      final decodedContent = utf8.decode(content.toString().codeUnits);
      messages
        ..removeLast()
        ..add(AiMessage(text: decodedContent));
    }

    notifyListeners();
  }

  /// Adds a new message to the list.
  void addUserMessage(String txt) {
    messages
      ..add(UserMessage(text: txt))
      ..add(const Loading(text: 'thinking...'));
    notifyListeners();
  }
}

final chatProvider = ChangeNotifierProvider((ref) => ChatModel());
