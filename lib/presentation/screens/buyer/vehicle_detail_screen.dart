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

class VehicleDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  ConsumerState<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(widget.vehicleId));
    final numberFormat = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: vehicleAsync.when(
        data: (vehicle) {
          if (vehicle == null) {
            return _buildNotFound();
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 🖼️ HEADER IMAGES
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: AppTheme.surfaceColor,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppTheme.primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border_rounded),
                          color: AppTheme.accentColor,
                          onPressed: () {},
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share_rounded),
                          color: AppTheme.primaryColor,
                          onPressed: () {},
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (vehicle.imageUrls.isNotEmpty)
                            PageView.builder(
                              controller: _pageController,
                              itemCount: vehicle.imageUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: vehicle.imageUrls[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppTheme.backgroundColor,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      _buildImagePlaceholder(),
                                );
                              },
                            )
                          else
                            _buildImagePlaceholder(),

                          // Indicateur de pages
                          if (vehicle.imageUrls.length > 1)
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      vehicle.imageUrls.length,
                                          (index) => Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        width: index == _currentImageIndex ? 20 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: index == _currentImageIndex
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 📝 CONTENU
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec prix
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.borderColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge condition
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getConditionColor(vehicle.condition),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getConditionLabel(vehicle.condition),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Titre
                              Text(
                                '${vehicle.brand} ${vehicle.model}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Prix
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.goldGradient,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.secondaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${numberFormat.format(vehicle.price)} TND',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Caractéristiques principales
                        _buildSpecsSection(vehicle, numberFormat),

                        const SizedBox(height: 8),

                        // Description
                        _buildSection(
                          'Description',
                          Icons.description_rounded,
                          child: Text(
                            vehicle.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),

                        // Équipements
                        if (vehicle.features.isNotEmpty)
                          _buildSection(
                            'Équipements & Options',
                            Icons.star_rounded,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: vehicle.features.map((feature) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.successColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: AppTheme.successColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        feature,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // Alerte accidents
                        if (vehicle.hasAccidents)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.warning_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Historique d\'accidents',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vehicle.accidentHistory ??
                                            'Ce véhicule a eu des accidents',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Localisation
                        _buildSection(
                          'Localisation',
                          Icons.location_on_rounded,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.premiumGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_city_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.city,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (vehicle.address != null)
                                        Text(
                                          vehicle.address!,
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Vendeur
                        _buildSection(
                          'Vendeur',
                          Icons.person_rounded,
                          child: InkWell(
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
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.premiumGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        vehicle.sellerName[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vehicle.sellerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Voir le profil →',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Info publication
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoChip(
                                Icons.calendar_today_rounded,
                                DateFormat('dd/MM/yy').format(vehicle.createdAt),
                              ),
                              Container(
                                width: 1,
                                height: 20,
                                color: AppTheme.borderColor,
                              ),
                              _buildInfoChip(
                                Icons.visibility_rounded,
                                '${vehicle.viewCount} vues',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBar(vehicle),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 80,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSpecsSection(VehicleModel vehicle, NumberFormat numberFormat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Caractéristiques techniques',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.borderColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSpecRow('Année', vehicle.year.toString(), Icons.calendar_today_rounded),
                const SizedBox(height: 12),
                _buildSpecRow('Kilométrage', '${numberFormat.format(vehicle.mileage)} km', Icons.speed_rounded),
                const SizedBox(height: 12),
                _buildSpecRow('Carburant', _getFuelTypeLabel(vehicle.fuelType), Icons.local_gas_station_rounded),
                const SizedBox(height: 12),
                _buildSpecRow('Transmission', _getTransmissionLabel(vehicle.transmission), Icons.settings_rounded),
                if (vehicle.horsePower != null) ...[
                  const SizedBox(height: 12),
                  _buildSpecRow('Puissance', '${vehicle.horsePower} ch', Icons.flash_on_rounded),
                ],
                if (vehicle.color != null) ...[
                  const SizedBox(height: 12),
                  _buildSpecRow('Couleur', vehicle.color!, Icons.palette_rounded),
                ],
                const SizedBox(height: 12),
                _buildSpecRow(
                  'Propriétaires',
                  vehicle.numberOfOwners == 1 ? '1er propriétaire' : '${vehicle.numberOfOwners} propriétaires',
                  Icons.person_outline_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.borderColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(VehicleModel vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCallDialog(vehicle),
                icon: const Icon(Icons.phone_rounded, size: 18),
                label: const Text('Appeler'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _handleMessage(vehicle),
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: const Text('Message'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallDialog(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppTheme.premiumGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Appeler ${vehicle.sellerName}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text('+216 XX XXX XXX', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                const SnackBar(content: Text('Appel - À venir')),
              );
            },
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMessage(VehicleModel vehicle) async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) {
      _showSnackBar('Vous devez être connecté', AppTheme.accentColor);
      return;
    }
    if (user.uid == vehicle.sellerId) {
      _showSnackBar('C\'est votre annonce', Colors.orange);
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final conversationId = await ref.read(createConversationProvider.notifier).createOrGetConversation(
        vehicleId: vehicle.id,
        buyerId: user.uid,
        sellerId: vehicle.sellerId,
        vehicleTitle: '${vehicle.brand} ${vehicle.model}',
        vehicleThumbnail: vehicle.thumbnailUrl ?? '',
        buyerName: user.displayName,
        sellerName: vehicle.sellerName,
        buyerPhotoUrl: user.photoUrl,
      );

      if (mounted) {
        Navigator.pop(context);
        if (conversationId != null) {
          _showSnackBar('Conversation créée !', AppTheme.successColor);
        } else {
          _showSnackBar('Erreur', AppTheme.accentColor);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Erreur: $e', AppTheme.accentColor);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.car_crash_rounded, size: 80, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          const Text('Véhicule non trouvé'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 80, color: AppTheme.accentColor),
          const SizedBox(height: 16),
          Text('Erreur: $error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Retour')),
        ],
      ),
    );
  }

  Color _getConditionColor(VehicleCondition condition) {
    switch (condition) {
      case VehicleCondition.excellent: return AppTheme.successColor;
      case VehicleCondition.good: return AppTheme.primaryColor;
      case VehicleCondition.fair: return const Color(0xFFF59E0B);
      case VehicleCondition.poor: return AppTheme.accentColor;
    }
  }

  String _getConditionLabel(VehicleCondition condition) {
    switch (condition) {
      case VehicleCondition.excellent: return 'EXCELLENT';
      case VehicleCondition.good: return 'BON ÉTAT';
      case VehicleCondition.fair: return 'MOYEN';
      case VehicleCondition.poor: return 'À RÉNOVER';
    }
  }

  String _getFuelTypeLabel(FuelType type) {
    switch (type) {
      case FuelType.gasoline: return 'Essence';
      case FuelType.diesel: return 'Diesel';
      case FuelType.electric: return 'Électrique';
      case FuelType.hybrid: return 'Hybride';
      case FuelType.other: return 'Autre';
    }
  }

  String _getTransmissionLabel(TransmissionType type) {
    switch (type) {
      case TransmissionType.manual: return 'Manuelle';
      case TransmissionType.automatic: return 'Automatique';
      case TransmissionType.semiAutomatic: return 'Semi-automatique';
    }
  }
}