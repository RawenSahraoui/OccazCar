class AiDescriptionService {
  String generateDescription({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    required String fuel,
    required String gearbox,
    required String condition,
    required String city,
  }) {
    return '''
$brand $model $year en $condition, soigneusement entretenue et prête à rouler.

🚗 Caractéristiques principales :
• Kilométrage : $mileage km
• Carburant : $fuel
• Boîte de vitesses : $gearbox

Ce véhicule offre un excellent confort de conduite et une fiabilité reconnue, idéal pour les trajets quotidiens comme pour les longs voyages.

📍 Disponible à $city.
Contactez-moi pour plus d’informations ou pour planifier une visite.
''';
  }
}
