import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain/langchain.dart' as lc;
import 'package:langchain_openai/langchain_openai.dart';

import 'package:flutter_chatgpt/model/chat_message.dart';

/// OpenAIのAPIとの通信を行うリポジトリクラス
class OpenAiRepository {
  OpenAiRepository._();

  static ChatOpenAI? _chatModel;

  /// OpenAIにリクエストを送信する
  ///
  /// @param prompt 送信するプロンプト
  /// @return APIからのレスポンス
  static Future<String> generate({
    required List<ChatMessage> history,
  }) async {
    final model = _ensureChatModel();
    final prompt = lc.PromptValue.chat(_buildPrompt(history));
    final result = await model.invoke(prompt);
    return result.outputAsString;
  }

  /// LangChain経由でストリーミング応答を取得する
  static Stream<String> stream({
    required List<ChatMessage> history,
  }) {
    final model = _ensureChatModel();
    final prompt = lc.PromptValue.chat(_buildPrompt(history));
    var buffer = '';

    return model.stream(prompt).map((chunk) {
      final delta = chunk.output.content;
      if (delta.isEmpty) {
        return buffer;
      }
      buffer += delta;
      return buffer;
    });
  }

  static ChatOpenAI _ensureChatModel() {
    final token = dotenv.env['aiToken'];
    if (token == null || token.isEmpty) {
      throw StateError(
        'OpenAI API key is missing. Please set aiToken in the .env file.',
      );
    }

    final endpoint = dotenv.env['endpoint'];
    final baseUrl = endpoint != null && endpoint.isNotEmpty
        ? endpoint.endsWith('/')
            ? endpoint.substring(0, endpoint.length - 1)
            : endpoint
        : null;
    final modelName = dotenv.env['model'] ?? 'gpt-4o-mini-2024-07-18';

    return _chatModel ??= ChatOpenAI(
      apiKey: token,
      baseUrl: baseUrl ?? 'https://api.openai.com/v1',
      defaultOptions: ChatOpenAIOptions(
        model: modelName,
        temperature: 0,
        maxTokens: 2000,
      ),
    );
  }

  static List<lc.ChatMessage> _buildPrompt(List<ChatMessage> history) {
    final prompt = <lc.ChatMessage>[];

    for (final message in history) {
      if (!message.isComplete) {
        continue;
      }

      if (message.sender == ChatSender.user) {
        prompt.add(lc.ChatMessage.humanText(message.text));
      } else if (message.sender == ChatSender.assistant) {
        prompt.add(lc.ChatMessage.ai(message.text));
      }
    }

    return prompt;
  }
}
