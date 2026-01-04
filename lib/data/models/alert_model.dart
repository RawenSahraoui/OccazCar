import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String userId;
  final String title;
  final List<String>? brands;
  final List<String>? models;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final int? maxKilometers;
  final String? city;
  final List<String>? fuelTypes;
  final List<String>? conditions;
  final List<String>? transmissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int triggeredCount;

  AlertModel({
    required this.id,
    required this.userId,
    required this.title,
    this.brands,
    this.models,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.maxKilometers,
    this.city,
    this.fuelTypes,
    this.conditions,
    this.transmissions,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
    this.triggeredCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'brands': brands,
      'models': models,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minYear': minYear,
      'maxYear': maxYear,
      'maxKilometers': maxKilometers,
      'city': city,
      'fuelTypes': fuelTypes,
      'conditions': conditions,
      'transmissions': transmissions,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastTriggered': lastTriggered != null ? Timestamp.fromDate(lastTriggered!) : null,
      'triggeredCount': triggeredCount,
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map, String id) {
    return AlertModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      brands: map['brands'] != null ? List<String>.from(map['brands']) : null,
      models: map['models'] != null ? List<String>.from(map['models']) : null,
      minPrice: map['minPrice']?.toDouble(),
      maxPrice: map['maxPrice']?.toDouble(),
      minYear: map['minYear']?.toInt(),
      maxYear: map['maxYear']?.toInt(),
      maxKilometers: map['maxKilometers']?.toInt(),
      city: map['city'],
      fuelTypes: map['fuelTypes'] != null ? List<String>.from(map['fuelTypes']) : null,
      conditions: map['conditions'] != null ? List<String>.from(map['conditions']) : null,
      transmissions: map['transmissions'] != null ? List<String>.from(map['transmissions']) : null,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastTriggered: map['lastTriggered'] != null ? (map['lastTriggered'] as Timestamp).toDate() : null,
      triggeredCount: map['triggeredCount'] ?? 0,
    );
  }

  AlertModel copyWith({
    String? id,
    String? userId,
    String? title,
    List<String>? brands,
    List<String>? models,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    int? maxKilometers,
    String? city,
    List<String>? fuelTypes,
    List<String>? conditions,
    List<String>? transmissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggered,
    int? triggeredCount,
  }) {
    return AlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      brands: brands ?? this.brands,
      models: models ?? this.models,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      maxKilometers: maxKilometers ?? this.maxKilometers,
      city: city ?? this.city,
      fuelTypes: fuelTypes ?? this.fuelTypes,
      conditions: conditions ?? this.conditions,
      transmissions: transmissions ?? this.transmissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      triggeredCount: triggeredCount ?? this.triggeredCount,
    );
  }

  String getCriteriaDescription() {
    List<String> criteria = [];

    if (brands != null && brands!.isNotEmpty) {
      criteria.add('Marques: ${brands!.join(", ")}');
    }
    if (models != null && models!.isNotEmpty) {
      criteria.add('Modèles: ${models!.join(", ")}');
    }
    if (minPrice != null || maxPrice != null) {
      String price = 'Prix: ';
      if (minPrice != null) price += '${minPrice!.toInt()} TND';
      if (minPrice != null && maxPrice != null) price += ' - ';
      if (maxPrice != null) price += '${maxPrice!.toInt()} TND';
      criteria.add(price);
    }
    if (minYear != null || maxYear != null) {
      String year = 'Année: ';
      if (minYear != null) year += '$minYear';
      if (minYear != null && maxYear != null) year += ' - ';
      if (maxYear != null) year += '$maxYear';
      criteria.add(year);
    }
    if (maxKilometers != null) {
      criteria.add('Max: ${maxKilometers!} km');
    }
    if (city != null) {
      criteria.add('Ville: $city');
    }
    if (fuelTypes != null && fuelTypes!.isNotEmpty) {
      criteria.add('Carburant: ${fuelTypes!.join(", ")}');
    }
    if (conditions != null && conditions!.isNotEmpty) {
      criteria.add('État: ${conditions!.join(", ")}');
    }
    if (transmissions != null && transmissions!.isNotEmpty) {
      criteria.add('Transmission: ${transmissions!.join(", ")}');
    }

    return criteria.isEmpty ? 'Tous les véhicules' : criteria.join(' • ');
  }
}