// lib/data/services/ai_damage_report_service.dart

import 'dart:math' as math;
import '../models/damage_report_models.dart';

/// Service de génération de rapport de dommages IA
/// Objectif : transparence informative, ton neutre et professionnel
class AiDamageReportService {
  
  /// Méthode principale de génération du rapport IA
  AiDamageReport generateReport({
    required List<DamageEntry> damages,
    required bool hasAccidentHistory,
  }) {
    // Cas particulier : véhicule en excellent état
    if (damages.isEmpty && !hasAccidentHistory) {
      return _generatePerfectConditionReport();
    }

    // Phase 1 : Calcul des métriques objectives
    final scores = _computeAiScores(damages, hasAccidentHistory);
    
    // Phase 2 : Génération du contenu textuel neutre
    final summary = _generateTechnicalSummary(damages, hasAccidentHistory, scores);
    final findings = _generateDetailedFindings(damages, hasAccidentHistory);
    
    return AiDamageReport(
      damages: damages,
      hasAccidentHistory: hasAccidentHistory,
      generatedAt: DateTime.now(),
      overallConditionScore: scores['conditionScore']!,
      transparencyIndex: scores['transparencyIndex']!,
      estimatedValueImpact: scores['valueImpact']!,
      conditionGrade: _calculateGrade(scores['conditionScore']!),
      riskLevel: _assessRiskLevel(damages, hasAccidentHistory, scores),
      executiveSummary: summary,
      detailedFindings: findings,
      recommendations: [], // ✅ Pas de recommandations
      legalDisclaimer: _generateLegalDisclaimer(),
    );
  }

  /// Rapport pour véhicule sans dommage déclaré
  AiDamageReport _generatePerfectConditionReport() {
    return AiDamageReport(
      damages: [],
      hasAccidentHistory: false,
      generatedAt: DateTime.now(),
      overallConditionScore: 100.0,
      transparencyIndex: 100.0,
      estimatedValueImpact: 0.0,
      conditionGrade: 'A+',
      riskLevel: 'Très faible',
      executiveSummary: 'Aucun dommage n\'a été déclaré pour ce véhicule. '
          'L\'historique d\'accident est également négatif. '
          'Les informations fournies indiquent un état général excellent.',
      detailedFindings: [
        'Aucun dommage structurel déclaré',
        'Aucun dommage esthétique déclaré',
        'Aucun historique d\'accident signalé',
        'État général : excellent selon déclaration',
      ],
      recommendations: [],
      legalDisclaimer: _generateLegalDisclaimer(),
    );
  }

  /// Algorithme de scoring multi-critères
  Map<String, double> _computeAiScores(
    List<DamageEntry> damages,
    bool hasAccidentHistory,
  ) {
    // 1. Score d'impact brut des dommages
    double totalDamageScore = damages.fold(0.0, (sum, d) => sum + d.impactScore);
    
    // 2. Pénalité pour historique d'accident (facteur de risque objectif)
    if (hasAccidentHistory) {
      totalDamageScore += 50.0;
    }
    
    // 3. Normalisation 0-100
    final normalizedDamage = math.min(100.0, totalDamageScore);
    
    // 4. Score de condition (inversé : 100 = parfait)
    final conditionScore = math.max(0.0, 100.0 - normalizedDamage);
    
    // 5. Indice de transparence (cohérence de la déclaration)
    final transparencyIndex = _calculateTransparencyIndex(damages, hasAccidentHistory);
    
    // 6. Impact estimé sur la valeur (modèle de dépréciation)
    final k = 0.02;
    final valueImpact = (1 - math.exp(-k * normalizedDamage)) * 100;
    
    return {
      'conditionScore': conditionScore,
      'transparencyIndex': transparencyIndex,
      'valueImpact': math.min(100.0, valueImpact),
    };
  }

