import '../data/models/alert_model.dart';
import '../data/models/vehicle_model.dart';

bool vehicleMatchesAlert(VehicleModel v, AlertModel a) {
  if (!a.isActive) return false;

  if (a.brands != null &&
      a.brands!.isNotEmpty &&
      !a.brands!.contains(v.brand)) {
    return false;
  }

  if (a.models != null &&
      a.models!.isNotEmpty &&
      !a.models!.contains(v.model)) {
    return false;
  }

  if (a.city != null && v.city != a.city) return false;

  if (a.minPrice != null && v.price < a.minPrice!) return false;
  if (a.maxPrice != null && v.price > a.maxPrice!) return false;

  if (a.minYear != null && v.year < a.minYear!) return false;
  if (a.maxYear != null && v.year > a.maxYear!) return false;

  if (a.fuelTypes != null &&
      a.fuelTypes!.isNotEmpty &&
      !a.fuelTypes!.contains(v.fuelType)) {
    return false;
  }

  if (a.conditions != null &&
      a.conditions!.isNotEmpty &&
      !a.conditions!.contains(v.condition)) {
    return false;
  }

  if (a.transmissions != null &&
      a.transmissions!.isNotEmpty &&
      !a.transmissions!.contains(v.transmission)) {
    return false;
  }

  return true;
}
