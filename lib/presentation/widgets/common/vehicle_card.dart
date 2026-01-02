import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###', 'fr_FR');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: vehicle.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: vehicle.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.directions_car,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.directions_car,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
            ),

            // Informations
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Prix
                  Text(
                    '${numberFormat.format(vehicle.price)} TND',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Détails
                  Row(
                    children: [
                      _buildInfo(
                        Icons.calendar_today,
                        vehicle.year.toString(),
                      ),
                      const SizedBox(width: 16),
                      _buildInfo(
                        Icons.speed,
                        '${numberFormat.format(vehicle.mileage)} km',
                      ),
                      const SizedBox(width: 16),
                      _buildInfo(
                        Icons.local_gas_station,
                        _getFuelTypeLabel(vehicle.fuelType),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Localisation
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.city,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _getFuelTypeLabel(FuelType type) {
    switch (type) {
      case FuelType.gasoline:
        return 'Essence';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Électrique';
      case FuelType.hybrid:
        return 'Hybride';
      case FuelType.other:
        return 'Autre';
    }
  }
}