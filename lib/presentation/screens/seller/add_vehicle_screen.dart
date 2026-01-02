import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _colorController = TextEditingController();
  final _engineSizeController = TextEditingController();
  final _horsePowerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedBrand;
  String? _selectedCity;
  FuelType _fuelType = FuelType.gasoline;
  TransmissionType _transmission = TransmissionType.manual;
  VehicleCondition _condition = VehicleCondition.good;
  int _numberOfOwners = 1;
  bool _hasAccidents = false;
  final List<String> _selectedFeatures = [];
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _colorController.dispose();
    _engineSizeController.dispose();
    _horsePowerController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images);
        if (_images.length > AppConstants.maxVehicleImages) {
          _images.removeRange(
            AppConstants.maxVehicleImages,
            _images.length,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Maximum ${AppConstants.maxVehicleImages} images',
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une ville'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await ref.read(currentUserProvider.future);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non connecté')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final vehicle = VehicleModel(
      id: '',
      sellerId: user.uid,
      sellerName: user.displayName,
      brand: _selectedBrand ?? _brandController.text,
      model: _modelController.text,
      year: int.parse(_yearController.text),
      mileage: int.parse(_mileageController.text),
      price: double.parse(_priceController.text),
      fuelType: _fuelType,
      transmission: _transmission,
      engineSize: int.tryParse(_engineSizeController.text),
      horsePower: int.tryParse(_horsePowerController.text),
      color: _colorController.text.isEmpty ? null : _colorController.text,
      condition: _condition,
      status: VehicleStatus.available,
      description: _descriptionController.text,
      features: _selectedFeatures,
      imageUrls: [],
      city: _selectedCity!,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      numberOfOwners: _numberOfOwners,
      hasAccidents: _hasAccidents,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final vehicleId = await ref.read(createVehicleProvider.notifier).createVehicle(
          vehicle: vehicle,
          images: _images,
        );

    setState(() => _isLoading = false);

    if (vehicleId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce publiée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final error = ref.read(createVehicleProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Erreur lors de la publication'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier une annonce'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photos
            Text(
              'Photos du véhicule *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildImagesSection(),
            const SizedBox(height: 24),

            // Informations de base
            Text(
              'Informations de base',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Marque
            DropdownButtonFormField<String>(
              value: _selectedBrand,
              decoration: const InputDecoration(
                labelText: 'Marque *',
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: AppConstants.carBrands.map((brand) {
                return DropdownMenuItem(value: brand, child: Text(brand));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedBrand = value);
              },
              validator: (value) =>
                  Validators.validateRequired(value, 'La marque'),
            ),
            const SizedBox(height: 16),

            // Modèle
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Modèle *',
                prefixIcon: Icon(Icons.car_rental),
              ),
              validator: (value) =>
                  Validators.validateRequired(value, 'Le modèle'),
            ),
            const SizedBox(height: 16),

            // Année et Kilométrage
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Année *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateYear,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Kilométrage *',
                      prefixIcon: Icon(Icons.speed),
                      suffixText: 'km',
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateMileage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Prix
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Prix *',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'TND',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validatePrice,
            ),
            const SizedBox(height: 24),

            // Détails techniques
            Text(
              'Détails techniques',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Carburant
            DropdownButtonFormField<FuelType>(
              value: _fuelType,
              decoration: const InputDecoration(
                labelText: 'Type de carburant *',
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              items: FuelType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getFuelTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _fuelType = value);
              },
            ),
            const SizedBox(height: 16),

            // Transmission
            DropdownButtonFormField<TransmissionType>(
              value: _transmission,
              decoration: const InputDecoration(
                labelText: 'Transmission *',
                prefixIcon: Icon(Icons.settings),
              ),
              items: TransmissionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTransmissionLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _transmission = value);
              },
            ),
            const SizedBox(height: 16),

            // Cylindrée et Puissance
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _engineSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Cylindrée',
                      prefixIcon: Icon(Icons.build),
                      suffixText: 'cc',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _horsePowerController,
                    decoration: const InputDecoration(
                      labelText: 'Puissance',
                      prefixIcon: Icon(Icons.speed),
                      suffixText: 'ch',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Couleur
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Couleur',
                prefixIcon: Icon(Icons.palette),
              ),
            ),
            const SizedBox(height: 24),

            // État et condition
            Text(
              'État du véhicule',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<VehicleCondition>(
              value: _condition,
              decoration: const InputDecoration(
                labelText: 'État général *',
                prefixIcon: Icon(Icons.check_circle),
              ),
              items: VehicleCondition.values.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(_getConditionLabel(condition)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _condition = value);
              },
            ),
            const SizedBox(height: 16),

            // Nombre de propriétaires
            DropdownButtonFormField<int>(
              value: _numberOfOwners,
              decoration: const InputDecoration(
                labelText: 'Nombre de propriétaires',
                prefixIcon: Icon(Icons.person),
              ),
              items: List.generate(5, (index) => index + 1).map((num) {
                return DropdownMenuItem(
                  value: num,
                  child: Text(num == 1 ? '1er propriétaire' : '$num propriétaires'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _numberOfOwners = value);
              },
            ),
            const SizedBox(height: 16),

            // Accidents
            SwitchListTile(
              title: const Text('A eu des accidents'),
              value: _hasAccidents,
              onChanged: (value) {
                setState(() => _hasAccidents = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description du véhicule *',
                alignLabelWithHint: true,
                hintText: 'Décrivez votre véhicule en détail...',
              ),
              maxLines: 5,
              validator: Validators.validateDescription,
            ),
            const SizedBox(height: 24),

            // Caractéristiques
            Text(
              'Caractéristiques',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 24),

            // Localisation
            Text(
              'Localisation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Ville *',
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

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse (optionnel)',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 32),

            // Bouton Publier
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
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
                  : const Text('Publier l\'annonce'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      children: [
        if (_images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return _buildAddImageButton();
                }
                return _buildImagePreview(_images[index], index);
              },
            ),
          )
        else
          _buildAddImageButton(),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImages,
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              'Ajouter',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile image, int index) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image.path,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() => _images.removeAt(index));
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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