// lib/data/models/damage_report_models.dart

import 'package:flutter/foundation.dart';

/// Represents the zone/location of damage on the vehicle
enum DamageZone {
  front('Avant', 1.2), // Higher weight - affects safety/value more
  rear('Arrière', 1.0),
  leftSide('Côté gauche', 1.1),
  rightSide('Côté droit', 1.1),
  roof('Toit', 0.9),
  hood('Capot', 1.15),
  trunk('Coffre', 0.95),
  interior('Intérieur', 1.0),
  undercarriage('Soubassement', 1.3), // Critical for structural integrity
  windshield('Pare-brise', 1.1),
  lights('Phares', 0.8),
  bumper('Pare-chocs', 0.7);

  const DamageZone(this.label, this.impactWeight);
  final String label;
  final double impactWeight; // AI weight factor for value calculation
}

/// Type of damage observed
enum DamageType {
  scratch('Rayure', 0.3),
  dent('Bosse', 0.6),
  paintDamage('Dommage peinture', 0.5),
  crack('Fissure', 0.8),
  rust('Rouille', 0.9),
  brokenPart('Pièce cassée', 1.0),
  mechanicalIssue('Problème mécanique', 1.2),
  waterDamage('Dégât des eaux', 1.1),
  electricalIssue('Problème électrique', 1.0),
  structuralDamage('Dommage structurel', 1.5);

  const DamageType(this.label, this.severityMultiplier);
  final String label;
  final double severityMultiplier;
}

/// Severity level with AI scoring
enum DamageSeverity {
  light('Léger', 1.0, 'Problème esthétique mineur'),
  medium('Moyen', 2.5, 'Dommage visible nécessitant attention'),
  severe('Sévère', 5.0, 'Dommage important affectant la fonctionnalité');

  const DamageSeverity(this.label, this.scoreWeight, this.description);
  final String label;
  final double scoreWeight;
  final String description;
}

/// Individual damage entry with all metadata
@immutable
class DamageEntry {
  final String id;
  final DamageZone zone;
  final DamageType type;
  final DamageSeverity severity;
  final bool isRepaired;
  final String? repairDetails;
  final DateTime reportedAt;

  const DamageEntry({
    required this.id,
    required this.zone,
    required this.type,
    required this.severity,
    required this.isRepaired,
    this.repairDetails,
    required this.reportedAt,
  });

  /// Calculate individual damage impact score (0-100)
  double get impactScore {
    final baseScore = severity.scoreWeight * 
                     type.severityMultiplier * 
                     zone.impactWeight * 10;
    
    // Reduce score if repaired (repair quality assumption: 70% restoration)
    return isRepaired ? baseScore * 0.3 : baseScore;
  }

  DamageEntry copyWith({
    String? id,
    DamageZone? zone,
    DamageType? type,
    DamageSeverity? severity,
    bool? isRepaired,
    String? repairDetails,
    DateTime? reportedAt,
  }) {
    return DamageEntry(
      id: id ?? this.id,
      zone: zone ?? this.zone,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      isRepaired: isRepaired ?? this.isRepaired,
      repairDetails: repairDetails ?? this.repairDetails,
      reportedAt: reportedAt ?? this.reportedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zone': zone.name,
      'type': type.name,
      'severity': severity.name,
      'isRepaired': isRepaired,
      'repairDetails': repairDetails,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }

  factory DamageEntry.fromJson(Map<String, dynamic> json) {
    return DamageEntry(
      id: json['id'] as String,
      zone: DamageZone.values.firstWhere((e) => e.name == json['zone']),
      type: DamageType.values.firstWhere((e) => e.name == json['type']),
      severity: DamageSeverity.values.firstWhere((e) => e.name == json['severity']),
      isRepaired: json['isRepaired'] as bool,
      repairDetails: json['repairDetails'] as String?,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
    );
  }
}

/// Complete AI-generated damage report
@immutable
class AiDamageReport {
  final List<DamageEntry> damages;
  final bool hasAccidentHistory;
  final DateTime generatedAt;
  
  // AI-computed metrics
  final double overallConditionScore; // 0-100 (100 = perfect)
  final double transparencyIndex; // 0-100 (seller honesty indicator)
  final double estimatedValueImpact; // Percentage reduction (0-100%)
  final String conditionGrade; // A+ to F
  final String riskLevel; // Low, Medium, High, Critical
  
  // Generated content
  final String executiveSummary;
  final List<String> detailedFindings;
  final List<String> recommendations;
  final String legalDisclaimer;

  const AiDamageReport({
    required this.damages,
    required this.hasAccidentHistory,
    required this.generatedAt,
    required this.overallConditionScore,
    required this.transparencyIndex,
    required this.estimatedValueImpact,
    required this.conditionGrade,
    required this.riskLevel,
    required this.executiveSummary,
    required this.detailedFindings,
    required this.recommendations,
    required this.legalDisclaimer,
  });

  Map<String, dynamic> toJson() {
    return {
      'damages': damages.map((d) => d.toJson()).toList(),
      'hasAccidentHistory': hasAccidentHistory,
      'generatedAt': generatedAt.toIso8601String(),
      'overallConditionScore': overallConditionScore,
      'transparencyIndex': transparencyIndex,
      'estimatedValueImpact': estimatedValueImpact,
      'conditionGrade': conditionGrade,
      'riskLevel': riskLevel,
      'executiveSummary': executiveSummary,
      'detailedFindings': detailedFindings,
      'recommendations': recommendations,
      'legalDisclaimer': legalDisclaimer,
    };
  }

  factory AiDamageReport.fromJson(Map<String, dynamic> json) {
    return AiDamageReport(
      damages: (json['damages'] as List)
          .map((d) => DamageEntry.fromJson(d as Map<String, dynamic>))
          .toList(),
      hasAccidentHistory: json['hasAccidentHistory'] as bool,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      overallConditionScore: (json['overallConditionScore'] as num).toDouble(),
      transparencyIndex: (json['transparencyIndex'] as num).toDouble(),
      estimatedValueImpact: (json['estimatedValueImpact'] as num).toDouble(),
      conditionGrade: json['conditionGrade'] as String,
      riskLevel: json['riskLevel'] as String,
      executiveSummary: json['executiveSummary'] as String,
      detailedFindings: List<String>.from(json['detailedFindings'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      legalDisclaimer: json['legalDisclaimer'] as String,
    );
  }
}