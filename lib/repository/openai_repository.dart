import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:langchain/langchain.dart' as lc;
import 'package:langchain_openai/langchain_openai.dart';

import 'package:flutter_chatgpt/model/chat_message.dart';

/// OpenAIのAPIとの通信を行うリポジトリクラス
class OpenAiRepository {
  OpenAiRepository._();

  static ChatOpenAI? _chatModel;
  static final http.Client _httpClient = http.Client();

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

  static Future<String> generateImage({required String prompt}) async {
    final modelName = dotenv.env['imageModel'] ?? 'gpt-image-1';
    final token = _requireToken();
    final baseUrl = _normalizedBaseUrl();
    final uri = Uri.parse('$baseUrl/images/generations');

    try {
      final response = await _httpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': modelName,
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode != 200) {
        throw StateError(
          'Image generation failed: ${response.statusCode} ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as List<dynamic>? ?? [];
      if (data.isEmpty) {
        throw StateError('No image payload returned from API.');
      }

      final first = data.first as Map<String, dynamic>;
      final url = first['url'] as String?;
      final b64 = first['b64_json'] as String?;

      if (url != null && url.isNotEmpty) {
        return url;
      }
      if (b64 != null && b64.isNotEmpty) {
        return 'data:image/png;base64,$b64';
      }
      throw StateError('Image payload missing URL and base64 content.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static String _requireToken() {
    final token = dotenv.env['aiToken'];
    if (token == null || token.isEmpty) {
      throw StateError(
        'OpenAI API key is missing. Please set aiToken in the .env file.',
      );
    }
    return token;
  }

  static String _normalizedBaseUrl() {
    final endpoint = dotenv.env['endpoint'];
    final base = endpoint != null && endpoint.isNotEmpty
        ? endpoint
        : 'https://api.openai.com/v1/';
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
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
        if (message.hasImage) {
          final description = message.altText?.trim().isNotEmpty == true
              ? message.altText!.trim()
              : 'Generated an image.';
          prompt.add(lc.ChatMessage.ai('Generated image: $description'));
        } else {
          prompt.add(lc.ChatMessage.ai(message.text));
        }
      }
    }

    return prompt;
  }
}
