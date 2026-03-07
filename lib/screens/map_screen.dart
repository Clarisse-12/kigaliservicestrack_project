import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/listing_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required targetLocation}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    // Start listening to Firestore listings
    Future.microtask(() {
      context.read<ListingProvider>().subscribeToAllListings();
    });
    _getUserLocation();
  }

  // Get user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return; // Location not enabled

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: const Color(0xFF1F3A93),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, _) {
          final listings = listingProvider.allListings;

          if (listings.isEmpty) {
            return const Center(child: Text("No listings found"));
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter:
                  _currentLocation ??
                  LatLng(listings.first.latitude, listings.first.longitude),
              initialZoom: 13,
            ),
            children: [
              // Map Tiles
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.app",
              ),

              // Listing Markers
              MarkerLayer(
                markers: listings.map((listing) {
                  return Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(listing.latitude, listing.longitude),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: listing.id,
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Current User Location Marker
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _currentLocation!,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
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
