import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chatgpt/model/chat_message.dart';
import 'package:flutter_chatgpt/repository/openai_repository.dart';

/// Chat Model
class ChatModel extends ChangeNotifier {
  ChatModel();

  int _idSeed = 0;

  /// List of messages (immutable view).
  final List<ChatMessage> _messages = [];

  /// Message list getter.
  UnmodifiableListView<ChatMessage> get messages =>
      UnmodifiableListView(_messages);

  /// Callback function for auto-scrolling
  VoidCallback? onMessageAdded;

  /// Callback function for message updates (for streaming)
  VoidCallback? onMessageUpdated;

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
    if (txt.trim().isEmpty) {
      return;
    }

    addUserMessage(txt);

    try {
      final historySnapshot = List<ChatMessage>.from(_messages);
      var latestContent = '';

      await for (final partial
          in OpenAiRepository.stream(history: historySnapshot)) {
        if (partial.isEmpty) {
          continue;
        }
        latestContent = partial;
        addStreamingUpdate(latestContent);
      }

      if (latestContent.isEmpty) {
        final finalHistory = List<ChatMessage>.from(_messages);
        latestContent = await OpenAiRepository.generate(history: finalHistory);
        if (latestContent.isNotEmpty) {
          addStreamingUpdate(latestContent);
        }
      }

      completeStreaming(latestContent);
    } catch (e) {
      _handleAssistantError('An unexpected error occurred: $e');
    }
  }

  /// Adds a new message to the list.
  void addUserMessage(String txt) {
    if (txt.trim().isEmpty) {
      return;
    }

    _messages
      ..add(
        ChatMessage(
          id: _nextId(),
          sender: ChatSender.user,
          text: txt,
          status: ChatMessageStatus.complete,
        ),
      )
      ..add(
        ChatMessage(
          id: _nextId(),
          sender: ChatSender.assistant,
          text: 'thinking...',
          status: ChatMessageStatus.loading,
        ),
      );
    notifyListeners();

    // ユーザーメッセージ追加後にスクロール
    if (onMessageAdded != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMessageAdded!();
      });
    }
  }

  /// Adds a streaming message update
  void addStreamingUpdate(String partialContent) {
    if (_messages.isEmpty) {
      return;
    }

    final lastIndex = _messages.length - 1;
    final lastMessage = _messages[lastIndex];

    if (lastMessage.sender != ChatSender.assistant) {
      return;
    }

    if (lastMessage.isLoading) {
      // Loading をストリーミングメッセージに置き換え
      _messages[lastIndex] = lastMessage.copyWith(
        text: partialContent,
        status: ChatMessageStatus.streaming,
      );
      notifyListeners();

      // Stream更新後にスクロール
      if (onMessageUpdated != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessageUpdated!();
        });
      }
    } else {
      // 既存のAIメッセージを更新
      _messages[lastIndex] = lastMessage.copyWith(
        text: partialContent,
        status: ChatMessageStatus.streaming,
      );
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
    for (final update in updates) {
      addStreamingUpdate(update);
      // 各更新間に少し遅延を入れる
      Future.delayed(const Duration(milliseconds: 100), () {});
    }
  }

  String _nextId() {
    _idSeed += 1;
    return _idSeed.toString();
  }

  void completeStreaming(String content) {
    if (_messages.isEmpty) {
      return;
    }

    final lastIndex = _messages.length - 1;
    final lastMessage = _messages[lastIndex];
    if (lastMessage.sender != ChatSender.assistant) {
      return;
    }

    _messages[lastIndex] = lastMessage.copyWith(
      text: content.isEmpty ? lastMessage.text : content,
      status: ChatMessageStatus.complete,
    );
    notifyListeners();

    if (onMessageUpdated != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMessageUpdated!();
      });
    }
  }

  void _handleAssistantError(String message) {
    if (_messages.isNotEmpty &&
        _messages.last.sender == ChatSender.assistant &&
        !_messages.last.isComplete) {
      _messages.removeLast();
    }

    _messages.add(
      ChatMessage(
        id: _nextId(),
        sender: ChatSender.assistant,
        text: message,
        status: ChatMessageStatus.complete,
      ),
    );
    notifyListeners();

    if (onMessageAdded != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMessageAdded!();
      });
    }
  }
}

final chatProvider = ChangeNotifierProvider((ref) => ChatModel());
