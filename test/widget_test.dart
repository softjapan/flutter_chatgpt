// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_chatgpt/main.dart';
import 'package:flutter_chatgpt/widgets/user_input.dart';
import 'package:flutter_chatgpt/widgets/user_message.dart';
import 'package:flutter_chatgpt/widgets/loading.dart';

void main() {
  testWidgets('ChatGPT App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('gpt-4o-mini-2024-07-18'), findsOneWidget);

    // Verify that the user input field is displayed
    expect(find.byType(UserInput), findsOneWidget);
  });

  testWidgets('User message is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UserMessage(text: 'Hello'),
      ),
    );
    expect(find.text('Hello'), findsOneWidget);
  });

  // testWidgets('AI message is displayed', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     const MaterialApp(
  //       home: AiMessage(text: 'Hi there!'),
  //     ),
  //   );
  //   expect(find.text('Hi there!'), findsOneWidget);
  // });

  testWidgets('Loading widget is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Loading(text: 'thinking...'),
      ),
    );
    expect(find.text('thinking...'), findsOneWidget);
  });
}
