import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/ai_description_provider.dart';
import '../../providers/damage_report_provider.dart';
import '../../../data/services/ai_damage_report_service.dart';
import '../../../data/models/damage_report_models.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/ai_image_enhancement_button.dart';

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
      // 🔥 RÉINITIALISER LE RAPPORT DE DOMMAGES APRÈS PUBLICATION
      ref.read(damageReportProvider.notifier).reset();
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
              initialValue: _selectedBrand,
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
              initialValue: _fuelType,
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
              initialValue: _transmission,
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
              initialValue: _condition,
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
              initialValue: _numberOfOwners,
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

            // Accidents - 🔥 MODIFIÉ POUR SYNCHRONISER AVEC LE DAMAGE REPORT
            SwitchListTile(
              title: const Text('A eu des accidents'),
              value: _hasAccidents,
              onChanged: (value) {
                setState(() => _hasAccidents = value);
                // Synchroniser avec le damage report provider
                ref.read(damageReportProvider.notifier).setAccidentHistory(value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // 🔥🔥🔥 SECTION AI DAMAGE REPORT - NOUVELLE SECTION 🔥🔥🔥
            _buildAiDamageReportSection(),
            const SizedBox(height: 24),

            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Consumer(
              builder: (context, ref, _) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Générer avec l\'IA'),
                    onPressed: () {
                      final aiService = ref.read(aiDescriptionServiceProvider);

                      final generatedDescription = aiService.generateDescription(
                        brand: _selectedBrand ?? 'Véhicule',
                        model: _modelController.text,
                        year: int.tryParse(_yearController.text) ?? DateTime.now().year,
                        mileage: int.tryParse(_mileageController.text) ?? 0,
                        fuel: _getFuelTypeLabel(_fuelType),
                        gearbox: _getTransmissionLabel(_transmission),
                        condition: _getConditionLabel(_condition),
                        city: _selectedCity ?? 'Tunisie',
                      );

                      _descriptionController.text = generatedDescription;
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

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
              initialValue: _selectedCity,
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

  // 🔥🔥🔥 NOUVELLE MÉTHODE - SECTION AI DAMAGE REPORT 🔥🔥🔥
  Widget _buildAiDamageReportSection() {
    return Consumer(
      builder: (context, ref, _) {
        final damageState = ref.watch(damageReportProvider);
        final totalDamages = ref.watch(totalDamagesProvider);
        final canGenerate = ref.watch(canGenerateReportProvider);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rapport de dommages IA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Transparence = Confiance des acheteurs',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (totalDamages > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalDamages dommage${totalDamages > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Déclarez les dommages pour générer un rapport professionnel IA qui renforce la confiance des acheteurs.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Aperçu du rapport si généré
                if (damageState.generatedReport != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Rapport généré',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildReportMetrics(damageState.generatedReport!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openDamageReportDialog(),
                        icon: const Icon(Icons.edit_note),
                        label: Text(
                          totalDamages > 0
                              ? 'Modifier dommages'
                              : 'Ajouter dommages',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canGenerate && !damageState.isGenerating
                            ? () {
                                ref
                                    .read(damageReportProvider.notifier)
                                    .generateReport();
                              }
                            : null,
                        icon: damageState.isGenerating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.analytics),
                        label: Text(
                          damageState.generatedReport != null
                              ? 'Régénérer'
                              : 'Générer IA',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bouton pour insérer le rapport
                if (damageState.generatedReport != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _insertReportIntoDescription(),
                      icon: const Icon(Icons.note_add),
                      label: const Text('Insérer le rapport dans la description'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green.shade300),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔥 NOUVELLE MÉTHODE - Afficher les métriques du rapport
  Widget _buildReportMetrics(AiDamageReport report) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricItem(
          'Note',
          report.conditionGrade,
          _getGradeColor(report.conditionGrade),
        ),
        Container(width: 1, height: 30, color: Colors.grey[300]),
        _buildMetricItem(
          'Impact',
          '-${report.estimatedValueImpact.toStringAsFixed(1)}%',
          Colors.orange,
        ),
        Container(width: 1, height: 30, color: Colors.grey[300]),
        _buildMetricItem(
          'Risque',
          report.riskLevel,
          _getRiskColor(report.riskLevel),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'very low':
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.deepOrange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 🔥 NOUVELLE MÉTHODE - Ouvrir le dialogue d'ajout de dommages
  void _openDamageReportDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _DamageReportDialog(),
    );
  }

  // 🔥 NOUVELLE MÉTHODE - Insérer le rapport dans la description
  void _insertReportIntoDescription() {
    final report = ref.read(damageReportProvider).generatedReport;
    if (report == null) return;

    final service = ref.read(aiDamageServiceProvider);
    final reportText = service.formatReportAsText(report);

    // Insérer à la fin de la description existante
    final currentDesc = _descriptionController.text;
    final separator = currentDesc.isNotEmpty ? '\n\n' : '';
    _descriptionController.text = '$currentDesc$separator$reportText';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Rapport IA inséré dans la description'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
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

      if (_images.isNotEmpty)
        AiImageEnhancementButton(
          images: _images,
          onImagesEnhanced: (enhancedImages) {
            setState(() {
              _images
                ..clear()
                ..addAll(enhancedImages);
            });
          },
        ),
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

// 🔥🔥🔥 NOUVEAU WIDGET - DIALOGUE DE GESTION DES DOMMAGES 🔥🔥🔥
class _DamageReportDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DamageReportDialog> createState() => _DamageReportDialogState();
}

class _DamageReportDialogState extends ConsumerState<_DamageReportDialog> {
  DamageZone _zone = DamageZone.front;
  DamageType _type = DamageType.scratch;
  DamageSeverity _severity = DamageSeverity.light;
  bool _isRepaired = false;

  @override
  Widget build(BuildContext context) {
    final damageState = ref.watch(damageReportProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.car_crash, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Gestion des dommages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Liste des dommages existants
            Expanded(
              child: damageState.damages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun dommage déclaré',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: damageState.damages.length,
                      itemBuilder: (ctx, idx) {
                        final damage = damageState.damages[idx];
                        return _buildDamageCard(damage);
                      },
                    ),
            ),

            // Formulaire d'ajout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ajouter un dommage',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<DamageZone>(
                          value: _zone,
                          decoration: const InputDecoration(
                            labelText: 'Zone',
                            isDense: true,
                          ),
                          items: DamageZone.values
                              .map((z) => DropdownMenuItem(
                                    value: z,
                                    child: Text(z.label, style: const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _zone = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<DamageType>(
                          value: _type,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            isDense: true,
                          ),
                          items: DamageType.values
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.label, style: const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _type = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<DamageSeverity>(
                          value: _severity,
                          decoration: const InputDecoration(
                            labelText: 'Gravité',
                            isDense: true,
                          ),
                          items: DamageSeverity.values
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.label, style: const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _severity = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Réparé', style: TextStyle(fontSize: 13)),
                          value: _isRepaired,
                          onChanged: (val) => setState(() => _isRepaired = val),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final damage = DamageEntry(
                          id: const Uuid().v4(),
                          zone: _zone,
                          type: _type,
                          severity: _severity,
                          isRepaired: _isRepaired,
                          reportedAt: DateTime.now(),
                        );
                        ref.read(damageReportProvider.notifier).addDamage(damage);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Dommage ajouté'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDamageCard(DamageEntry damage) {
    final severityColor = _getSeverityColor(damage.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: severityColor,
          child: Icon(
            _getSeverityIcon(damage.severity),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          '${damage.zone.label} - ${damage.type.label}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${damage.severity.label}${damage.isRepaired ? ' (Réparé)' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () {
            ref.read(damageReportProvider.notifier).removeDamage(damage.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Dommage supprimé'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getSeverityColor(DamageSeverity severity) {
    switch (severity) {
      case DamageSeverity.light:
        return Colors.green;
      case DamageSeverity.medium:
        return Colors.orange;
      case DamageSeverity.severe:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon(DamageSeverity severity) {
    switch (severity) {
      case DamageSeverity.light:
        return Icons.info_outline;
      case DamageSeverity.medium:
        return Icons.warning_amber;
      case DamageSeverity.severe:
        return Icons.error;
    }
  }
}