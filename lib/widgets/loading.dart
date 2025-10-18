import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ローディング中を表示するウィジェット
class Loading extends StatefulWidget {
  /// コンストラクタ
  ///
  /// @param key ウィジェットのキー
  /// @param text 表示するテキスト
  const Loading({
    super.key,
    required this.text,
  });

  /// 表示するテキスト
  final String text;

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FcColors.gray,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent, // アバターの背景色
                ),
                child: SvgPicture.asset(
                  'images/ai-avatar.svg', // AIアバターの画像
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text, // 表示するテキスト
                  style: const TextStyle(
                    color: FcColors.white, // テキストの色
                    fontSize: 16, // フォントサイズ
                    fontWeight: FontWeight.w700, // フォントの太さ
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 14,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _WaveDotsPainter(progress: _controller.value),
                        size: Size(MediaQuery.of(context).size.width, 14),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveDotsPainter extends CustomPainter {
  const _WaveDotsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const dotCount = 5;
    const dotSize = 6.0;
    const spacing = 12.0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final startX =
        (size.width - ((dotCount - 1) * spacing) - dotSize) / 2; // 中央寄せ
    final baseY = size.height / 2;
    const amplitude = 6.0;

    for (var i = 0; i < dotCount; i++) {
      final phase = (progress * 2 * math.pi) + (i * 0.6);
      final yOffset = math.sin(phase) * amplitude;

      final dx = startX + (i * spacing);
      final dy = baseY - yOffset;

      canvas.drawCircle(Offset(dx, dy), dotSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveDotsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
