import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/vehicle_card.dart';
import 'vehicle_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedBrand;
  String? _selectedCity;
  double? _minPrice;
  double? _maxPrice;
  int? _minYear;
  int? _maxYear;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedBrand = null;
      _selectedCity = null;
      _minPrice = null;
      _maxPrice = null;
      _minYear = null;
      _maxYear = null;
    });
  }

  void _applyFilters() {
    Navigator.pop(context);
    setState(() {}); // Trigger rebuild with new filters
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtres',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() => _clearFilters());
                          setState(() {});
                        },
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Marque
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    decoration: const InputDecoration(
                      labelText: 'Marque',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Toutes les marques'),
                      ),
                      ...AppConstants.carBrands.map((brand) {
                        return DropdownMenuItem(
                          value: brand,
                          child: Text(brand),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setModalState(() => _selectedBrand = value);
                      setState(() => _selectedBrand = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ville
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Toutes les villes'),
                      ),
                      ...AppConstants.tunisianCities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setModalState(() => _selectedCity = value);
                      setState(() => _selectedCity = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Prix
                  Text(
                    'Prix (TND)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _minPrice?.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Min',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final price = double.tryParse(value);
                            setModalState(() => _minPrice = price);
                            setState(() => _minPrice = price);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _maxPrice?.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Max',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final price = double.tryParse(value);
                            setModalState(() => _maxPrice = price);
                            setState(() => _maxPrice = price);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Année
                  Text(
                    'Année',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _minYear?.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Min',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final year = int.tryParse(value);
                            setModalState(() => _minYear = year);
                            setState(() => _minYear = year);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _maxYear?.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Max',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final year = int.tryParse(value);
                            setModalState(() => _maxYear = year);
                            setState(() => _maxYear = year);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bouton Appliquer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Appliquer les filtres'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

@override
Widget build(BuildContext context) {
  // NE PAS passer les filtres à vehiclesProvider, juste le status
  final allVehicles = ref.watch(
    vehiclesProvider(
      VehicleFilters(
        status: VehicleStatus.available,
        // NE PAS passer brand, city, etc. ici
      ),
    ),
  );

  return Scaffold(
    appBar: AppBar(
      title: const Text('Rechercher'),
    ),
    body: Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une marque, modèle...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Chips de filtres actifs
        if (_selectedBrand != null ||
            _selectedCity != null ||
            _minPrice != null ||
            _maxPrice != null ||
            _minYear != null ||
            _maxYear != null)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (_selectedBrand != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(_selectedBrand!),
                      onDeleted: () {
                        setState(() => _selectedBrand = null);
                      },
                    ),
                  ),
                if (_selectedCity != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(_selectedCity!),
                      onDeleted: () {
                        setState(() => _selectedCity = null);
                      },
                    ),
                  ),
                if (_minPrice != null || _maxPrice != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        '${_minPrice?.toInt() ?? 0} - ${_maxPrice?.toInt() ?? '∞'} TND',
                      ),
                      onDeleted: () {
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                        });
                      },
                    ),
                  ),
                if (_minYear != null || _maxYear != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        '${_minYear ?? ''} - ${_maxYear ?? ''}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _minYear = null;
                          _maxYear = null;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

        // Résultats
        Expanded(
          child: _buildFilteredResults(allVehicles),
        ),
      ],
    ),
  );
}

Widget _buildFilteredResults(AsyncValue<List<VehicleModel>> allVehicles) {
  return allVehicles.when(
    data: (vehicles) {
      print('🔍 DEBUG: ${vehicles.length} véhicules reçus de Firestore'); // DEBUG
      
      // Appliquer TOUS les filtres en mémoire
      var filtered = vehicles.where((vehicle) {
        // Filtre par marque
        if (_selectedBrand != null && vehicle.brand != _selectedBrand) {
          return false;
        }
        
        // Filtre par ville
        if (_selectedCity != null && vehicle.city != _selectedCity) {
          return false;
        }
        
        // Filtre par année
        if (_minYear != null && vehicle.year < _minYear!) {
          return false;
        }
        if (_maxYear != null && vehicle.year > _maxYear!) {
          return false;
        }
        
        // Filtre par prix
        if (_minPrice != null && vehicle.price < _minPrice!) {
          return false;
        }
        if (_maxPrice != null && vehicle.price > _maxPrice!) {
          return false;
        }
        
        // Filtre par recherche textuelle
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          if (!vehicle.brand.toLowerCase().contains(searchLower) &&
              !vehicle.model.toLowerCase().contains(searchLower) &&
              !vehicle.description.toLowerCase().contains(searchLower)) {
            return false;
          }
        }
        
        return true;
      }).toList();

      print('✅ DEBUG: ${filtered.length} véhicules après filtrage'); // DEBUG

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Aucun véhicule trouvé',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Total véhicules disponibles: ${vehicles.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedBrand != null ||
                  _selectedCity != null ||
                  _minPrice != null ||
                  _maxPrice != null ||
                  _minYear != null ||
                  _maxYear != null ||
                  _searchQuery.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    _clearFilters();
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: const Text('Réinitialiser la recherche'),
                ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final vehicle = filtered[index];
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
    loading: () {
      print('⏳ DEBUG: Chargement en cours...'); // DEBUG
      return const Center(child: CircularProgressIndicator());
    },
    error: (error, stack) {
      print('❌ DEBUG ERROR: $error'); // DEBUG
      print('❌ STACK: $stack'); // DEBUG
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  vehiclesProvider(
                    VehicleFilters(status: VehicleStatus.available),
                  ),
                );
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    },
  );
}
}