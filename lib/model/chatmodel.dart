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

  /// Callback function for auto-scrolling
  VoidCallback? onMessageAdded;

  /// Callback function for message updates (for streaming)
  VoidCallback? onMessageUpdated;

  /// Message list getter.
  List<Widget> get getMessages => messages;

  /// Sets the callback for auto-scrolling
  void setScrollCallback(VoidCallback callback) {
    onMessageAdded = callback;
  }

  /// Sets the callback for message updates (streaming)
  void setUpdateCallback(VoidCallback callback) {
    onMessageUpdated = callback;
  }

  /// Sends chat request to OpenAI chat server.
  Future<void> sendChat(String txt) async {
    addUserMessage(txt);

    final response = await OpenAiRepository.sendMessage(prompt: txt);
    if (response['status'] == false) {
      // エラー処理
      messages
        ..removeLast()
        ..add(AiMessage(
            text: response['message']?.toString() ?? 'エラーが発生しました',
            isStreaming: false));
      notifyListeners();

      // エラーメッセージ追加後にスクロール
      if (onMessageAdded != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessageAdded!();
        });
      }
    } else {
      final content = response['choices'][0]['message']['content'] as String;
      messages
        ..removeLast()
        ..add(AiMessage(text: content, isStreaming: false));
      notifyListeners();

      // AI応答完了後にスクロール
      if (onMessageAdded != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessageAdded!();
        });
      }
    }
  }

  /// Adds a new message to the list.
  void addUserMessage(String txt) {
    messages
      ..add(UserMessage(text: txt))
      ..add(const Loading(text: 'thinking...'));
    notifyListeners();

    // ユーザーメッセージ追加後にスクロール
    if (onMessageAdded != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMessageAdded!();
      });
    }
  }

  /// Updates the last message (for streaming)
  void updateLastMessage(Widget newMessage) {
    if (messages.isNotEmpty) {
      messages[messages.length - 1] = newMessage;
      notifyListeners();

      // メッセージ更新後にスクロール（Stream更新用）
      if (onMessageUpdated != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessageUpdated!();
        });
      }
    }
  }

  /// Adds a streaming message update
  void addStreamingUpdate(String partialContent) {
    if (messages.isNotEmpty && messages.last is Loading) {
      // Loadingを削除して新しいAIメッセージを追加
      messages.removeLast();
      messages.add(AiMessage(text: partialContent, isStreaming: true));
      notifyListeners();

      // Stream更新後にスクロール
      if (onMessageUpdated != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessageUpdated!();
        });
      }
    } else if (messages.isNotEmpty && messages.last is AiMessage) {
      // 既存のAIメッセージを更新
      messages[messages.length - 1] =
          AiMessage(text: partialContent, isStreaming: true);
      notifyListeners();

      // Stream更新後にスクロール
      if (onMessageUpdated != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessageUpdated!();
        });
      }
    }
  }

  /// Test method to simulate streaming updates
  void simulateStreamingUpdate(String partialContent) {
    addStreamingUpdate(partialContent);
  }

  /// Test method to simulate multiple streaming updates
  void simulateMultipleStreamingUpdates(List<String> updates) {
    for (int i = 0; i < updates.length; i++) {
      final update = updates[i];
      addStreamingUpdate(update);
      // 各更新間に少し遅延を入れる
      Future.delayed(const Duration(milliseconds: 100), () {});
    }
  }
}

final chatProvider = ChangeNotifierProvider((ref) => ChatModel());
