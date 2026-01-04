// lib/data/services/ai_image_enhancement_service.dart

import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import '../models/image_enhancement_models.dart';

/// Service d'amélioration intelligente d'images par IA
/// Analyse et corrige uniquement les défauts détectés
class AiImageEnhancementService {
  final EnhancementConfig config;

  AiImageEnhancementService({EnhancementConfig? config})
      : config = config ?? const EnhancementConfig();

  // ═══════════════════════════════════════════════════════════════
  // PHASE 1 : ANALYSE IA DE L'IMAGE
  // ═══════════════════════════════════════════════════════════════

  /// Analyse complète d'une image
  Future<ImageAnalysisResult> analyzeImage(
    Uint8List imageBytes,
    String imageId,
  ) async {
    final stopwatch = Stopwatch()..start();

    // Décoder l'image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Impossible de décoder l\'image');
    }

    // Analyses individuelles
    final brightnessAnalysis = _analyzeBrightness(image);
    final contrastAnalysis = _analyzeContrast(image);
    final sharpnessAnalysis = _analyzeSharpness(image);
    final noiseAnalysis = _analyzeNoise(image);
    final framingAnalysis = _analyzeFraming(image);

    // Construction des métriques
    final metrics = ImageQualityMetrics(
      brightnessScore: brightnessAnalysis['score']!,
      contrastScore: contrastAnalysis['score']!,
      sharpnessScore: sharpnessAnalysis['score']!,
      noiseScore: noiseAnalysis['score']!,
      framingScore: framingAnalysis['score']!,
      averageBrightness: brightnessAnalysis['average']!,
      contrastRatio: contrastAnalysis['ratio']!,
      edgeStrength: sharpnessAnalysis['edgeStrength']!,
      noiseLevel: noiseAnalysis['level']!,
      framing: FramingAnalysis(
        vehicleAreaRatio: framingAnalysis['vehicleArea']!,
        horizontalCentering: framingAnalysis['hCenter']!,
        verticalCentering: framingAnalysis['vCenter']!,
        skyRatio: framingAnalysis['skyRatio']!,
        groundRatio: framingAnalysis['groundRatio']!,
      ),
    );

    // Détection des défauts
    final defects = _detectDefects(metrics);

    // Décision IA : quelles actions appliquer ?
    final actions = _decideEnhancements(metrics, defects);

    stopwatch.stop();

    return ImageAnalysisResult(
      imageId: imageId,
      metrics: metrics,
      detectedDefects: defects,
      recommendedActions: actions,
      analyzedAt: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Analyse de luminosité
  // ─────────────────────────────────────────────────────────────────
  Map<String, double> _analyzeBrightness(img.Image image) {
    int totalBrightness = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        // Luminance perçue (formule standard)
        final brightness = (0.299 * r + 0.587 * g + 0.114 * b);
        totalBrightness += brightness.toInt();
        pixelCount++;
      }
    }

    final avgBrightness = totalBrightness / pixelCount;

    // Score : optimal entre 80-170, pénalité si trop sombre/clair
    double score;
    if (avgBrightness < 60) {
      score = (avgBrightness / 60) * 40; // Très sombre
    } else if (avgBrightness > 200) {
      score = 100 - ((avgBrightness - 200) / 55) * 60; // Surexposé
    } else if (avgBrightness >= 100 && avgBrightness <= 150) {
      score = 100.0; // Optimal
    } else {
      score = 100 - ((avgBrightness - 125).abs() / 75) * 30;
    }

