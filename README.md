# Flutter ChatGPT Client

**LangChain + Flutter + Riverpod によるリアルタイム ChatGPT クライアント**

![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter) ![Riverpod](https://img.shields.io/badge/Riverpod-2.x-50C878?logo=dart) ![LangChain](https://img.shields.io/badge/LangChain-Dart-2e7d32) ![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

---

## 概要

Flutter と Riverpod をベースにした LINE 風 UI の ChatGPT クライアントです。  
LangChain + LangChain OpenAI を採用し、チャット履歴を LangChain のチャットモデルへストリーミング連携することで、段階的なトーク更新と Markdown レンダリングを実現します。  
フロントエンドは純 Flutter で構築し、AI モデルとの通信はリポジトリ層で完全に抽象化。モバイル／デスクトップのクロスプラットフォーム展開を前提としたアーキテクチャです。

---

## ハイライト

- **LLM 連携の最新アプローチ**  
  LangChain のチャットモデル (`ChatOpenAI`) とストリーミング API を利用し、トーク生成の途中経過を自然に反映。
- **堅牢な状態管理**  
  Riverpod (`ChangeNotifierProvider`) により、UI/状態/ドメインロジックを明確に分離。ユニットテスト容易性も確保。
- **Markdown レンダリングによるリッチな表示**  
  `flutter_markdown` で数式・コードブロック・リストなどをネイティブ描画。選択・コピーにも対応。
- **UI/UX に配慮したチャット体験**  
  ユーザー・AI 双方のバブル表現、Thinking インジケーター、ストリーミング時のプログレス表示を備えた LINE ライクな UI。
- **実務レベルの設定管理**  
  `.env` で API キーやモデル、エンドポイントを切り替え可能。OpenAI 互換のプロキシやカスタムエンドポイントにも対応。

---

## アーキテクチャ概要

```
lib/
├── main.dart                     # エントリポイント + UI ルート
├── model/
│   ├── chat_message.dart         # 不変メッセージモデル (データ層)
│   └── chatmodel.dart            # ChangeNotifier (状態管理)
├── repository/
│   └── openai_repository.dart    # LangChain を使った LLM アクセス
└── widgets/                      # プレゼンテーション層
    ├── ai_message.dart
    ├── loading.dart
    ├── user_input.dart
    └── user_message.dart
```

- **Presentation**: Flutter Widgets (Material Design) + Markdown 表示  
- **State Management**: Riverpod ChangeNotifier を利用したメッセージストア  
- **Domain / Data**: LangChain による LLM 呼び出し、OpenAI 互換エンドポイント対応  
- **Testing**: `flutter_test` によるスモークテストを用意し、ProviderScope での依存解決を検証

---

## 技術スタック

| Layer            | Technology & Packages                                                                 |
| ---------------- | -------------------------------------------------------------------------------------- |
| UI/Presentation  | Flutter, Material Design, `flutter_markdown`, `flutter_svg`                            |
| State Management | Riverpod (`flutter_riverpod`)                                                          |
| LLM Integration  | LangChain (`langchain`), LangChain OpenAI (`langchain_openai`), `langchain_tiktoken`   |
| Config/Env       | `flutter_dotenv`                                                                       |
| Tooling          | Dart 3.3+, Flutter 3.19+, Very Good Analysis, Flutter Test                             |

---

## セットアップ

1. **リポジトリを取得**
   ```bash
   git clone https://github.com/softjapan/flutter_chatgpt.git
   cd flutter_chatgpt
   ```

2. **依存関係の取得**
   ```bash
   flutter pub get
   ```

3. **環境変数の設定**  
   ルート直下に `.env` を作成し、以下を設定してください。
   ```env
   endpoint=https://api.openai.com/v1
   model=gpt-4o-mini-2024-07-18
   aiToken=your-openai-api-key
   ```

4. **アプリの起動**
   ```bash
   flutter run
   ```

---

## コマンドチートシート

| Purpose            | Command                        |
| ------------------ | ------------------------------ |
| 依存関係の更新     | `flutter pub get`              |
| LangChain の追加例 | `flutter pub add langchain`    |
| テスト実行         | `flutter test`                 |
| L10n/ビルド等      | `flutter build <platform>`     |

---

## スクリーンショット & デモ

![チャット画面](./flutter-chatgpt.png)

### デモ動画
[flutter-chatgpt.webm](https://github.com/user-attachments/assets/f21f61c9-41c2-42cc-8422-e136c1078e3d)

---

## コントリビューション

1. リポジトリを **Fork**
2. ブランチを作成  
   ```bash
   git checkout -b feature/awesome-feature
   ```
3. 変更をコミット  
   ```bash
   git commit -m "Add awesome feature"
   ```
4. Push & Pull Request  
   ```bash
   git push origin feature/awesome-feature
   ```

---

## ライセンス

このプロジェクトは [MIT License](./LICENSE) の下で公開されています。

---

## Author

- **Twitter**: [システムエンジニア@JP](https://twitter.com/fullstack_se)  
- **GitHub**: [softjapan/flutter_chatgpt](https://github.com/softjapan/flutter_chatgpt)

---

### English Summary

A Flutter + Riverpod ChatGPT client leveraging LangChain’s `ChatOpenAI` for streaming responses, delivering a LINE-style chat experience with Markdown rendering, responsive UI, and environment-driven configuration. Cross-platform ready, production-oriented architecture with clear separation of concerns and automated testing.
