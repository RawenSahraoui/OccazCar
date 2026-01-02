class AppConstants {
  // Collections Firestore
  static const String usersCollection = 'users';
  static const String vehiclesCollection = 'vehicles';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';

  // Storage paths
  static const String vehiclesStorage = 'vehicles';
  static const String usersStorage = 'users';
  static const String chatsStorage = 'chats';

  // Marques de voitures populaires en Tunisie
  static const List<String> carBrands = [
    'Renault',
    'Peugeot',
    'Citroën',
    'Volkswagen',
    'Toyota',
    'Hyundai',
    'Kia',
    'Fiat',
    'Dacia',
    'Seat',
    'Nissan',
    'Ford',
    'Opel',
    'Mercedes-Benz',
    'BMW',
    'Audi',
    'Mazda',
    'Suzuki',
    'Mitsubishi',
    'Chevrolet',
    'Autre',
  ];

  // Villes de Tunisie
  static const List<String> tunisianCities = [
    'Tunis',
    'Ariana',
    'Ben Arous',
    'Manouba',
    'Sfax',
    'Sousse',
    'Nabeul',
    'Bizerte',
    'Gabès',
    'Kairouan',
    'Monastir',
    'Gafsa',
    'Médenine',
    'Béja',
    'Jendouba',
    'Mahdia',
    'Kasserine',
    'Tataouine',
    'Kébili',
    'Siliana',
    'Le Kef',
    'Tozeur',
    'Sidi Bouzid',
    'Zaghouan',
  ];

  // Caractéristiques communes
  static const List<String> commonFeatures = [
    'Climatisation',
    'GPS',
    'Bluetooth',
    'Caméra de recul',
    'Toit ouvrant',
    'Sièges en cuir',
    'Régulateur de vitesse',
    'Système audio premium',
    'Sièges chauffants',
    'Phares LED',
    'Capteurs de stationnement',
    'Système de navigation',
    'Verrouillage centralisé',
    'Airbags',
    'ABS',
    'ESP',
    'Jantes en alliage',
  ];

  // Limites
  static const int maxVehicleImages = 10;
  static const int maxMessageLength = 500;
  static const int minVehiclePrice = 1000;
  static const int maxVehiclePrice = 1000000;
  static const int minVehicleYear = 1990;
}