import 'package:cloud_firestore/cloud_firestore.dart';

enum VehicleCondition { excellent, good, fair, poor }
enum VehicleStatus { available, sold, reserved, archived }
enum FuelType { gasoline, diesel, electric, hybrid, other }
enum TransmissionType { manual, automatic, semiAutomatic }

class VehicleModel {
  final String id;
  final String sellerId;
  final String sellerName;
  
  // Informations de base
  final String brand;
  final String model;
  final int year;
  final int mileage; // en km
  final double price;
  
  // Détails techniques
  final FuelType fuelType;
  final TransmissionType transmission;
  final int? engineSize; // en cc
  final int? horsePower;
  final String? color;
  
  // État et condition
  final VehicleCondition condition;
  final VehicleStatus status;
  
  // Description
  final String description;
  final List<String> features; // Caractéristiques (GPS, climatisation, etc.)
  
  // Images
  final List<String> imageUrls;
  final String? thumbnailUrl;
  
  // Localisation
  final String city;
  final String? address;
  final double? latitude;
  final double? longitude;
  
  // Historique
  final int numberOfOwners;
  final bool hasAccidents;
  final String? accidentHistory;
  final List<MaintenanceRecord>? maintenanceHistory;
  
  // Métadonnées
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int favoriteCount;

  VehicleModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.price,
    required this.fuelType,
    required this.transmission,
    this.engineSize,
    this.horsePower,
    this.color,
    required this.condition,
    required this.status,
    required this.description,
    required this.features,
    required this.imageUrls,
    this.thumbnailUrl,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
    required this.numberOfOwners,
    required this.hasAccidents,
    this.accidentHistory,
    this.maintenanceHistory,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.favoriteCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'brand': brand,
      'model': model,
      'year': year,
      'mileage': mileage,
      'price': price,
      'fuelType': fuelType.name,
      'transmission': transmission.name,
      'engineSize': engineSize,
      'horsePower': horsePower,
      'color': color,
      'condition': condition.name,
      'status': status.name,
      'description': description,
      'features': features,
      'imageUrls': imageUrls,
      'thumbnailUrl': thumbnailUrl,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'numberOfOwners': numberOfOwners,
      'hasAccidents': hasAccidents,
      'accidentHistory': accidentHistory,
      'maintenanceHistory': maintenanceHistory?.map((m) => m.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      mileage: map['mileage'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      fuelType: FuelType.values.firstWhere(
        (e) => e.name == map['fuelType'],
        orElse: () => FuelType.gasoline,
      ),
      transmission: TransmissionType.values.firstWhere(
        (e) => e.name == map['transmission'],
        orElse: () => TransmissionType.manual,
      ),
      engineSize: map['engineSize'],
      horsePower: map['horsePower'],
      color: map['color'],
      condition: VehicleCondition.values.firstWhere(
        (e) => e.name == map['condition'],
        orElse: () => VehicleCondition.good,
      ),
      status: VehicleStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VehicleStatus.available,
      ),
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      thumbnailUrl: map['thumbnailUrl'],
      city: map['city'] ?? '',
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      numberOfOwners: map['numberOfOwners'] ?? 1,
      hasAccidents: map['hasAccidents'] ?? false,
      accidentHistory: map['accidentHistory'],
      maintenanceHistory: map['maintenanceHistory'] != null
          ? List<MaintenanceRecord>.from(
              map['maintenanceHistory'].map((m) => MaintenanceRecord.fromMap(m)))
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      viewCount: map['viewCount'] ?? 0,
      favoriteCount: map['favoriteCount'] ?? 0,
    );
  }

  VehicleModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? brand,
    String? model,
    int? year,
    int? mileage,
    double? price,
    FuelType? fuelType,
    TransmissionType? transmission,
    int? engineSize,
    int? horsePower,
    String? color,
    VehicleCondition? condition,
    VehicleStatus? status,
    String? description,
    List<String>? features,
    List<String>? imageUrls,
    String? thumbnailUrl,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    int? numberOfOwners,
    bool? hasAccidents,
    String? accidentHistory,
    List<MaintenanceRecord>? maintenanceHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? favoriteCount,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      mileage: mileage ?? this.mileage,
      price: price ?? this.price,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      engineSize: engineSize ?? this.engineSize,
      horsePower: horsePower ?? this.horsePower,
      color: color ?? this.color,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      description: description ?? this.description,
      features: features ?? this.features,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      city: city ?? this.city,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      numberOfOwners: numberOfOwners ?? this.numberOfOwners,
      hasAccidents: hasAccidents ?? this.hasAccidents,
      accidentHistory: accidentHistory ?? this.accidentHistory,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }
}

// Sous-modèle pour l'historique de maintenance
class MaintenanceRecord {
  final DateTime date;
  final String type; // "Oil change", "Tire replacement", etc.
  final String description;
  final double? cost;
  final int? mileageAtService;

  MaintenanceRecord({
    required this.date,
    required this.type,
    required this.description,
    this.cost,
    this.mileageAtService,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'type': type,
      'description': description,
      'cost': cost,
      'mileageAtService': mileageAtService,
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      cost: map['cost']?.toDouble(),
      mileageAtService: map['mileageAtService'],
    );
  }
}