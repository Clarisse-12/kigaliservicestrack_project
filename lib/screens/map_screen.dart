import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/listing_provider.dart';

class MapScreen extends StatefulWidget {
  final LatLng targetLocation;

  const MapScreen({Key? key, required this.targetLocation}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ListingProvider>().subscribeToAllListings();
    });

    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final userLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocation = userLocation;

      // Create route line
      _routePoints = [
        userLocation,
        widget.targetLocation,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Directions"),
        backgroundColor: const Color(0xFF1F3A93),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, _) {
          final listings = listingProvider.allListings;

          return FlutterMap(
            options: MapOptions(
              initialCenter: _currentLocation ?? widget.targetLocation,
              initialZoom: 14,
            ),
            children: [

              /// MAP TILES
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.kigaliservicestrack",
              ),

              /// ROUTE LINE
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4,
                    color: Colors.blue,
                  )
                ],
              ),

              /// LISTING MARKERS
              MarkerLayer(
                markers: listings.map((listing) {
                  return Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(listing.latitude, listing.longitude),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                }).toList(),
              ),

              // /// TARGET MARKER
              // MarkerLayer(
              //   markers: [
              //     Marker(
              //       width: 45,
              //       height: 45,
              //       point: widget.targetLocation,
              //       child: const Icon(
              //         Icons.flag,
              //         color: Colors.red,
              //         size: 45,
              //       ),
              //     ),
              //   ],
              // ),

              /// USER MARKER
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 45,
                      height: 45,
                      point: _currentLocation!,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 45,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}