import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/favorites_provider.dart';

class VehicleCard extends ConsumerStatefulWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  ConsumerState<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends ConsumerState<VehicleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###', 'fr_FR');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavoriteAsync = ref.watch(isFavoriteProvider(widget.vehicle.id));

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
              width: 1,
            ),
            boxShadow: isDark ? AppTheme.cardShadowDark : AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ IMAGE AVEC BADGES
              Stack(
                children: [
                  // Image principale
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: widget.vehicle.thumbnailUrl != null
                          ? CachedNetworkImage(
                        imageUrl: widget.vehicle.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.backgroundColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.backgroundColor,
                          child: Center(
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              size: 48,
                              color: isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.backgroundColor,
                        child: Center(
                          child: Icon(
                            Icons.directions_car_filled_rounded,
                            size: 48,
                            color: isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Badge condition (haut gauche)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getConditionColor(widget.vehicle.condition),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getConditionLabel(widget.vehicle.condition),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Bouton favori (haut droit) - FONCTIONNEL
                  Positioned(
                    top: 8,
                    right: 8,
                    child: isFavoriteAsync.when(
                      data: (isFavorite) => Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 20,
                          ),
                          color: AppTheme.accentColor,
                          onPressed: () async {
                            await ref.read(favoritesNotifierProvider).toggleFavorite(widget.vehicle.id);

                            // Feedback visuel
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? 'Retiré des favoris'
                                        : 'Ajouté aux favoris',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      loading: () => Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),

                  // Overlay gradient en bas
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 📝 INFORMATIONS
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Marque et modèle
                    Text(
                      '${widget.vehicle.brand} ${widget.vehicle.model}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Prix
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer_rounded,
                          size: 16,
                          color: isDark ? AppTheme.secondaryColor : AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${numberFormat.format(widget.vehicle.price)} TND',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Séparateur
                    Container(
                      height: 1,
                      color: isDark ? AppTheme.darkDivider : AppTheme.dividerColor,
                    ),
                    const SizedBox(height: 12),

                    // Specs en ligne
                    Row(
                      children: [
                        _buildIconSpec(
                          Icons.calendar_today_rounded,
                          widget.vehicle.year.toString(),
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 14,
                          color: isDark ? AppTheme.darkDivider : AppTheme.dividerColor,
                        ),
                        const SizedBox(width: 12),
                        _buildIconSpec(
                          Icons.speed_rounded,
                          '${numberFormat.format(widget.vehicle.mileage ~/ 1000)}K',
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 14,
                          color: isDark ? AppTheme.darkDivider : AppTheme.dividerColor,
                        ),
                        const SizedBox(width: 12),
                        _buildIconSpec(
                          Icons.local_gas_station_rounded,
                          _getFuelIcon(widget.vehicle.fuelType),
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Localisation
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.vehicle.city,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSpec(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getConditionColor(VehicleCondition condition) {
    switch (condition) {
      case VehicleCondition.excellent:
        return AppTheme.successColor;
      case VehicleCondition.good:
        return AppTheme.primaryColor;
      case VehicleCondition.fair:
        return const Color(0xFFF59E0B);
      case VehicleCondition.poor:
        return AppTheme.accentColor;
    }
  }

  String _getConditionLabel(VehicleCondition condition) {
    switch (condition) {
      case VehicleCondition.excellent:
        return 'EXCELLENT';
      case VehicleCondition.good:
        return 'BON ÉTAT';
      case VehicleCondition.fair:
        return 'MOYEN';
      case VehicleCondition.poor:
        return 'À RÉNOVER';
    }
  }

  String _getFuelIcon(FuelType type) {
    switch (type) {
      case FuelType.gasoline:
        return 'Ess';
      case FuelType.diesel:
        return 'Dies';
      case FuelType.electric:
        return 'Élec';
      case FuelType.hybrid:
        return 'Hyb';
      case FuelType.other:
        return 'Autre';
    }
  }
}