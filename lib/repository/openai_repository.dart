import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// OpenAIのAPIとの通信を行うリポジトリクラス
class OpenAiRepository {
  /// OpenAIにリクエストを送信する
  ///
  /// @param prompt 送信するプロンプト
  /// @return APIからのレスポンス
  static Future<Map<String, dynamic>> sendMessage({
    required String prompt,
  }) async {
    final aiToken = dotenv.env['aiToken'];
    final model = dotenv.env['model'] ?? 'gpt-4o-mini-2024-07-18';
    final headers = {
      'Authorization': 'Bearer $aiToken',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'model': model, // 最新のモデル名に更新
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0,
      'max_completion_tokens': 2000, // パラメーター名を最新仕様に合わせて変更
    });

    try {
      final endpoint = dotenv.env['endpoint'] ?? 'https://api.openai.com/v1/';
      final response = await http.post(
        Uri.parse(
            '${endpoint.endsWith('/') ? endpoint : '$endpoint/'}chat/completions'),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        return {
          'status': false,
          'message': 'Error: ${response.statusCode} - ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }
}
