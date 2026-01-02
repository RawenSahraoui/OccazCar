import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/common/vehicle_card.dart';
import '../buyer/vehicle_detail_screen.dart';

class SellerProfileScreen extends ConsumerWidget {
  final String sellerId;
  final String sellerName;
  final String? sellerPhotoUrl;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhotoUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(sellerVehiclesProvider(sellerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil du vendeur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partage - À venir')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    backgroundImage: sellerPhotoUrl != null
                        ? NetworkImage(sellerPhotoUrl!)
                        : null,
                    child: sellerPhotoUrl == null
                        ? Text(
                            sellerName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sellerName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 20),
                      SizedBox(width: 4),
                      Text('Vendeur vérifié'),
                    ],
                  ),
                ],
              ),
            ),

            // Statistiques
            vehiclesAsync.when(
              data: (vehicles) {
                final activeVehicles = vehicles
                    .where((v) => v.status == VehicleStatus.available)
                    .length;
                final soldVehicles = vehicles
                    .where((v) => v.status == VehicleStatus.sold)
                    .length;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.directions_car,
                          label: 'Annonces actives',
                          value: activeVehicles.toString(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.sell,
                          label: 'Vendus',
                          value: soldVehicles.toString(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star,
                          label: 'Note',
                          value: '4.5',
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showCallDialog(context);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Appeler'),
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

                        if (user.uid == sellerId) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('C\'est votre propre profil'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Get first available vehicle to create conversation
                        final vehiclesAsync = ref.read(sellerVehiclesProvider(sellerId));
                        await vehiclesAsync.when(
                          data: (vehicles) async {
                            if (vehicles.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Aucun véhicule disponible'),
                                ),
                              );
                              return;
                            }

                            final vehicle = vehicles.first;
                            
                            // Show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              final conversationId = await ref
                                  .read(createConversationProvider.notifier)
                                  .createOrGetConversation(
                                    vehicleId: vehicle.id,
                                    buyerId: user.uid,
                                    sellerId: sellerId,
                                    vehicleTitle: '${vehicle.brand} ${vehicle.model}',
                                    vehicleThumbnail: vehicle.thumbnailUrl ?? '',
                                    buyerName: user.displayName,
                                    sellerName: sellerName,
                                    buyerPhotoUrl: user.photoUrl,
                                    sellerPhotoUrl: sellerPhotoUrl,
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
                          loading: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chargement...'),
                              ),
                            );
                          },
                          error: (error, _) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Annonces du vendeur
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Annonces de ${sellerName.split(' ').first}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),

            vehiclesAsync.when(
              data: (vehicles) {
                final activeVehicles = vehicles
                    .where((v) => v.status == VehicleStatus.available)
                    .toList();

                if (activeVehicles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune annonce active',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: activeVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = activeVehicles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: VehicleCard(
                        vehicle: vehicle,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VehicleDetailScreen(
                                vehicleId: vehicle.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: $error'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
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
              'Contactez $sellerName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'La fonctionnalité d\'appel direct sera disponible prochainement.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}