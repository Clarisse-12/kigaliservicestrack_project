import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing_model.dart';
import '../providers/listing_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ListingProvider>().subscribeToAllListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: const Color(0xFF1F3A93),
        elevation: 0,
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, _) {
          final listings = listingProvider.allListings;

          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No listings to display',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Showing ${listings.length} services',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return _buildListingMapCard(listing, context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListingMapCard(Listing listing, BuildContext context) {
    final categoryColors = {
      'Hospital': Colors.red[100],
      'Police Station': Colors.blue[100],
      'Library': Colors.green[100],
      'Restaurant': Colors.orange[100],
      'Park': Colors.teal[100],
      'Tourist Attraction': Colors.purple[100],
    };

    final categoryIcons = {
      'Hospital': Icons.local_hospital,
      'Police Station': Icons.local_police,
      'Library': Icons.library_books,
      'Utility Office': Icons.business,
      'Restaurant': Icons.restaurant,
      'Café': Icons.coffee,
      'Park': Icons.park,
      'Tourist Attraction': Icons.language,
      'School': Icons.school,
      'Bank': Icons.account_balance,
      'Market': Icons.shopping_bag,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: categoryColors[listing.category] ?? Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                categoryIcons[listing.category] ?? Icons.location_on,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: listing.id,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.latitude.toStringAsFixed(2)}, ${listing.longitude.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _launchNavigation(
                  listing.latitude,
                  listing.longitude,
                  listing.name,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3A93).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.directions,
                  color: Color(0xFF1F3A93),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchNavigation(double latitude, double longitude, String name) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open Google Maps at: $latitude, $longitude'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
