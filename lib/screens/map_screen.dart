import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/listing_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ListingProvider>().subscribeToAllListings();
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hospital': return Colors.red;
      case 'Police Station': return Colors.blue;
      case 'Library': return Colors.purple;
      case 'Utility Office': return Colors.orange;
      case 'Restaurant': return Colors.green;
      case 'Café': return Colors.brown;
      case 'Park': return Colors.lightGreen;
      case 'Tourist Attraction': return Colors.pink;
      case 'School': return Colors.yellow;
      case 'Bank': return Colors.teal;
      case 'Market': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }

  LatLngBounds? _calculateBounds(List listings) {
    if (listings.isEmpty) return null;
    
    double minLat = listings.first.latitude;
    double maxLat = listings.first.latitude;
    double minLng = listings.first.longitude;
    double maxLng = listings.first.longitude;

    for (var listing in listings) {
      if (listing.latitude < minLat) minLat = listing.latitude;
      if (listing.latitude > maxLat) maxLat = listing.latitude;
      if (listing.longitude < minLng) minLng = listing.longitude;
      if (listing.longitude > maxLng) maxLng = listing.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Services Map"),
        backgroundColor: const Color(0xFF1F3A93),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, _) {
          final listings = listingProvider.allListings;
          
          if (listings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final bounds = _calculateBounds(listings);
          final center = LatLng(
            (bounds!.south + bounds.north) / 2,
            (bounds.west + bounds.east) / 2,
          );

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              minZoom: 10,
              maxZoom: 18,
              onMapReady: () {
                Future.delayed(const Duration(milliseconds: 100), () {
                  _mapController.fitCamera(
                    CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(50),
                    ),
                  );
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.kigaliservicestrack",
              ),
              MarkerLayer(
                markers: listings.map((listing) {
                  return Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(listing.latitude, listing.longitude),
                    child: Icon(
                      Icons.location_on,
                      color: _getCategoryColor(listing.category),
                      size: 40,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}