  /// Indice de transparence (cohérence et exhaustivité de la déclaration)
  double _calculateTransparencyIndex(
    List<DamageEntry> damages,
    bool hasAccidentHistory,
  ) {
    if (damages.isEmpty) {
      return hasAccidentHistory ? 50.0 : 100.0;
    }

    double transparency = 70.0;
    
    // Bonus pour déclaration de dommages mineurs (signe d'honnêteté)
    final lightDamages = damages.where((d) => d.severity == DamageSeverity.light).length;
    transparency += math.min(20.0, lightDamages * 5.0);
    
    // Bonus pour mention des réparations effectuées
    final repairedCount = damages.where((d) => d.isRepaired).length;
    transparency += math.min(10.0, repairedCount * 3.0);
    
    // Détection de pattern suspect (uniquement dommages graves = sélectivité)
    final severeDamages = damages.where((d) => d.severity == DamageSeverity.severe).length;
    if (severeDamages == damages.length && damages.length < 3) {
      transparency -= 15.0;
    }
    
    return math.max(0.0, math.min(100.0, transparency));
  }

  /// Attribution de note académique
  String _calculateGrade(double score) {
    if (score >= 95) return 'A+';
    if (score >= 90) return 'A';
    if (score >= 85) return 'A-';
    if (score >= 80) return 'B+';
    if (score >= 75) return 'B';
    if (score >= 70) return 'B-';
    if (score >= 65) return 'C+';
    if (score >= 60) return 'C';
    if (score >= 55) return 'C-';
    if (score >= 50) return 'D';
    return 'F';
  }

  /// Évaluation du niveau de risque (classification objective)
  String _assessRiskLevel(
    List<DamageEntry> damages,
    bool hasAccidentHistory,
    Map<String, double> scores,
  ) {
    final conditionScore = scores['conditionScore']!;
    final hasStructuralDamage = damages.any((d) => 
      d.type == DamageType.structuralDamage || 
      d.zone == DamageZone.undercarriage
    );
    final hasUnrepairedSevere = damages.any((d) => 
      d.severity == DamageSeverity.severe && !d.isRepaired
    );

    // Classification par règles expertes
    if (hasStructuralDamage || conditionScore < 40) return 'Critique';
    if (hasAccidentHistory && hasUnrepairedSevere) return 'Élevé';
    if (conditionScore < 60 || hasAccidentHistory) return 'Moyen';
    if (conditionScore < 80) return 'Faible';
    return 'Très faible';
  }

  /// Résumé technique neutre et factuel
  String _generateTechnicalSummary(
    List<DamageEntry> damages,
    bool hasAccidentHistory,
    Map<String, double> scores,
  ) {
    final conditionScore = scores['conditionScore']!;
    final valueImpact = scores['valueImpact']!;
    final grade = _calculateGrade(conditionScore);
    
    final damageCount = damages.length;
    final repairedCount = damages.where((d) => d.isRepaired).length;
    final unrepairedCount = damageCount - repairedCount;
    
    String summary = 'Ce véhicule présente un indice de condition de ${conditionScore.toStringAsFixed(1)}/100 '
        '(note : $grade). ';
    
    if (damageCount > 0) {
      summary += '$damageCount dommage${damageCount > 1 ? 's ont été déclarés' : ' a été déclaré'} '
          '($repairedCount réparé${repairedCount > 1 ? 's' : ''}, '
          '$unrepairedCount non réparé${unrepairedCount > 1 ? 's' : ''}). ';
    }
    
    if (hasAccidentHistory) {
      summary += 'Un historique d\'accident a été signalé. ';
    }
    
    summary += 'L\'impact estimé sur la valeur de référence est de ${valueImpact.toStringAsFixed(1)} %. ';
    
    if (scores['transparencyIndex']! > 80) {
      summary += 'Le niveau de détail des informations fournies est élevé.';
    } else if (scores['transparencyIndex']! < 50) {
      summary += 'Les informations déclarées présentent un niveau de détail limité.';
    } else {
      summary += 'Les informations déclarées sont conformes aux standards de divulgation.';
    }
    
    return summary;
  }

