// lib/presentation/widgets/ai_image_enhancement_button.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/image_enhancement_models.dart';
import '../providers/image_enhancement_provider.dart';

/// Widget bouton pour améliorer les images avec l'IA
class AiImageEnhancementButton extends ConsumerWidget {
  final List<XFile> images;
  final ValueChanged<List<XFile>> onImagesEnhanced;

  const AiImageEnhancementButton({
    super.key,
    required this.images,
    required this.onImagesEnhanced,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enhancementState = ref.watch(imageEnhancementProvider);
    final enhancedCount = ref.watch(enhancedImagesCountProvider);

    if (images.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_fix_high, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Optimisation IA des photos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (enhancedCount > 0)
                  Chip(
                    label: Text(
                      '$enhancedCount optimisée${enhancedCount > 1 ? 's' : ''}',
                    ),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'L\'IA analyse et corrige uniquement les défauts détectés (luminosité, netteté, cadrage).',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),

            if (enhancementState.isProcessing) ...[
              LinearProgressIndicator(
                value: enhancementState.totalImages > 0 ? enhancementState.progress : null,
              ),
              const SizedBox(height: 8),
              Text(
                'Traitement : ${enhancementState.processedImages}/${enhancementState.totalImages}',
                style: const TextStyle(fontSize: 12),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _analyzeImages(context, ref),
                      icon: const Icon(Icons.analytics, size: 18),
                      label: const Text('Analyser'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _enhanceImages(context, ref),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Optimiser les photos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (enhancementState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                enhancementState.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeImages(BuildContext context, WidgetRef ref) async {
    if (images.isEmpty) return;

    try {
      final service = ref.read(aiImageEnhancementServiceProvider);

      // Analyser la première image comme échantillon
      final imageBytes = await File(images.first.path).readAsBytes();
      final analysis = await service.analyzeImage(imageBytes, 'sample');

      if (!context.mounted) return;
      _showAnalysisDialog(context, analysis);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur analyse IA : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enhanceImages(BuildContext context, WidgetRef ref) async {
    if (images.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Optimisation IA'),
        content: Text(
          'Voulez-vous optimiser ${images.length} photo${images.length > 1 ? 's' : ''} ?\n\n'
          'L\'IA analysera et corrigera automatiquement :\n'
          '• La luminosité\n'
          '• Le contraste\n'
          '• La netteté\n'
          '• Le cadrage\n\n'
          'Le véhicule ne sera pas modifié visuellement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Optimiser'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Lire toutes les images
      final imageBytesList = <Uint8List>[];
      for (final image in images) {
        imageBytesList.add(await File(image.path).readAsBytes());
      }

      // Traiter avec le provider
      final notifier = ref.read(imageEnhancementProvider.notifier);
      await notifier.processImages(imageBytesList);

      final results = ref.read(imageEnhancementProvider).results;
      if (results == null || results.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun résultat généré.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Sauvegarder les images améliorées
      final enhancedImages = <XFile>[];
      final safeLen = results.length < images.length ? results.length : images.length;

      for (int i = 0; i < safeLen; i++) {
        final result = results[i];

        // IMPORTANT : éviter de réécrire sur le même fichier + garantir une extension
        final originalPath = images[i].path;
        final enhancedPath = _buildEnhancedPath(originalPath, suffix: '_enhanced');

        await File(enhancedPath).writeAsBytes(result.enhancedImage);
        enhancedImages.add(XFile(enhancedPath));
      }

      // Callback (remplacer la liste des images côté écran parent)
      onImagesEnhanced(enhancedImages);

      if (!context.mounted) return;
      _showResultDialog(context, results);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur optimisation IA : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAnalysisDialog(BuildContext context, ImageAnalysisResult analysis) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Analyse IA de l\'image'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score de qualité : ${analysis.overallQualityScore.toStringAsFixed(1)}/100',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildMetricRow('Luminosité', analysis.metrics.brightnessScore),
              _buildMetricRow('Contraste', analysis.metrics.contrastScore),
              _buildMetricRow('Netteté', analysis.metrics.sharpnessScore),
              _buildMetricRow('Bruit', analysis.metrics.noiseScore),
              _buildMetricRow('Cadrage', analysis.metrics.framingScore),
              const SizedBox(height: 12),
              if (analysis.detectedDefects.isNotEmpty) ...[
                const Text(
                  'Défauts détectés :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...analysis.detectedDefects.map((d) => Text('• ${d.description}')),
                const SizedBox(height: 12),
              ],
              if (analysis.recommendedActions.isNotEmpty) ...[
                const Text(
                  'Actions recommandées :',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 4),
                ...analysis.recommendedActions.map((a) => Text('✓ ${a.label}')),
              ] else ...[
                const Text(
                  '✓ Aucune amélioration nécessaire',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, double score) {
    var color = Colors.green;
    if (score < 40) color = Colors.red;
    else if (score < 70) color = Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            '${score.toStringAsFixed(0)}/100',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, List<ImageEnhancementResult> results) {
    final improved = results.where((r) => r.appliedActions.isNotEmpty).length;

    final avgImprovement = results.isEmpty
        ? 0.0
        : results.map((r) => r.qualityImprovement).reduce((a, b) => a + b) / results.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Optimisation terminée'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$improved/${results.length} photo${results.length > 1 ? 's' : ''} '
              'optimisée${improved > 1 ? 's' : ''}',
            ),
            const SizedBox(height: 8),
            Text(
              'Amélioration moyenne : +${avgImprovement.toStringAsFixed(1)} points',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (results.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  results.first.ethicalDisclaimer,
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Construit un chemin de fichier "enhanced" sans casser l'extension.
  /// Exemple: C:\img\car.jpg -> C:\img\car_enhanced.jpg
  String _buildEnhancedPath(String originalPath, {required String suffix}) {
    final file = File(originalPath);
    final dir = file.parent.path;

    final name = file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'image.jpg';
    final dot = name.lastIndexOf('.');
    final base = dot > 0 ? name.substring(0, dot) : name;
    final ext = dot > 0 ? name.substring(dot) : '.jpg';

    return '$dir${Platform.pathSeparator}$base$suffix$ext';
  }
}
