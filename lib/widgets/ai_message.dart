import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// AIのメッセージを表示するウィジェットクラス
class AiMessage extends StatelessWidget {
  /// コンストラクタ
  const AiMessage({
    super.key,
    required this.text,
    this.isStreaming = false,
    this.imageUrl,
    this.altText,
  });

  /// 表示するメッセージテキスト
  final String text;

  /// ストリーミング中かどうか
  final bool isStreaming;

  /// 表示する画像URL（画像応答の場合）
  final String? imageUrl;

  /// 画像の説明文
  final String? altText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent,
                  ),
                  child: SvgPicture.asset(
                    'images/ai-avatar.svg',
                    height: 30,
                    width: 30,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (imageUrl != null && imageUrl!.isNotEmpty)
                        _ImageBubble(
                          imageUrl: imageUrl!,
                          caption: _captionText,
                          onTap: () => _openImageViewer(context),
                        )
                      else ...[
                        MarkdownBody(
                          data: text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            Theme.of(context).copyWith(
                              textTheme: Theme.of(context).textTheme.apply(
                                    bodyColor: FcColors.black,
                                    displayColor: FcColors.black,
                                  ),
                            ),
                          ),
                        ),
                        if (isStreaming) ...[
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? get _captionText {
    if (altText != null && altText!.trim().isNotEmpty) {
      return altText!.trim();
    }
    if (text.trim().isNotEmpty) {
      return text.trim();
    }
    return null;
  }

  Future<void> _openImageViewer(BuildContext context) async {
    final imageSrc = imageUrl;
    if (imageSrc == null || imageSrc.isEmpty) {
      return;
    }
    final caption = _captionText;
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (dialogContext) => _ImageViewerDialog(
        imageUrl: imageSrc,
        caption: caption,
        onDownload: () => _downloadImage(messenger),
      ),
    );
  }

  Future<void> _downloadImage(ScaffoldMessengerState messenger) async {
    if (kIsWeb) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Webではダウンロードに対応していません。'),
        ),
      );
      return;
    }

    try {
      final bytes = await _loadImageBytes();
      final directory = await getApplicationDocumentsDirectory();
      final filename = 'ai_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = io.File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);

      messenger.showSnackBar(
        SnackBar(
          content: Text('画像を保存しました: ${file.path}'),
          action: SnackBarAction(
            label: '閉じる',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('保存に失敗しました: $e'),
        ),
      );
    }
  }

  Future<Uint8List> _loadImageBytes() async {
    final imageSrc = imageUrl;
    if (imageSrc == null || imageSrc.isEmpty) {
      throw StateError('Image source is empty.');
    }

    if (imageSrc.startsWith('data:image')) {
      return _decodeDataUri(imageSrc);
    }

    final response = await http.get(Uri.parse(imageSrc));
    if (response.statusCode != 200) {
      throw StateError('Failed to download image data.');
    }
    return response.bodyBytes;
  }
}

class _ImageBubble extends StatelessWidget {
  const _ImageBubble({
    required this.imageUrl,
    this.caption,
    this.onTap,
  });

  final String imageUrl;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildPreview(),
          ),
        ),
        if (caption != null && caption!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            caption!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FcColors.black.withOpacity(0.7),
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreview() {
    if (imageUrl.startsWith('data:image')) {
      final bytes = _decodeDataUri(imageUrl);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.high,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: FcColors.gray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: FcColors.gray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.broken_image, color: Colors.white70),
      ),
    );
  }
}

class _ImageViewerDialog extends StatelessWidget {
  const _ImageViewerDialog({
    required this.imageUrl,
    required this.onDownload,
    this.caption,
  });

  final String imageUrl;
  final String? caption;
  final Future<void> Function() onDownload;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: _FullscreenImage(imageUrl: imageUrl),
              ),
            ),
            if (caption != null && caption!.isNotEmpty)
              Positioned(
                left: 24,
                right: 24,
                bottom: 80,
                child: Text(
                  caption!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'ダウンロード',
                    icon: const Icon(Icons.download_outlined,
                        color: Colors.white),
                    onPressed: onDownload,
                  ),
                  IconButton(
                    tooltip: '閉じる',
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image')) {
      final bytes = _decodeDataUri(imageUrl);
      return Center(
        child: Image.memory(
          bytes,
          fit: BoxFit.contain,
        ),
      );
    }

    return Center(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image, color: Colors.white70, size: 64),
      ),
    );
  }
}

Uint8List _decodeDataUri(String uri) {
  final commaIndex = uri.indexOf(',');
  final data = commaIndex != -1 ? uri.substring(commaIndex + 1) : uri;
  return base64Decode(data);
}
