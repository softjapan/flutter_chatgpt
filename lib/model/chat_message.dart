import 'package:flutter/foundation.dart';

/// 種類を表す列挙体
enum ChatSender {
  /// ユーザーからのメッセージ
  user,

  /// AI からのメッセージ
  assistant,
}

/// メッセージの状態を表す列挙体
enum ChatMessageStatus {
  /// コンテンツ生成待機中（ローディング）
  loading,

  /// ストリーミング中（部分的な出力）
  streaming,

  /// 応答完了
  complete,
}

/// チャットメッセージのデータモデル
@immutable
class ChatMessage {
  /// コンストラクタ
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.status,
  });

  /// メッセージを一意に識別する ID
  final String id;

  /// メッセージの送信者
  final ChatSender sender;

  /// メッセージ本文
  final String text;

  /// メッセージの状態
  final ChatMessageStatus status;

  /// ローディング中かどうか
  bool get isLoading => status == ChatMessageStatus.loading;

  /// ストリーミング中かどうか
  bool get isStreaming => status == ChatMessageStatus.streaming;

  /// 完了済みかどうか
  bool get isComplete => status == ChatMessageStatus.complete;

  /// メッセージのコピーを作成
  ChatMessage copyWith({
    String? id,
    ChatSender? sender,
    String? text,
    ChatMessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      status: status ?? this.status,
    );
  }
}
