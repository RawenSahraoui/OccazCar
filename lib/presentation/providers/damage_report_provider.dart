// lib/presentation/providers/damage_report_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/damage_report_models.dart';
import '../../data/services/ai_damage_report_service.dart';

/// Service provider (singleton)
final aiDamageServiceProvider = Provider<AiDamageReportService>((ref) {
  return AiDamageReportService();
});

/// State notifier for managing damage entries collection
class DamageReportNotifier extends StateNotifier<DamageReportState> {
  DamageReportNotifier(this._service) : super(DamageReportState.initial());

  final AiDamageReportService _service;

  /// Add a new damage entry
  void addDamage(DamageEntry damage) {
    state = state.copyWith(
      damages: [...state.damages, damage],
      generatedReport: null, // Invalidate previous report
    );
  }

  /// Remove damage by ID
  void removeDamage(String damageId) {
    state = state.copyWith(
      damages: state.damages.where((d) => d.id != damageId).toList(),
      generatedReport: null,
    );
  }

  /// Update existing damage entry
  void updateDamage(DamageEntry updatedDamage) {
    final index = state.damages.indexWhere((d) => d.id == updatedDamage.id);
    if (index != -1) {
      final updatedList = [...state.damages];
      updatedList[index] = updatedDamage;
      state = state.copyWith(
        damages: updatedList,
        generatedReport: null,
      );
    }
  }

  /// Toggle accident history
  void setAccidentHistory(bool hasAccident) {
    state = state.copyWith(
      hasAccidentHistory: hasAccident,
      generatedReport: null,
    );
  }

  /// Generate AI report from current state
  void generateReport() {
    state = state.copyWith(isGenerating: true);

    try {
      final report = _service.generateReport(
        damages: state.damages,
        hasAccidentHistory: state.hasAccidentHistory,
      );

      state = state.copyWith(
        generatedReport: report,
        isGenerating: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate report: $e',
      );
    }
  }

  /// Clear all damages and reset
  void reset() {
    state = DamageReportState.initial();
  }

  /// Load from existing data (e.g., editing existing vehicle)
  void loadFromReport(AiDamageReport report) {
    state = state.copyWith(
      damages: report.damages,
      hasAccidentHistory: report.hasAccidentHistory,
      generatedReport: report,
    );
  }
}

/// State class for damage report management
class DamageReportState {
  final List<DamageEntry> damages;
  final bool hasAccidentHistory;
  final AiDamageReport? generatedReport;
  final bool isGenerating;
  final String? error;

  const DamageReportState({
    required this.damages,
    required this.hasAccidentHistory,
    this.generatedReport,
    this.isGenerating = false,
    this.error,
  });

  factory DamageReportState.initial() {
    return const DamageReportState(
      damages: [],
      hasAccidentHistory: false,
    );
  }

  DamageReportState copyWith({
    List<DamageEntry>? damages,
    bool? hasAccidentHistory,
    AiDamageReport? generatedReport,
    bool? isGenerating,
    String? error,
  }) {
    return DamageReportState(
      damages: damages ?? this.damages,
      hasAccidentHistory: hasAccidentHistory ?? this.hasAccidentHistory,
      generatedReport: generatedReport,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
    );
  }
}

/// Provider for damage report state management
final damageReportProvider =
    StateNotifierProvider<DamageReportNotifier, DamageReportState>((ref) {
  final service = ref.watch(aiDamageServiceProvider);
  return DamageReportNotifier(service);
});

/// Computed provider: Can generate report?
final canGenerateReportProvider = Provider<bool>((ref) {
  final state = ref.watch(damageReportProvider);
  return state.damages.isNotEmpty || state.hasAccidentHistory;
});

/// Computed provider: Total damage count
final totalDamagesProvider = Provider<int>((ref) {
  return ref.watch(damageReportProvider).damages.length;
});