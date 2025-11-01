import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrimmedAssetImage extends StatefulWidget {
  const TrimmedAssetImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final BoxFit fit;

  @override
  State<TrimmedAssetImage> createState() => _TrimmedAssetImageState();
}

class _TrimmedAssetImageState extends State<TrimmedAssetImage> {
  late final Future<Uint8List> _imageFuture = _ImageTrimmer.trimmedBytes(
    widget.assetPath,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: const SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Container(
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: const Text(
              'No se pudo cargar la imagen del ejercicio.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return Image.memory(
          snapshot.data!,
          fit: widget.fit,
          filterQuality: FilterQuality.high,
        );
      },
    );
  }
}

class _ImageTrimmer {
  _ImageTrimmer._();

  static final Map<String, Future<Uint8List>> _cache = {};

  static Future<Uint8List> trimmedBytes(String assetPath) {
    return _cache.putIfAbsent(assetPath, () async {
      final originalData = await rootBundle.load(assetPath);
      final originalBytes = originalData.buffer.asUint8List();
      try {
        final codec = await ui.instantiateImageCodec(originalBytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;
        final width = image.width;
        final height = image.height;
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData == null) {
          image.dispose();
          return originalBytes;
        }
        final pixels = byteData.buffer.asUint8List();
        const threshold = 235;

        bool rowHasInk(int y) {
          final rowOffset = y * width * 4;
          for (var x = 0; x < width; x++) {
            final offset = rowOffset + x * 4;
            final a = pixels[offset + 3];
            if (a < 8) continue;
            final r = pixels[offset];
            final g = pixels[offset + 1];
            final b = pixels[offset + 2];
            if (r < threshold || g < threshold || b < threshold) {
              return true;
            }
          }
          return false;
        }

        bool columnHasInk(int x) {
          final offset = x * 4;
          for (var y = 0; y < height; y++) {
            final index = y * width * 4 + offset;
            final a = pixels[index + 3];
            if (a < 8) continue;
            final r = pixels[index];
            final g = pixels[index + 1];
            final b = pixels[index + 2];
            if (r < threshold || g < threshold || b < threshold) {
              return true;
            }
          }
          return false;
        }

        var top = 0;
        while (top < height && !rowHasInk(top)) {
          top++;
        }
        var bottom = height - 1;
        while (bottom > top && !rowHasInk(bottom)) {
          bottom--;
        }
        var left = 0;
        while (left < width && !columnHasInk(left)) {
          left++;
        }
        var right = width - 1;
        while (right > left && !columnHasInk(right)) {
          right--;
        }

        // If we failed to detect a meaningful crop, return original data.
        if (left >= right || top >= bottom) {
          image.dispose();
          return originalBytes;
        }

        const padding = 22;
        final expandedLeft = (left - padding).clamp(0, width - 1);
        final expandedTop = (top - padding).clamp(0, height - 1);
        final expandedRight = (right + padding).clamp(0, width - 1);
        final expandedBottom = (bottom + padding).clamp(0, height - 1);

        final gapCandidates = <int>[];
        var blankStreak = 0;
        const gapThreshold = 80;
        for (var y = expandedTop; y <= expandedBottom; y++) {
          if (rowHasInk(y)) {
            blankStreak = 0;
            continue;
          }
          blankStreak++;
          if (blankStreak == gapThreshold) {
            gapCandidates.add(y - gapThreshold ~/ 2);
          }
        }

        var adjustedBottom = expandedBottom;
        if (gapCandidates.isNotEmpty) {
          final useful =
              gapCandidates
                  .where((candidate) => candidate - expandedTop > 180)
                  .toList()
                ..sort();
          if (useful.isNotEmpty) {
            adjustedBottom = useful.first;
          }
        }

        final cropRect = Rect.fromLTRB(
          expandedLeft.toDouble(),
          expandedTop.toDouble(),
          (expandedRight + 1).toDouble(),
          (adjustedBottom + 1).toDouble(),
        );
        final newWidth = cropRect.width.round();
        final newHeight = cropRect.height.round();

        final originalArea = width * height;
        final trimmedArea = newWidth * newHeight;
        if (trimmedArea > originalArea * 0.92) {
          image.dispose();
          return originalBytes;
        }

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(
          recorder,
          Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
        );
        final paint = Paint();
        canvas.drawImageRect(
          image,
          cropRect,
          Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
          paint,
        );
        final trimmedImage = await recorder.endRecording().toImage(
          newWidth,
          newHeight,
        );
        final pngBytes = await trimmedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        image.dispose();
        trimmedImage.dispose();
        if (pngBytes == null) {
          return originalBytes;
        }
        return pngBytes.buffer.asUint8List();
      } catch (_) {
        return originalBytes;
      }
    });
  }
}
