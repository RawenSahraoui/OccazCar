import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerResult {
  final double latitude;
  final double longitude;

  const MapPickerResult({required this.latitude, required this.longitude});
}

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String title;

  const MapPickerScreen({
    super.key,
    this.initialPosition,
    this.title = 'Choisir une position',
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  LatLng? _picked;

  static const LatLng _defaultCenter = LatLng(36.8065, 10.1815); // Tunis

  @override
  void initState() {
    super.initState();
    _picked = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.initialPosition ?? _defaultCenter;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _picked == null
                ? null
                : () {
              Navigator.pop(
                context,
                MapPickerResult(
                  latitude: _picked!.latitude,
                  longitude: _picked!.longitude,
                ),
              );
            },
            child: Text(
              'Confirmer',
              style: TextStyle(
                color: _picked == null
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initial,
          zoom: 12,
        ),
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: (c) => _controller = c,
        onLongPress: (pos) => setState(() => _picked = pos),
        markers: {
          if (_picked != null)
            Marker(
              markerId: const MarkerId('picked'),
              position: _picked!,
            ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_picked == null) return;
          await _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(_picked!, 15),
          );
        },
        label: const Text('Centrer'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }
}