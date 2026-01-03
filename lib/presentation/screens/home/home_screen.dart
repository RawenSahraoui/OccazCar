// 🔧 CORRECTION COMPLÈTE DU HOME_SCREEN.dart
// Cette version gère mieux le chargement initial

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../buyer/vehicles_list_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../buyer/search_screen.dart';
import '../chat/conversations_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // Forcer le refresh du provider utilisateur
    Future.microtask(() {
      if (mounted) {
        ref.invalidate(currentUserProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      data: (user) {
        // Marquer que le chargement initial est terminé
        if (_isInitialLoad) {
          Future.microtask(() {
            if (mounted) {
              setState(() => _isInitialLoad = false);
            }
          });
        }

        if (user == null) {
          // Si pas d'utilisateur après le chargement, ne rien afficher
          // Le router va rediriger vers login automatiquement
          return const SizedBox.shrink();
        }

        final screens = _getScreensForUserType(user);
        final navItems = _getNavItemsForUserType(user);

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppTheme.primaryColor).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    navItems.length,
                        (index) => _buildNavItem(
                      navItems[index],
                      index,
                      isDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _buildLoading(isDark),
      error: (error, stack) {
        // En cas d'erreur, afficher un message et permettre de réessayer
        return _buildError(error.toString(), isDark);
      },
    );
  }

  Widget _buildNavItem(BottomNavigationBarItem item, int index, bool isDark) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (mounted) {
            setState(() => _currentIndex = index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? (isDark ? AppTheme.goldGradient : AppTheme.premiumGradient)
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: (isDark ? AppTheme.secondaryColor : AppTheme.primaryColor)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected
                      ? (item.activeIcon as Icon).icon
                      : (item.icon as Icon).icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: isDark ? AppTheme.goldGradient : AppTheme.premiumGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppTheme.secondaryColor : AppTheme.primaryColor)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chargement de votre profil...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Erreur de chargement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Réessayer en invalidant le provider
                  ref.invalidate(currentUserProvider);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getScreensForUserType(UserModel user) {
    // Utiliser des keys uniques basées sur l'userId pour forcer le rebuild
    switch (user.userType) {
      case UserType.buyer:
        return [
          VehiclesListScreen(key: ValueKey('buyer-${user.uid}')),
          SearchScreen(key: ValueKey('search-${user.uid}')),
          ConversationsListScreen(key: ValueKey('conv-${user.uid}')),
          ProfileScreen(key: ValueKey('profile-${user.uid}')),
        ];
      case UserType.seller:
        return [
          SellerDashboardScreen(key: ValueKey('seller-${user.uid}')),
          SearchScreen(key: ValueKey('search-${user.uid}')),
          ConversationsListScreen(key: ValueKey('conv-${user.uid}')),
          ProfileScreen(key: ValueKey('profile-${user.uid}')),
        ];
      case UserType.both:
        return [
          VehiclesListScreen(key: ValueKey('buyer-${user.uid}')),
          SellerDashboardScreen(key: ValueKey('seller-${user.uid}')),
          SearchScreen(key: ValueKey('search-${user.uid}')),
          ConversationsListScreen(key: ValueKey('conv-${user.uid}')),
          ProfileScreen(key: ValueKey('profile-${user.uid}')),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavItemsForUserType(UserModel user) {
    switch (user.userType) {
      case UserType.buyer:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ];
      case UserType.seller:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Annonces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ];
      case UserType.both:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Vendre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ];
    }
  }
}