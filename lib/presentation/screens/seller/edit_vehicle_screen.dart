import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';

class EditVehicleScreen extends ConsumerStatefulWidget {
  final VehicleModel vehicle;

  const EditVehicleScreen({
    super.key,
    required this.vehicle,
  });

  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _mileageController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;

  late VehicleStatus _status;
  late String? _selectedCity;
  late List<String> _selectedFeatures;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.vehicle.price.toInt().toString(),
    );
    _mileageController = TextEditingController(
      text: widget.vehicle.mileage.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.vehicle.description,
    );
    _addressController = TextEditingController(
      text: widget.vehicle.address ?? '',
    );
    _status = widget.vehicle.status;
    _selectedCity = widget.vehicle.city;
    _selectedFeatures = List.from(widget.vehicle.features);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _mileageController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

Future<void> _saveChanges() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final updates = {
    'price': double.parse(_priceController.text),
    'mileage': int.parse(_mileageController.text),
    'description': _descriptionController.text,
    'address': _addressController.text.isEmpty ? null : _addressController.text,
    'city': _selectedCity!,
    'status': _status.name, // Convert enum to string
    'features': _selectedFeatures,
    'updatedAt': DateTime.now().toIso8601String(),
  };

  final success = await ref.read(updateVehicleProvider.notifier).updateVehicle(
        vehicleId: widget.vehicle.id,
        updates: updates,
      );

  setState(() => _isLoading = false);

  if (success && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Annonce mise à jour !'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  } else {
    final error = ref.read(updateVehicleProvider).error;
    if (mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'annonce'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Statut
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut de l\'annonce',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<VehicleStatus>(
                      segments: const [
                        ButtonSegment(
                          value: VehicleStatus.available,
                          label: Text('Disponible'),
                          icon: Icon(Icons.check_circle),
                        ),
                        ButtonSegment(
                          value: VehicleStatus.reserved,
                          label: Text('Réservé'),
                          icon: Icon(Icons.schedule),
                        ),
                        ButtonSegment(
                          value: VehicleStatus.sold,
                          label: Text('Vendu'),
                          icon: Icon(Icons.sell),
                        ),
                      ],
                      selected: {_status},
                      onSelectionChanged: (Set<VehicleStatus> newSelection) {
                        setState(() => _status = newSelection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Prix
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Prix',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'TND',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validatePrice,
            ),
            const SizedBox(height: 16),

            // Kilométrage
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'Kilométrage',
                prefixIcon: Icon(Icons.speed),
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validateMileage,
            ),
            const SizedBox(height: 16),

            // Ville
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Ville',
                prefixIcon: Icon(Icons.location_city),
              ),
              items: AppConstants.tunisianCities.map((city) {
                return DropdownMenuItem(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCity = value);
              },
              validator: (value) =>
                  Validators.validateRequired(value, 'La ville'),
            ),
            const SizedBox(height: 16),

            // Adresse
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse (optionnel)',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: Validators.validateDescription,
            ),
            const SizedBox(height: 24),

            // Caractéristiques
            Text(
              'Caractéristiques',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.commonFeatures.map((feature) {
                final isSelected = _selectedFeatures.contains(feature);
                return FilterChip(
                  label: Text(feature),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFeatures.add(feature);
                      } else {
                        _selectedFeatures.remove(feature);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Bouton Enregistrer
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}