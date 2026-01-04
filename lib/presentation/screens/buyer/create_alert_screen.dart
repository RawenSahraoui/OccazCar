import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/alert_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';

class CreateAlertScreen extends ConsumerStatefulWidget {
  final AlertModel? alert;

  const CreateAlertScreen({super.key, this.alert});

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minYearController = TextEditingController();
  final _maxYearController = TextEditingController();
  final _cityController = TextEditingController();

  List<String> _selectedBrands = [];
  List<String> _selectedFuelTypes = [];
  List<String> _selectedConditions = [];

  final List<String> _availableBrands = [
    'Toyota',
    'Mercedes',
    'BMW',
    'Audi',
    'Volkswagen',
    'Peugeot',
    'Renault',
    'Hyundai',
    'Kia',
    'Honda',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.alert != null) {
      _titleController.text = widget.alert!.title;
      _minPriceController.text = widget.alert!.minPrice?.toString() ?? '';
      _maxPriceController.text = widget.alert!.maxPrice?.toString() ?? '';
      _minYearController.text = widget.alert!.minYear?.toString() ?? '';
      _maxYearController.text = widget.alert!.maxYear?.toString() ?? '';
      _cityController.text = widget.alert!.city ?? '';
      _selectedBrands = widget.alert!.brands ?? [];
      _selectedFuelTypes = widget.alert!.fuelTypes ?? [];
      _selectedConditions = widget.alert!.conditions ?? [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minYearController.dispose();
    _maxYearController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.alert == null ? 'Nouvelle alerte' : 'Modifier l\'alerte'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.secondaryColor : AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vous recevrez une notification pour chaque nouveau vehicule correspondant',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Informations generales',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'alerte',
                hintText: 'Ex: Toyota Corolla Tunis',
                prefixIcon: Icon(Icons.label_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Marques',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableBrands.map((brand) {
                final isSelected = _selectedBrands.contains(brand);
                return FilterChip(
                  label: Text(brand),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedBrands.add(brand);
                      } else {
                        _selectedBrands.remove(brand);
                      }
                    });
                  },
                  selectedColor: (isDark ? AppTheme.secondaryColor : AppTheme.primaryColor).withOpacity(0.2),
                  checkmarkColor: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text(
              'Fourchette de prix (TND)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix minimum',
                      prefixIcon: Icon(Icons.payments_rounded),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix maximum',
                      prefixIcon: Icon(Icons.payments_rounded),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Annee de fabrication',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minYearController,
                    decoration: const InputDecoration(
                      labelText: 'Annee min',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxYearController,
                    decoration: const InputDecoration(
                      labelText: 'Annee max',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Localisation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ville',
                hintText: 'Ex: Tunis, Sousse, Sfax...',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Type de carburant',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['gasoline', 'diesel', 'electric', 'hybrid'].map((fuel) {
                final isSelected = _selectedFuelTypes.contains(fuel);
                return FilterChip(
                  label: Text(_getFuelLabel(fuel)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFuelTypes.add(fuel);
                      } else {
                        _selectedFuelTypes.remove(fuel);
                      }
                    });
                  },
                  selectedColor: (isDark ? AppTheme.secondaryColor : AppTheme.primaryColor).withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text(
              'Etat du vehicule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['excellent', 'good', 'fair', 'poor'].map((condition) {
                final isSelected = _selectedConditions.contains(condition);
                return FilterChip(
                  label: Text(_getConditionLabel(condition)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedConditions.add(condition);
                      } else {
                        _selectedConditions.remove(condition);
                      }
                    });
                  },
                  selectedColor: (isDark ? AppTheme.secondaryColor : AppTheme.primaryColor).withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveAlert,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.alert == null ? 'Creer l\'alerte' : 'Modifier l\'alerte'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getFuelLabel(String fuel) {
    switch (fuel) {
      case 'gasoline':
        return 'Essence';
      case 'diesel':
        return 'Diesel';
      case 'electric':
        return 'Electrique';
      case 'hybrid':
        return 'Hybride';
      default:
        return fuel;
    }
  }

  String _getConditionLabel(String condition) {
    switch (condition) {
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Bon';
      case 'fair':
        return 'Moyen';
      case 'poor':
        return 'A renover';
      default:
        return condition;
    }
  }

  Future<void> _saveAlert() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final alert = AlertModel(
      id: widget.alert?.id ?? '',
      userId: user.uid,
      title: _titleController.text.trim(),
      brands: _selectedBrands.isEmpty ? null : _selectedBrands,
      minPrice: _minPriceController.text.isEmpty ? null : double.tryParse(_minPriceController.text),
      maxPrice: _maxPriceController.text.isEmpty ? null : double.tryParse(_maxPriceController.text),
      minYear: _minYearController.text.isEmpty ? null : int.tryParse(_minYearController.text),
      maxYear: _maxYearController.text.isEmpty ? null : int.tryParse(_maxYearController.text),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      fuelTypes: _selectedFuelTypes.isEmpty ? null : _selectedFuelTypes,
      conditions: _selectedConditions.isEmpty ? null : _selectedConditions,
      isActive: widget.alert?.isActive ?? true,
      createdAt: widget.alert?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (widget.alert == null) {
      success = await ref.read(alertNotifierProvider).createAlert(alert);
    } else {
      success = await ref.read(alertNotifierProvider).updateAlert(
        widget.alert!.id,
        alert.toMap(),
      );
    }

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.alert == null ? 'Alerte creee' : 'Alerte modifiee'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'enregistrement'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }
}