import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/vehicle_card.dart';
import '../buyer/vehicle_detail_screen.dart';
import 'add_vehicle_screen.dart';
import 'edit_vehicle_screen.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes annonces'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Utilisateur non connecté'));
          }

          final vehiclesAsync = ref.watch(
            sellerVehiclesProvider(user.uid),
          );

          return vehiclesAsync.when(
            data: (vehicles) {
              if (vehicles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_box_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune annonce',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Publiez votre première annonce',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddVehicleScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Publier une annonce'),
                      ),
                    ],
                  ),
                );
              }

              // Statistiques
              final availableCount = vehicles
                  .where((v) => v.status == VehicleStatus.available)
                  .length;
              final soldCount =
                  vehicles.where((v) => v.status == VehicleStatus.sold).length;

              return Column(
                children: [
                  // Statistiques
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            label: 'Disponibles',
                            value: availableCount.toString(),
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.sell,
                            label: 'Vendus',
                            value: soldCount.toString(),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.list,
                            label: 'Total',
                            value: vehicles.length.toString(),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Liste des véhicules
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _SellerVehicleCard(vehicle: vehicle),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Erreur: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle annonce'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerVehicleCard extends ConsumerWidget {
  final VehicleModel vehicle;

  const _SellerVehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VehicleDetailScreen(vehicleId: vehicle.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Miniature
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: vehicle.thumbnailUrl != null
                    ? Image.network(
                        vehicle.thumbnailUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.directions_car),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.directions_car),
                      ),
              ),
              const SizedBox(width: 12),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.price.toInt()} TND',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          vehicle.status == VehicleStatus.available
                              ? Icons.check_circle
                              : Icons.sell,
                          size: 14,
                          color: vehicle.status == VehicleStatus.available
                              ? Colors.green
                              : Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.status == VehicleStatus.available
                              ? 'Disponible'
                              : vehicle.status == VehicleStatus.sold
                                  ? 'Vendu'
                                  : 'Réservé',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu
              // Menu
PopupMenuButton(
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit),
          SizedBox(width: 8),
          Text('Modifier'),
        ],
      ),
    ),
    if (vehicle.status == VehicleStatus.available)
      const PopupMenuItem(
        value: 'reserve',
        child: Row(
          children: [
            Icon(Icons.schedule),
            SizedBox(width: 8),
            Text('Marquer comme réservé'),
          ],
        ),
      ),
    if (vehicle.status != VehicleStatus.sold)
      const PopupMenuItem(
        value: 'sold',
        child: Row(
          children: [
            Icon(Icons.sell),
            SizedBox(width: 8),
            Text('Marquer comme vendu'),
          ],
        ),
      ),
    if (vehicle.status == VehicleStatus.sold)
      const PopupMenuItem(
        value: 'reactivate',
        child: Row(
          children: [
            Icon(Icons.replay),
            SizedBox(width: 8),
            Text('Réactiver'),
          ],
        ),
      ),
    const PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete, color: Colors.red),
          SizedBox(width: 8),
          Text('Supprimer', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
  onSelected: (value) async {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditVehicleScreen(vehicle: vehicle),
          ),
        );
        break;
      case 'reserve':
        await ref
            .read(updateVehicleStatusProvider.notifier)
            .updateStatus(
              vehicleId: vehicle.id,
              newStatus: VehicleStatus.reserved,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Véhicule marqué comme réservé'),
            ),
          );
        }
        break;
      case 'sold':
        await ref
            .read(updateVehicleStatusProvider.notifier)
            .updateStatus(
              vehicleId: vehicle.id,
              newStatus: VehicleStatus.sold,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Véhicule marqué comme vendu'),
            ),
          );
        }
        break;
      case 'reactivate':
        await ref
            .read(updateVehicleStatusProvider.notifier)
            .updateStatus(
              vehicleId: vehicle.id,
              newStatus: VehicleStatus.available,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Véhicule réactivé'),
            ),
          );
        }
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer l\'annonce'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette annonce ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          await ref
              .read(deleteVehicleProvider.notifier)
              .deleteVehicle(vehicle.id);

          if (context.mounted) {
            Navigator.pop(context); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Annonce supprimée'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        break;
    }
  },
),
            ],
          ),
        ),
      ),
    );
  }
}