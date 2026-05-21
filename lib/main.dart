import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  LatLng currentPosition = 
    LatLng(-6.200000, 106.816666); // Default to Jakarta

  StreamSubscription<Position>? positionStream;

  File? capturedImage;

  double? capturedLat;
  double? capturedLng;

  final LatLng targetLocation = LatLng(-6.175392, 106.827153); // Target location (Jakarta)

  @override
  void initState() {
    super.initState();
    startTracking();
  }

  Future<void> startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Start listening to location updates
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      LatLng newPos = LatLng(position.latitude, position.longitude);
      setState(() {
        currentPosition = newPos;
      });
      mapController.move(newPos, 18);
      print(position.accuracy);
    });
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;
    
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
  );

    setState(() {
      capturedImage = File(photo.path);
      capturedLat = pos.latitude;
      capturedLng = pos.longitude;
      });

    print("Foto Tersimpan");
    print("Latitude: $capturedLat, Longitude: $capturedLng");
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
        title: const Text("Lokasi Tracker"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: takePhoto,
        child: const Icon(Icons.camera_alt),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentPosition,
          initialZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.lokasi_tracker',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              //marker user
              Marker(
                width: 80,
                height: 80,
                point: currentPosition,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              //marker target
              Marker(
                width: 80,
                height: 80,
                point: targetLocation,
                child: const Icon(
                  Icons.flag,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}