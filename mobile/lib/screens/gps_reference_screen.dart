import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_theme.dart';

class GpsReferenceScreen extends StatefulWidget {
  final double targetLat;
  final double targetLng;

  const GpsReferenceScreen({
    super.key,
    required this.targetLat,
    required this.targetLng,
  });

  @override
  State<GpsReferenceScreen> createState() => _GpsReferenceScreenState();
}

class _GpsReferenceScreenState extends State<GpsReferenceScreen> {
  final MapController mapController = MapController();
  LatLng? currentPosition;
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    startTracking();
  }

  Future<void> startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi dinonaktifkan.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position initialPos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    if (mounted) {
      setState(() {
        currentPosition = LatLng(initialPos.latitude, initialPos.longitude);
      });
      // Tidak perlu mapController.move karena initialCenter sudah memakai currentPosition.
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      if (mounted) {
        LatLng newPos = LatLng(position.latitude, position.longitude);
        setState(() {
          currentPosition = newPos;
        });
      }
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Referensi GPS",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentPosition!,
                initialZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.geosurvey.pbb',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    // Target Location (Bangunan)
                    Marker(
                      width: 80,
                      height: 80,
                      point: LatLng(widget.targetLat, widget.targetLng),
                      child: const Column(
                        children: [
                          Icon(Icons.flag, color: Colors.blue, size: 40),
                          Text('Target', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, backgroundColor: Colors.white70)),
                        ],
                      ),
                    ),
                    // Current Position (Enumerator)
                    Marker(
                      width: 80,
                      height: 80,
                      point: currentPosition!,
                      child: const Column(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 40),
                          Text('Anda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, backgroundColor: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
