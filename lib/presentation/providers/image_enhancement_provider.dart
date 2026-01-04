import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/image_enhancement_models.dart';
import '../../data/services/ai_image_enhancement_service.dart';

/// Provider du service d'amélioration d'images
final aiImageEnhancementServiceProvider =
    Provider<AiImageEnhancementService>((ref) {
  return AiImageEnhancementService();
});

/// État de traitement d'un batch d'images
class ImageEnhancementState {
  final List<ImageEnhancementResult> results;
  final bool isProcessing;
  final int totalImages;
  final int processedImages;
  final String? error;

  const ImageEnhancementState({
    this.results = const [],
    this.isProcessing = false,
    this.totalImages = 0,
    this.processedImages = 0,
    this.error,
  });

  ImageEnhancementState copyWith({
    List<ImageEnhancementResult>? results,
    bool? isProcessing,
    int? totalImages,
    int? processedImages,
    String? error,
  }) {
    return ImageEnhancementState(
      results: results ?? this.results,
      isProcessing: isProcessing ?? this.isProcessing,
      totalImages: totalImages ?? this.totalImages,
      processedImages: processedImages ?? this.processedImages,
      error: error,
    );
  }

  double get progress =>
      totalImages > 0 ? processedImages / totalImages : 0.0;
}

/// Notifier pour gérer le traitement IA
class ImageEnhancementNotifier
    extends StateNotifier<ImageEnhancementState> {
  ImageEnhancementNotifier(this._service)
      : super(const ImageEnhancementState());

  final AiImageEnhancementService _service;

  /// Traiter un batch d'images
  Future<void> processImages(List<Uint8List> images) async {
    if (images.isEmpty) {
      state = const ImageEnhancementState();
      return;
    }

    state = ImageEnhancementState(
      isProcessing: true,
      totalImages: images.length,
      processedImages: 0,
      results: const [],
    );

    final results = <ImageEnhancementResult>[];

    try {
      for (int i = 0; i < images.length; i++) {
        final imageId = 'image_$i';

        final result =
            await _service.enhanceImage(images[i], imageId);

        results.add(result);

        state = state.copyWith(
          results: List.unmodifiable(results),
          processedImages: i + 1,
        );
      }

      state = state.copyWith(isProcessing: false);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Erreur lors du traitement IA : $e',
      );
    }
  }

  /// Traiter une seule image
  Future<ImageEnhancementResult?> processSingleImage(
    Uint8List imageBytes,
  ) async {
    try {
      return await _service.enhanceImage(
        imageBytes,
        'single_image',
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur IA : $e',
      );
      return null;
    }
  }

  /// Analyser une image sans la modifier
  Future<ImageAnalysisResult?> analyzeImage(
    Uint8List imageBytes,
  ) async {
    try {
      return await _service.analyzeImage(
        imageBytes,
        'analysis',
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur d\'analyse IA : $e',
      );
      return null;
    }
  }

  /// Réinitialiser l'état
  void reset() {
    state = const ImageEnhancementState();
  }
}

/// Provider du notifier
final imageEnhancementProvider = StateNotifierProvider<
    ImageEnhancementNotifier, ImageEnhancementState>((ref) {
  final service = ref.watch(aiImageEnhancementServiceProvider);
  return ImageEnhancementNotifier(service);
});

/// Nombre d'images réellement améliorées
final enhancedImagesCountProvider = Provider<int>((ref) {
  final state = ref.watch(imageEnhancementProvider);

  return state.results
      .where((r) => r.appliedActions.isNotEmpty)
      .length;
});

/// Score moyen de qualité après amélioration
final averageQualityScoreProvider = Provider<double>((ref) {
  final state = ref.watch(imageEnhancementProvider);

  if (state.results.isEmpty) return 0.0;

  final scores = state.results.map((r) {
    final metrics = r.afterMetrics;
    return (metrics.brightnessScore +
            metrics.contrastScore +
            metrics.sharpnessScore +
            metrics.noiseScore +
            metrics.framingScore) /
        5;
  }).toList();

  return scores.reduce((a, b) => a + b) / scores.length;
});
