// lib/data/models/image_enhancement_models.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Résultat de l'analyse d'image par l'IA
@immutable
class ImageAnalysisResult {
  final String imageId;
  final ImageQualityMetrics metrics;
  final List<ImageDefect> detectedDefects;
  final List<EnhancementAction> recommendedActions;
  final DateTime analyzedAt;

  const ImageAnalysisResult({
    required this.imageId,
    required this.metrics,
    required this.detectedDefects,
    required this.recommendedActions,
    required this.analyzedAt,
  });

  /// L'image nécessite-t-elle des améliorations ?
  bool get needsEnhancement => recommendedActions.isNotEmpty;

  /// Score de qualité global (0-100)
  double get overallQualityScore => _averageMetrics(metrics);
}

/// Métriques de qualité d'image (scores 0-100, 100 = parfait)
@immutable
class ImageQualityMetrics {
  final double brightnessScore; // 100 = luminosité optimale
  final double contrastScore; // 100 = contraste optimal
  final double sharpnessScore; // 100 = netteté parfaite
  final double noiseScore; // 100 = aucun bruit
  final double framingScore; // 100 = cadrage parfait

  // Valeurs brutes pour décisions
  final double averageBrightness; // 0-255
  final double contrastRatio; // 0-100
  final double edgeStrength; // Indicateur de netteté
  final double noiseLevel; // Niveau de bruit détecté
  final FramingAnalysis framing;

  const ImageQualityMetrics({
    required this.brightnessScore,
    required this.contrastScore,
    required this.sharpnessScore,
    required this.noiseScore,
    required this.framingScore,
    required this.averageBrightness,
    required this.contrastRatio,
    required this.edgeStrength,
    required this.noiseLevel,
    required this.framing,
  });
}

/// Analyse du cadrage de l'image
@immutable
class FramingAnalysis {
  final double vehicleAreaRatio; // % de l'image occupé par le véhicule
  final double horizontalCentering; // -1 (gauche) à 1 (droite), 0 = centré
  final double verticalCentering; // -1 (bas) à 1 (haut), 0 = centré
  final double skyRatio; // % de ciel dans l'image
  final double groundRatio; // % de sol dans l'image

  const FramingAnalysis({
    required this.vehicleAreaRatio,
    required this.horizontalCentering,
    required this.verticalCentering,
    required this.skyRatio,
    required this.groundRatio,
  });

  bool get isWellFramed =>
      vehicleAreaRatio > 0.3 &&
      vehicleAreaRatio < 0.8 &&
      horizontalCentering.abs() < 0.3 &&
      verticalCentering.abs() < 0.3;
}

/// Types de défauts détectés
enum ImageDefect {
  underexposed('Sous-exposition', 'Image trop sombre'),
  overexposed('Surexposition', 'Image trop claire'),
  lowContrast('Contraste faible', 'Détails peu visibles'),
  blurry('Flou', 'Manque de netteté'),
  noisy('Bruit visuel', 'Grain visible'),
  poorFraming('Cadrage inadéquat', 'Véhicule mal centré'),
  excessiveSky('Ciel excessif', 'Trop d\'espace au-dessus'),
  excessiveGround('Sol excessif', 'Trop d\'espace en bas');

  const ImageDefect(this.label, this.description);
  final String label;
  final String description;
}

/// Actions d'amélioration recommandées par l'IA
enum EnhancementAction {
  increaseBrightness('Augmentation luminosité', 0.2),
  decreaseBrightness('Réduction luminosité', 0.15),
  enhanceContrast('Amélioration contraste', 0.25),
  sharpen('Renforcement netteté', 0.3),
  reduceNoise('Réduction bruit', 0.15),
  cropToImproveFraming('Recadrage intelligent', 0.2),
  autoLevels('Équilibrage automatique', 0.25);

  const EnhancementAction(this.label, this.intensity);
  final String label;
  final double intensity; // Intensité par défaut (0-1)
}

/// Résultat d'amélioration d'image
@immutable
class ImageEnhancementResult {
  final String imageId;
  final Uint8List originalImage;
  final Uint8List enhancedImage;
  final List<EnhancementAction> appliedActions;
  final ImageQualityMetrics beforeMetrics;
  final ImageQualityMetrics afterMetrics;
  final Duration processingTime;
  final String ethicalDisclaimer;

  const ImageEnhancementResult({
    required this.imageId,
    required this.originalImage,
    required this.enhancedImage,
    required this.appliedActions,
    required this.beforeMetrics,
    required this.afterMetrics,
    required this.processingTime,
    required this.ethicalDisclaimer,
  });

  /// Amélioration du score de qualité (peut être négatif si la correction n'aide pas)
  double get qualityImprovement =>
      _averageMetrics(afterMetrics) - _averageMetrics(beforeMetrics);
}

/// Configuration du moteur d'amélioration IA
@immutable
class EnhancementConfig {
  // Seuils de détection (0-100)
  final double minAcceptableBrightness;
  final double maxAcceptableBrightness;
  final double minAcceptableContrast;
  final double minAcceptableSharpness;
  final double maxAcceptableNoise;

  // Intensité des corrections (0-1)
  final double brightnessAdjustmentIntensity;
  final double contrastAdjustmentIntensity;
  final double sharpeningIntensity;
  final double noiseReductionIntensity;

  // Cadrage
  final double minVehicleAreaRatio;
  final double maxVehicleAreaRatio;
  final double maxCenteringDeviation;

  const EnhancementConfig({
    this.minAcceptableBrightness = 35.0,
    this.maxAcceptableBrightness = 75.0,
    this.minAcceptableContrast = 40.0,
    this.minAcceptableSharpness = 50.0,
    this.maxAcceptableNoise = 70.0,
    this.brightnessAdjustmentIntensity = 0.3,
    this.contrastAdjustmentIntensity = 0.4,
    this.sharpeningIntensity = 0.5,
    this.noiseReductionIntensity = 0.3,
    this.minVehicleAreaRatio = 0.25,
    this.maxVehicleAreaRatio = 0.85,
    this.maxCenteringDeviation = 0.35,
  });

  /// Configuration conservative (modifications minimales)
  factory EnhancementConfig.conservative() {
    return const EnhancementConfig(
      minAcceptableBrightness: 30.0,
      maxAcceptableBrightness: 80.0,
      brightnessAdjustmentIntensity: 0.2,
      contrastAdjustmentIntensity: 0.3,
      sharpeningIntensity: 0.3,
    );
  }

  /// Configuration agressive (améliorations maximales)
  factory EnhancementConfig.aggressive() {
    return const EnhancementConfig(
      minAcceptableBrightness: 40.0,
      maxAcceptableBrightness: 70.0,
      brightnessAdjustmentIntensity: 0.5,
      contrastAdjustmentIntensity: 0.6,
      sharpeningIntensity: 0.7,
    );
  }
}

/// Helper: moyenne robuste (0-100) des métriques de qualité
double _averageMetrics(ImageQualityMetrics m) {
  final values = <double>[
    m.brightnessScore,
    m.contrastScore,
    m.sharpnessScore,
    m.noiseScore,
    m.framingScore,
  ];

  if (values.isEmpty) return 0.0;
  return values.reduce((a, b) => a + b) / values.length;
}
