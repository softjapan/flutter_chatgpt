import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_chatgpt/model/chatmodel.dart';
import 'package:flutter_chatgpt/widgets/user_input.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

/// Main app class
class MyApp extends StatefulWidget {
  /// Constructor
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初期化後にコールバックを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final container = ProviderScope.containerOf(context);
      final chatModel = container.read(chatProvider);
      chatModel.setScrollCallback(_scrollToBottom);
      chatModel.setUpdateCallback(_scrollToBottomForStream);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // 即座にスクロール
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

      // レンダリング完了後に再度スクロール
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });

      // 遅延後に再度スクロール
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  void _scrollWithRetryForStream(int attempt) {
    if (!_scrollController.hasClients) {
      print(
          'DEBUG: Stream scroll - ScrollController lost clients during retry attempt $attempt');
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    print(
        'DEBUG: Stream scroll attempt $attempt, maxScrollExtent: $maxScroll, current: $currentScroll');

    // 常に一番上にスクロール（maxScrollExtentの値に関係なく）
    print('DEBUG: Stream scrolling to top (position 0)');
    _scrollController.jumpTo(0.0);
    print(
        'DEBUG: Stream scroll completed, new position: ${_scrollController.position.pixels}');
  }

  void _scrollToBottomForStream() {
    if (_scrollController.hasClients) {
      // 即座にスクロール
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

      // Stream更新用のスクロール（一番下にスクロール）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });

      // 追加のスクロール処理（レイアウト完了後に実行）
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });

      // さらに遅延後にスクロール
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatcontroller = TextEditingController();

    return MaterialApp(
      title: 'Flutter ChatGPT',
      home: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: FcColors.skyblue,
          appBar: AppBar(
            backgroundColor: FcColors.white,
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.menu,
                color: FcColors.black,
              ),
            ),
            elevation: 0,
            title: Text(dotenv.env['model'] ?? 'gpt-4o-mini-2024-07-18'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit,
                  color: FcColors.black,
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    onPressed: () {
                      final chatModel = ref.read(chatProvider);
                      chatModel.addUserMessage('Test message');

                      // ストリーミング更新をシミュレート
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        chatModel.simulateMultipleStreamingUpdates([
                          'Hello',
                          'Hello, this',
                          'Hello, this is',
                          'Hello, this is a',
                          'Hello, this is a streaming',
                          'Hello, this is a streaming test',
                          'Hello, this is a streaming test message',
                          'Hello, this is a streaming test message that should auto-scroll as it updates.',
                          'Hello, this is a streaming test message that should auto-scroll as it updates. This is a longer message to ensure scrolling is needed.',
                          'Hello, this is a streaming test message that should auto-scroll as it updates. This is a longer message to ensure scrolling is needed. The scroll should happen automatically with each update.'
                        ]);
                      });
                    },
                    icon: const Icon(
                      Icons.play_arrow,
                      color: FcColors.black,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Consumer(builder: (context, ref, child) {
            final chatModel = ref.watch(chatProvider);
            final messages = chatModel.getMessages;

            return Stack(
              children: [
                //chat
                Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // レイアウト完了後に一番下にスクロール
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent);
                        }
                      });

                      return ListView(
                        controller: _scrollController,
                        children: [
                          const Divider(
                            color: FcColors.gray,
                          ),
                          for (int i = 0; i < messages.length; i++) messages[i]
                        ],
                      );
                    },
                  ),
                ),
                //input
                UserInput(
                  chatcontroller: chatcontroller,
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
