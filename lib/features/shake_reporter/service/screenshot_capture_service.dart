import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ScreenshotCaptureService {
  static final GlobalKey boundaryKey = GlobalKey();
  static const int _maxUploadBytes = 70 * 1024;

  String? _latestCaptureBase64;

  String? consumeLatestCapture() {
    final capture = _latestCaptureBase64;
    _latestCaptureBase64 = null;
    return capture;
  }

  Future<String?> captureFromBoundary() async {
    // Ensure the current frame is painted before reading the boundary.
    await WidgetsBinding.instance.endOfFrame;

    final renderObject = boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;

    if (renderObject.debugNeedsPaint) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await WidgetsBinding.instance.endOfFrame;
    }

    final double devicePixelRatio =
        ui.PlatformDispatcher.instance.views.isNotEmpty
        ? ui.PlatformDispatcher.instance.views.first.devicePixelRatio
        : 1.0;
    final double pixelRatio = min(devicePixelRatio, 1.5);

    final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) return null;

    final Uint8List bytes = byteData.buffer.asUint8List();
    if (bytes.isEmpty) return null;

    final compressedBytes = await _compressForUpload(
      bytes,
      width: image.width,
      height: image.height,
    );
    if (compressedBytes.isEmpty) return null;

    final capture = base64Encode(compressedBytes);
    _latestCaptureBase64 = capture;
    return capture;
  }

  Future<Uint8List> _compressForUpload(
    Uint8List source, {
    required int width,
    required int height,
  }) async {
    if (source.lengthInBytes <= _maxUploadBytes) {
      return source;
    }

    Uint8List best = source;
    const edgeSteps = [1080, 900, 768, 640];
    const qualitySteps = [85, 70, 55, 40, 28, 22, 16];

    for (final maxEdge in edgeSteps) {
      final (targetWidth, targetHeight) = _calculateTargetDimensions(
        width: width,
        height: height,
        maxEdge: maxEdge,
      );
      for (final quality in qualitySteps) {
        try {
          final compressed = await FlutterImageCompress.compressWithList(
            source,
            format: CompressFormat.jpeg,
            quality: quality,
            minWidth: targetWidth,
            minHeight: targetHeight,
          );
          if (compressed.isNotEmpty &&
              compressed.lengthInBytes < best.lengthInBytes) {
            best = compressed;
          }
          if (best.lengthInBytes <= _maxUploadBytes) {
            return best;
          }
        } catch (_) {
          // Try the next compression settings.
        }
      }
    }

    return best;
  }

  (int, int) _calculateTargetDimensions({
    required int width,
    required int height,
    required int maxEdge,
  }) {
    if (width <= maxEdge && height <= maxEdge) {
      return (max(width, 1), max(height, 1));
    }

    if (width >= height) {
      final scaledHeight = (height * maxEdge / width).round();
      return (maxEdge, max(scaledHeight, 1));
    }

    final scaledWidth = (width * maxEdge / height).round();
    return (max(scaledWidth, 1), maxEdge);
  }
}