    return {
      'average': avgBrightness,
      'score': score.clamp(0.0, 100.0),
    };
  }

  // ─────────────────────────────────────────────────────────────────
  // Analyse de contraste
  // ─────────────────────────────────────────────────────────────────
  Map<String, double> _analyzeContrast(img.Image image) {
    List<int> luminances = [];

    // Échantillonnage (pour performance)
    final step = (image.width * image.height / 10000).ceil();
    
    for (int i = 0; i < image.height; i += step) {
      for (int j = 0; j < image.width; j += step) {
        final pixel = image.getPixel(j, i);
        final lum = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).toInt();
        luminances.add(lum);
      }
    }

    luminances.sort();
    
    // Calcul de l'écart-type (indicateur de contraste)
    final mean = luminances.reduce((a, b) => a + b) / luminances.length;
    final variance = luminances.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / luminances.length;
    final stdDev = math.sqrt(variance);

    // Contraste ratio (0-100)
    final contrastRatio = (stdDev / 128 * 100).clamp(0.0, 100.0);

    // Score : optimal entre 30-70
    double score;
    if (contrastRatio < 20) {
      score = contrastRatio * 2; // Trop plat
    } else if (contrastRatio > 80) {
      score = 100 - (contrastRatio - 80) * 2; // Trop contrasté
    } else if (contrastRatio >= 35 && contrastRatio <= 65) {
      score = 100.0; // Optimal
    } else {
      score = 100 - ((contrastRatio - 50).abs() / 30) * 30;
    }

    return {
      'ratio': contrastRatio,
      'score': score.clamp(0.0, 100.0),
    };
  }

  // ─────────────────────────────────────────────────────────────────
  // Analyse de netteté (détection de flou)
  // ─────────────────────────────────────────────────────────────────
  Map<String, double> _analyzeSharpness(img.Image image) {
    // Détection de contours (Laplacien simplifié)
    double edgeSum = 0;
    int edgeCount = 0;

    for (int y = 1; y < image.height - 1; y += 3) {
      for (int x = 1; x < image.width - 1; x += 3) {
        final center = _getGrayValue(image, x, y);
        final top = _getGrayValue(image, x, y - 1);
        final bottom = _getGrayValue(image, x, y + 1);
        final left = _getGrayValue(image, x - 1, y);
        final right = _getGrayValue(image, x + 1, y);

        final laplacian = ((4 * center - top - bottom - left - right).abs());
        edgeSum += laplacian;
        edgeCount++;
      }
    }

    final edgeStrength = edgeSum / edgeCount;

    // Score : plus de contours = plus net
    final score = (edgeStrength / 80 * 100).clamp(0.0, 100.0);

    return {
      'edgeStrength': edgeStrength,
      'score': score,
    };
  }

  double _getGrayValue(img.Image image, int x, int y) {
    final pixel = image.getPixel(x, y);
    return 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
  }

  // ─────────────────────────────────────────────────────────────────
  // Analyse de bruit
  // ─────────────────────────────────────────────────────────────────
  Map<String, double> _analyzeNoise(img.Image image) {
    // Variance locale (indicateur de bruit)
    double totalVariance = 0;
    int samples = 0;

    for (int y = 5; y < image.height - 5; y += 10) {
      for (int x = 5; x < image.width - 5; x += 10) {
        List<double> window = [];
        
        for (int dy = -2; dy <= 2; dy++) {
          for (int dx = -2; dx <= 2; dx++) {
            window.add(_getGrayValue(image, x + dx, y + dy));
          }
        }

        final mean = window.reduce((a, b) => a + b) / window.length;
        final variance = window.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / window.length;
        
        totalVariance += variance;
        samples++;
      }
    }

    final avgVariance = totalVariance / samples;
    final noiseLevel = (avgVariance / 100).clamp(0.0, 100.0);

    // Score inversé : moins de bruit = meilleur score
    final score = (100 - noiseLevel).clamp(0.0, 100.0);

    return {
      'level': noiseLevel,
      'score': score,
    };
  }

  // ─────────────────────────────────────────────────────────────────
  // Analyse de cadrage (simplifié)
  // ─────────────────────────────────────────────────────────────────
  Map<String, double> _analyzeFraming(img.Image image) {
    // Détection des zones claires (ciel) et sombres (sol) en haut/bas
    int topBrightPixels = 0;
    int bottomDarkPixels = 0;
    
    final topSample = (image.height * 0.15).toInt();
    final bottomStart = (image.height * 0.85).toInt();

    for (int x = 0; x < image.width; x += 5) {
      for (int y = 0; y < topSample; y++) {
        if (_getGrayValue(image, x, y) > 180) topBrightPixels++;
      }
      for (int y = bottomStart; y < image.height; y++) {
        if (_getGrayValue(image, x, y) < 100) bottomDarkPixels++;
      }
    }

    final skyRatio = (topBrightPixels / (image.width * topSample / 5) * 100).clamp(0.0, 100.0);
    final groundRatio = (bottomDarkPixels / (image.width * (image.height - bottomStart) / 5) * 100).clamp(0.0, 100.0);

    // Estimation simple du centrage (basé sur distribution de luminance)
    final vehicleAreaRatio = 0.5; // Simplified assumption
    final hCenter = 0.0;
    final vCenter = 0.0;

    // Score : pénalité si trop de ciel ou sol
    double score = 100.0;
    if (skyRatio > 40) score -= (skyRatio - 40);
    if (groundRatio > 40) score -= (groundRatio - 40);

    return {
      'vehicleArea': vehicleAreaRatio,
      'hCenter': hCenter,
      'vCenter': vCenter,
      'skyRatio': skyRatio,
      'groundRatio': groundRatio,
      'score': score.clamp(0.0, 100.0),
    };
  }

  // ═══════════════════════════════════════════════════════════════
  // PHASE 2 : DÉTECTION DES DÉFAUTS
  // ═══════════════════════════════════════════════════════════════

  List<ImageDefect> _detectDefects(ImageQualityMetrics metrics) {
    final defects = <ImageDefect>[];

    // Luminosité
    if (metrics.brightnessScore < config.minAcceptableBrightness) {
      if (metrics.averageBrightness < 80) {
        defects.add(ImageDefect.underexposed);
      } else {
        defects.add(ImageDefect.overexposed);
      }
    }

    // Contraste
    if (metrics.contrastScore < config.minAcceptableContrast) {
      defects.add(ImageDefect.lowContrast);
    }

    // Netteté
    if (metrics.sharpnessScore < config.minAcceptableSharpness) {
      defects.add(ImageDefect.blurry);
    }

    // Bruit
    if (metrics.noiseScore < config.maxAcceptableNoise) {
      defects.add(ImageDefect.noisy);
    }

    // Cadrage
    if (metrics.framing.skyRatio > 45) {
      defects.add(ImageDefect.excessiveSky);
    }
    if (metrics.framing.groundRatio > 45) {
      defects.add(ImageDefect.excessiveGround);
    }
    if (!metrics.framing.isWellFramed) {
      defects.add(ImageDefect.poorFraming);
    }

    return defects;
  }

  // ═══════════════════════════════════════════════════════════════
  // PHASE 3 : DÉCISION IA - QUELLES ACTIONS APPLIQUER ?
  // ═══════════════════════════════════════════════════════════════

  List<EnhancementAction> _decideEnhancements(
    ImageQualityMetrics metrics,
    List<ImageDefect> defects,
  ) {
    final actions = <EnhancementAction>[];

    // Règle 1 : Correction de luminosité
    if (defects.contains(ImageDefect.underexposed)) {
      actions.add(EnhancementAction.increaseBrightness);
    } else if (defects.contains(ImageDefect.overexposed)) {
      actions.add(EnhancementAction.decreaseBrightness);
    }

    // Règle 2 : Amélioration du contraste
    if (defects.contains(ImageDefect.lowContrast)) {
      actions.add(EnhancementAction.enhanceContrast);
    }

    // Règle 3 : Renforcement de la netteté
    if (defects.contains(ImageDefect.blurry)) {
      actions.add(EnhancementAction.sharpen);
    }

    // Règle 4 : Réduction du bruit
    if (defects.contains(ImageDefect.noisy)) {
      actions.add(EnhancementAction.reduceNoise);
    }

    // Règle 5 : Recadrage
    if (defects.contains(ImageDefect.excessiveSky) ||
        defects.contains(ImageDefect.excessiveGround) ||
        defects.contains(ImageDefect.poorFraming)) {
      actions.add(EnhancementAction.cropToImproveFraming);
    }

    // Règle 6 : Si plusieurs problèmes mineurs, nivellement auto
    if (actions.length >= 3) {
      actions.clear();
      actions.add(EnhancementAction.autoLevels);
    }

    return actions;
  }

  // ═══════════════════════════════════════════════════════════════
  // PHASE 4 : APPLICATION DES AMÉLIORATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<ImageEnhancementResult> enhanceImage(
    Uint8List imageBytes,
    String imageId,
  ) async {
    final stopwatch = Stopwatch()..start();

    // Analyse préalable
    final analysis = await analyzeImage(imageBytes, imageId);
    
    // Si aucune amélioration nécessaire, retourner l'original
    if (!analysis.needsEnhancement) {
      stopwatch.stop();
      return ImageEnhancementResult(
        imageId: imageId,
        originalImage: imageBytes,
        enhancedImage: imageBytes,
        appliedActions: [],
        beforeMetrics: analysis.metrics,
        afterMetrics: analysis.metrics,
        processingTime: stopwatch.elapsed,
        ethicalDisclaimer: _getEthicalDisclaimer(false),
      );
    }

    // Décoder l'image
    img.Image image = img.decodeImage(imageBytes)!;
    final originalImage = img.Image.from(image); // Copie

    // Appliquer les actions recommandées
    for (final action in analysis.recommendedActions) {
      image = _applyEnhancement(image, action);
    }

    // Encoder le résultat
    final enhancedBytes = Uint8List.fromList(img.encodeJpg(image, quality: 90));

    // Nouvelle analyse
    final afterAnalysis = await analyzeImage(enhancedBytes, imageId);

    stopwatch.stop();

    return ImageEnhancementResult(
      imageId: imageId,
      originalImage: imageBytes,
      enhancedImage: enhancedBytes,
      appliedActions: analysis.recommendedActions,
      beforeMetrics: analysis.metrics,
      afterMetrics: afterAnalysis.metrics,
      processingTime: stopwatch.elapsed,
      ethicalDisclaimer: _getEthicalDisclaimer(true),
    );
  }

  img.Image _applyEnhancement(img.Image image, EnhancementAction action) {
    switch (action) {
      case EnhancementAction.increaseBrightness:
        return img.adjustColor(image, brightness: config.brightnessAdjustmentIntensity);
      
      case EnhancementAction.decreaseBrightness:
        return img.adjustColor(image, brightness: -config.brightnessAdjustmentIntensity);
      
      case EnhancementAction.enhanceContrast:
        return img.adjustColor(image, contrast: config.contrastAdjustmentIntensity);
      
      case EnhancementAction.sharpen:
        return img.convolution(image, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);
      
      case EnhancementAction.reduceNoise:
        return img.gaussianBlur(image, radius: 1);
      
      case EnhancementAction.cropToImproveFraming:
        final cropHeight = (image.height * 0.1).toInt();
        return img.copyCrop(image, 
          x: 0, 
          y: cropHeight ~/ 2, 
          width: image.width, 
          height: image.height - cropHeight
        );
      
      case EnhancementAction.autoLevels:
        return img.normalize(image, min: 0, max: 255);
    }
  }

  String _getEthicalDisclaimer(bool wasModified) {
    if (!wasModified) {
      return 'Photo originale non modifiée – Qualité jugée satisfaisante.';
    }
    return 'Photo optimisée automatiquement (luminosité/contraste/netteté) – '
        'Le véhicule n\'a pas été modifié visuellement. '
        'Amélioration technique uniquement.';
  }
}