  /// Liste détaillée des dommages (format neutre)
  List<String> _generateDetailedFindings(
    List<DamageEntry> damages,
    bool hasAccidentHistory,
  ) {
    final findings = <String>[];
    
    // Catégorisation par gravité
    final severe = damages.where((d) => d.severity == DamageSeverity.severe).toList();
    final medium = damages.where((d) => d.severity == DamageSeverity.medium).toList();
    final light = damages.where((d) => d.severity == DamageSeverity.light).toList();
    
    // Mention de l'historique d'accident (factuel)
    if (hasAccidentHistory) {
      findings.add('HISTORIQUE : Accident déclaré par le vendeur');
    }
    
    // Dommages graves
    if (severe.isNotEmpty) {
      findings.add('DOMMAGES SÉVÈRES (${severe.length}) :');
      for (var d in severe) {
        final status = d.isRepaired ? 'Réparé' : 'Non réparé';
        findings.add('   • ${d.zone.label} – ${d.type.label} [$status]');
      }
    }
    
    // Dommages moyens
    if (medium.isNotEmpty) {
      findings.add('DOMMAGES MODÉRÉS (${medium.length}) :');
      for (var d in medium) {
        final status = d.isRepaired ? 'Réparé' : 'Non réparé';
        findings.add('   • ${d.zone.label} – ${d.type.label} [$status]');
      }
    }
    
    // Dommages légers
    if (light.isNotEmpty) {
      findings.add('DOMMAGES MINEURS (${light.length}) :');
      for (var d in light.take(5)) {
        findings.add('   • ${d.zone.label} – ${d.type.label}');
      }
      if (light.length > 5) {
        findings.add('   • ... et ${light.length - 5} autre${light.length - 5 > 1 ? 's' : ''} dommage${light.length - 5 > 1 ? 's' : ''} mineur${light.length - 5 > 1 ? 's' : ''}');
      }
    }
    
    return findings;
  }

  /// Disclaimer légal (conformité et neutralité)
  String _generateLegalDisclaimer() {
    return 'Ce rapport est généré automatiquement à partir des informations déclarées par le vendeur. '
        'Il vise à fournir une synthèse informative de l\'état du véhicule et ne constitue ni une expertise mécanique, '
        'ni une évaluation professionnelle, ni un audit technique. Les acheteurs sont invités à effectuer leur propre '
        'vérification avant toute transaction. OccazCar ne garantit pas l\'exactitude des données déclarées et décline '
        'toute responsabilité quant aux conclusions de ce rapport automatisé.';
  }

  /// Formatage du rapport en texte professionnel (export PDF)
  String formatReportAsText(AiDamageReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('           RAPPORT DE SYNTHÈSE – ÉTAT DU VÉHICULE');
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('Date de génération : ${_formatDate(report.generatedAt)}');
    buffer.writeln('');
    buffer.writeln('─────────────────────────────────────────────────────────────');
    buffer.writeln('ÉVALUATION GLOBALE');
    buffer.writeln('─────────────────────────────────────────────────────────────');
    buffer.writeln('  Indice de fiabilité   : ${report.conditionGrade} (${report.overallConditionScore.toStringAsFixed(1)}/100)');
    buffer.writeln('  Niveau de risque      : ${report.riskLevel}');
    buffer.writeln('  Impact sur la valeur  : ${report.estimatedValueImpact.toStringAsFixed(1)} %');
    buffer.writeln('  Historique d\'accident : ${report.hasAccidentHistory ? 'Déclaré' : 'Non déclaré'}');
    buffer.writeln('  Indice de transparence: ${report.transparencyIndex.toStringAsFixed(0)}/100');
    buffer.writeln('');
    buffer.writeln('─────────────────────────────────────────────────────────────');
    buffer.writeln('RÉSUMÉ TECHNIQUE');
    buffer.writeln('─────────────────────────────────────────────────────────────');
    buffer.writeln(report.executiveSummary);
    buffer.writeln('');
    buffer.writeln('─────────────────────────────────────────────────────────────');
    buffer.writeln('DÉTAILS DES DOMMAGES DÉCLARÉS');
    buffer.writeln('─────────────────────────────────────────────────────────────');
    for (var finding in report.detailedFindings) {
      buffer.writeln(finding);
    }
    buffer.writeln('');
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('DISCLAIMER');
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln(report.legalDisclaimer);
    buffer.writeln('═══════════════════════════════════════════════════════════');
    
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}