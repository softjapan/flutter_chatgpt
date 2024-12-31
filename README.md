# 日本語版

## Flutter × Riverpod で構築した ChatGPT クライアント (LINE 風チャット UI)

Flutter と Riverpod を使用して開発した LINE 風のチャット UI を特徴とする ChatGPT クライアントアプリケーションです。  
OpenAI GPT モデルとの連携により、リアルタイムでの双方向コミュニケーションを実現します。

---

### 特徴

- **LINE 風のチャット UI**  
  シンプルかつ見やすいデザインを採用し、直感的に操作できるユーザーインターフェース
- **OpenAI GPT モデルとのリアルタイムチャット**  
  ChatGPT API を活用し、人間らしい自然な対話を実現
- **Riverpod による状態管理**  
  ビジネスロジックと UI を分離することで、拡張性・保守性を向上
- **レスポンシブデザイン**  
  スマートフォンから大型端末まで、さまざまな画面サイズに対応したレイアウト

---

### スクリーンショット

![スクリーンショット](./flutter-chatgpt.png)

### 動画
[flutter-chatgpt.webm](https://github.com/user-attachments/assets/f21f61c9-41c2-42cc-8422-e136c1078e3d)

---

### 必要要件

- **Flutter** 3.19.x 以上
- **Dart** 3.3.x 以上
- **OpenAI API キー**

---

### セットアップ手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/softjapan/flutter_chatgpt.git
   ```
2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```
3. **環境変数の設定**  
   プロジェクトのルートディレクトリに `.env` ファイルを作成し、以下の内容を設定してください:
   ```
   endpoint='https://api.openai.com/v1/'
   model='gpt-4-turbo-preview'
   aiToken='your-api-key-here'
   ```
4. **アプリケーションの実行**
   ```bash
   flutter run
   ```

---

### 使用している主な技術

- [Flutter](https://flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [OpenAI API](https://platform.openai.com/)
- [Freezed](https://pub.dev/packages/freezed)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

---

### ライセンス

このプロジェクトは [MIT License](./LICENSE) の下で公開されています。詳細は [LICENSE](./LICENSE) ファイルをご覧ください。

---

### コントリビューションの方法

1. 本リポジトリを **Fork** する
2. フィーチャーブランチを作成する
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. 変更をコミットする
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. ブランチをリモートリポジトリにプッシュする
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Pull Request** を作成する

---

### 開発者

- **Twitter**: [FullStack@ITエンジニア](https://twitter.com/softbasejp)

リポジトリへのリンク: [https://github.com/softjapan/flutter_chatgpt](https://github.com/softjapan/flutter_chatgpt)

---

# English Version

## ChatGPT Client with LINE-Style UI Built with Flutter and Riverpod

This is a ChatGPT client application developed with Flutter and Riverpod, featuring a LINE-inspired chat UI.  
It provides real-time, bidirectional communication by integrating with OpenAI’s GPT models.

---

### Features

- **LINE-Style Chat UI**  
  A simple, intuitive design that offers a streamlined user experience
- **Real-Time Chat with OpenAI GPT Model**  
  Utilizes the ChatGPT API to enable natural, human-like conversations
- **State Management with Riverpod**  
  Improves scalability and maintainability by separating application logic from the UI
- **Responsive Design**  
  Adapts seamlessly to various screen sizes, from smartphones to larger devices

---

### Screenshots

![Screenshot](./flutter-chatgpt.png)

### Video
[flutter-chatgpt.webm](https://github.com/user-attachments/assets/f21f61c9-41c2-42cc-8422-e136c1078e3d)

---

### Requirements

- **Flutter** 3.19.x or higher
- **Dart** 3.3.x or higher
- **OpenAI API Key**

---

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/softjapan/flutter_chatgpt.git
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Configure environment variables**  
   Create a `.env` file in the project’s root directory and add the following:
   ```
   endpoint='https://api.openai.com/v1/'
   model='gpt-4-turbo-preview'
   aiToken='your-api-key-here'
   ```
4. **Run the application**
   ```bash
   flutter run
   ```

---

### Technologies Used

- [Flutter](https://flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [OpenAI API](https://platform.openai.com/)
- [Freezed](https://pub.dev/packages/freezed)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

---

### License

This project is released under the [MIT License](./LICENSE). Please see the [LICENSE](./LICENSE) file for details.

---

### How to Contribute

1. **Fork** this repository
2. Create a new feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. Push the branch to the remote repository
   ```bash
   git push origin feature/amazing-feature
   ```
5. Create a **Pull Request**

---

### Author

- **Twitter**: [FullStack@ITエンジニア](https://twitter.com/softbasejp)

GitHub Repository: [https://github.com/softjapan/flutter_chatgpt](https://github.com/softjapan/flutter_chatgpt)
