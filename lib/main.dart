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
            ],
          ),
          body: Consumer(builder: (context, ref, child) {
            final messages = ref.watch(chatProvider).getMessages;
            return Stack(
              children: [
                //chat

                Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  child: ListView(
                    children: [
                      const Divider(
                        color: FcColors.gray,
                      ),
                      for (int i = 0; i < messages.length; i++) messages[i]
                    ],
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
