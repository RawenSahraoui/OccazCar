import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/vehicle_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme
          .backgroundColor,
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return _buildNotLoggedIn(context);
            }

            return CustomScrollView(
              slivers: [
                // 🎨 HEADER PROFIL
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : AppTheme
                          .surfaceColor,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : AppTheme.primaryColor)
                              .withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? AppTheme.goldGradient
                                    : AppTheme.premiumGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark
                                        ? AppTheme.secondaryColor
                                        : AppTheme.primaryColor).withOpacity(
                                        0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: user.photoUrl != null
                                  ? ClipOval(
                                child: Image.network(
                                  user.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        user.displayName[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                                  : Center(
                                child: Text(
                                  user.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // Bouton éditer
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () =>
                                    _showEditProfileDialog(context, ref, user),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.secondaryColor
                                        : AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? AppTheme.darkSurface
                                          : AppTheme.surfaceColor,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Nom
                        Text(
                          user.displayName,
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          user.email,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium,
                        ),

                        // Téléphone (si existe)
                        if (user.phoneNumber != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.phoneNumber!,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Badge type utilisateur
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTheme.secondaryColor : AppTheme
                                .primaryColor).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppTheme.secondaryColor : AppTheme
                                  .primaryColor,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            _getUserTypeLabel(user.userType),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.secondaryColor : AppTheme
                                  .primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔧 SECTION À REMPLACER dans profile_screen.dart
// Remplacez toute la section "⚙️ PARAMÈTRES" par celle-ci :

                // ⚙️ PARAMÈTRES
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paramètres',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Modifier le profil
                        _buildSettingTile(
                          context: context,
                          icon: Icons.person_outline_rounded,
                          title: 'Modifier le profil',
                          subtitle: 'Nom, téléphone, photo',
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () => _showEditProfileDialog(context, ref, user),
                        ),

                        const SizedBox(height: 8),

                        // Dark Mode Toggle
                        Consumer(
                          builder: (context, ref, _) {
                            final themeMode = ref.watch(themeModeProvider);
                            final isDarkMode = themeMode == ThemeMode.dark;

                            return _buildSettingTile(
                              context: context,
                              icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              title: 'Mode ${isDarkMode ? 'sombre' : 'clair'}',
                              subtitle: 'Changer l\'apparence',
                              trailing: Switch(
                                value: isDarkMode,
                                onChanged: (value) {
                                  ref.read(themeModeProvider.notifier).toggleTheme();
                                },
                                activeColor: AppTheme.secondaryColor,
                                activeTrackColor: AppTheme.secondaryColor.withOpacity(0.5),
                              ),
                            );
                          },
                        ),

                        // Favoris (SEULEMENT pour acheteurs et both - PAS pour vendeur pur)
                        if (user.userType == UserType.buyer || user.userType == UserType.both) ...[
                          const SizedBox(height: 8),
                          _buildSettingTile(
                            context: context,
                            icon: Icons.favorite_rounded,
                            title: 'Mes favoris',
                            subtitle: 'Véhicules sauvegardés',
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                            onTap: () {
                              _showFavoritesDialog(context, ref);
                            },
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Déconnexion
                        _buildSettingTile(
                          context: context,
                          icon: Icons.logout_rounded,
                          title: 'Déconnexion',
                          subtitle: 'Se déconnecter du compte',
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          isDestructive: true,
                          onTap: () {
                            _showLogoutDialog(context, ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erreur: $error')),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppTheme.accentColor.withOpacity(0.1)
                    : (isDark ? AppTheme.secondaryColor : AppTheme.primaryColor)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppTheme.accentColor
                    : (isDark ? AppTheme.secondaryColor : AppTheme
                    .primaryColor),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppTheme.accentColor : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
              Icons.person_off_rounded, size: 80, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          const Text('Non connecté'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  String _getUserTypeLabel(UserType type) {
    switch (type) {
      case UserType.buyer:
        return 'ACHETEUR';
      case UserType.seller:
        return 'VENDEUR';
      case UserType.both:
        return 'ACHETEUR & VENDEUR';
    }
  }

  // 📝 DIALOG MODIFICATION PROFIL
  void _showEditProfileDialog(BuildContext context, WidgetRef ref,
      UserModel user) {
    final nameController = TextEditingController(text: user.displayName);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isDark ? AppTheme.goldGradient : AppTheme
                        .premiumGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                      Icons.edit_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Modifier le profil'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone_rounded),
                      hintText: '+216 XX XXX XXX',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Le nom ne peut pas être vide')),
                    );
                    return;
                  }

                  // Afficher loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                  );

                  final success = await ref
                      .read(updateProfileProvider.notifier)
                      .updateProfile(
                    displayName: name != user.displayName ? name : null,
                    phoneNumber: phone.isNotEmpty && phone != user.phoneNumber
                        ? phone
                        : null,
                  );

                  if (context.mounted) {
                    Navigator.pop(context); // Fermer loading
                    Navigator.pop(context); // Fermer dialog

                    if (success) {
                      // Rafraîchir les données
                      ref.invalidate(currentUserProvider);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil mis à jour !'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erreur lors de la mise à jour'),
                          backgroundColor: AppTheme.accentColor,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  void _showFavoritesDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) =>
                Container(
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppTheme.sportGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Mes Favoris',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final favoritesAsync = ref.watch(
                                favoritesListProvider);

                            return favoritesAsync.when(
                              data: (favorites) {
                                if (favorites.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        const Icon(
                                          Icons.favorite_border_rounded,
                                          size: 80,
                                          color: AppTheme.textTertiary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Aucun favori',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Ajoutez des véhicules à vos favoris',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  controller: controller,
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 0, 20, 20),
                                  itemCount: favorites.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final vehicle = favorites[index];
                                    return VehicleCard(
                                      vehicle: vehicle,
                                      onTap: () {
                                        Navigator.pop(context);
                                        context.push('/vehicle/${vehicle.id}');
                                      },
                                    );
                                  },
                                );
                              },
                              loading: () =>
                              const Center(child: CircularProgressIndicator()),
                              error: (error, _) =>
                                  Center(child: Text('Erreur: $error')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppTheme.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Déconnexion'),
          ],
        ),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Fermer le dialog
              Navigator.pop(dialogContext);

              // Afficher un loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Déconnexion...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              // Se déconnecter
              final signOut = ref.read(signOutProvider);
              await signOut();

              // ⚠️ IMPORTANT: Invalider TOUS les providers
              ref.invalidate(currentUserProvider);
              ref.invalidate(favoritesListProvider);

              // Si vous avez d'autres providers liés à l'utilisateur, invalidez-les aussi :
              // ref.invalidate(userConversationsProvider);
              // ref.invalidate(userVehiclesProvider);
              // etc.

              // Attendre un peu pour que Firebase se mette à jour
              await Future.delayed(const Duration(milliseconds: 300));

              if (context.mounted) {
                // Fermer le loading
                Navigator.pop(context);

                // Navigation vers login
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}