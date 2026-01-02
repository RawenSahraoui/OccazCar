import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../seller/seller_profile_screen.dart';
import '../chat/chat_screen.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;

  const VehicleDetailScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(vehicleId));
    final numberFormat = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) {
            return const Center(child: Text('Véhicule non trouvé'));
          }

          return CustomScrollView(
            slivers: [
              // AppBar avec images
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: vehicle.imageUrls.isNotEmpty
                      ? PageView.builder(
                          itemCount: vehicle.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: vehicle.imageUrls[index],
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
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Indicateur de page
                                if (vehicle.imageUrls.length > 1)
                                  Positioned(
                                    bottom: 16,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${index + 1}/${vehicle.imageUrls.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.directions_car,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et prix
                      Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${numberFormat.format(vehicle.price)} TND',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Informations principales
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.calendar_today,
                                'Année',
                                vehicle.year.toString(),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.speed,
                                'Kilométrage',
                                '${numberFormat.format(vehicle.mileage)} km',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.local_gas_station,
                                'Carburant',
                                _getFuelTypeLabel(vehicle.fuelType),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.settings,
                                'Transmission',
                                _getTransmissionLabel(vehicle.transmission),
                              ),
                              if (vehicle.color != null) ...[
                                const Divider(),
                                _buildInfoRow(
                                  Icons.palette,
                                  'Couleur',
                                  vehicle.color!,
                                ),
                              ],
                              if (vehicle.engineSize != null) ...[
                                const Divider(),
                                _buildInfoRow(
                                  Icons.build,
                                  'Cylindrée',
                                  '${vehicle.engineSize} cc',
                                ),
                              ],
                              if (vehicle.horsePower != null) ...[
                                const Divider(),
                                _buildInfoRow(
                                  Icons.speed,
                                  'Puissance',
                                  '${vehicle.horsePower} ch',
                                ),
                              ],
                              const Divider(),
                              _buildInfoRow(
                                Icons.check_circle,
                                'État',
                                _getConditionLabel(vehicle.condition),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.person,
                                'Propriétaires',
                                vehicle.numberOfOwners == 1
                                    ? '1er propriétaire'
                                    : '${vehicle.numberOfOwners} propriétaires',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            vehicle.description,
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Caractéristiques
                      if (vehicle.features.isNotEmpty) ...[
                        Text(
                          'Caractéristiques',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: vehicle.features.map((feature) {
                                return Chip(
                                  label: Text(feature),
                                  avatar: const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  backgroundColor:
                                      AppTheme.primaryColor.withOpacity(0.1),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Historique
                      if (vehicle.hasAccidents) ...[
                        Card(
                          color: Colors.orange.withOpacity(0.1),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Ce véhicule a eu des accidents',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Localisation
                      Text(
                        'Localisation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text(vehicle.city),
                          subtitle: vehicle.address != null
                              ? Text(vehicle.address!)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vendeur
                      Text(
                        'Vendeur',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              vehicle.sellerName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(vehicle.sellerName),
                          subtitle: const Text('Voir le profil'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SellerProfileScreen(
                                  sellerId: vehicle.sellerId,
                                  sellerName: vehicle.sellerName,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Informations complémentaires
                      Card(
                        color: Colors.grey[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Publié le ${DateFormat('dd/MM/yyyy').format(vehicle.createdAt)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${vehicle.viewCount} vues',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: vehicleAsync.maybeWhen(
        data: (vehicle) {
          if (vehicle == null) return null;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Appeler le vendeur'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 60,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Contacter ${vehicle.sellerName}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Numéro de téléphone : +216 XX XXX XXX',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Appel téléphonique - À venir'),
                                    ),
                                  );
                                },
                                child: const Text('Appeler'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Appeler'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final user = await ref.read(currentUserProvider.future);
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vous devez être connecté'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (user.uid == vehicle.sellerId) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('C\'est votre propre annonce'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        try {
                          // Create or get conversation
                          final conversationId = await ref
                              .read(createConversationProvider.notifier)
                              .createOrGetConversation(
                                vehicleId: vehicle.id,
                                buyerId: user.uid,
                                sellerId: vehicle.sellerId,
                                vehicleTitle: '${vehicle.brand} ${vehicle.model}',
                                vehicleThumbnail: vehicle.thumbnailUrl ?? '',
                                buyerName: user.displayName,
                                sellerName: vehicle.sellerName,
                                buyerPhotoUrl: user.photoUrl,
                              );

                          if (context.mounted) {
                            Navigator.pop(context); // Close loading

                            if (conversationId != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Conversation créée ! Allez dans Messages pour discuter.',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erreur lors de la création de la conversation'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context); // Close loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
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

  String _getTransmissionLabel(TransmissionType type) {
    switch (type) {
      case TransmissionType.manual:
        return 'Manuelle';
      case TransmissionType.automatic:
        return 'Automatique';
      case TransmissionType.semiAutomatic:
        return 'Semi-automatique';
    }
  }

  String _getConditionLabel(VehicleCondition condition) {
    switch (condition) {
      case VehicleCondition.excellent:
        return 'Excellent';
      case VehicleCondition.good:
        return 'Bon';
      case VehicleCondition.fair:
        return 'Moyen';
      case VehicleCondition.poor:
        return 'Mauvais';
    }
  }
}