import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createListing(Listing listing) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('listings')
          .add(listing.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create listing: $e';
    }
  }

  Stream<List<Listing>> getAllListings() {
    try {
      return _firestore
          .collection('listings')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Listing.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw 'Failed to fetch listings: $e';
    }
  }

  Stream<List<Listing>> getUserListings(String uid) {
    try {
      return _firestore
          .collection('listings')
          .where('createdBy', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Listing.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw 'Failed to fetch user listings: $e';
    }
  }

  Stream<List<Listing>> getListingsByCategory(String category) {
    try {
      return _firestore
          .collection('listings')
          .where('category', isEqualTo: category)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Listing.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw 'Failed to fetch listings by category: $e';
    }
  }

  Stream<List<Listing>> searchListings(String query) {
    try {
      return _firestore.collection('listings').snapshots().map((snapshot) {
        final listings = snapshot.docs
            .map((doc) => Listing.fromFirestore(doc))
            .toList();

        return listings
            .where(
              (listing) =>
                  listing.name.toLowerCase().contains(query.toLowerCase()) ||
                  listing.address.toLowerCase().contains(query.toLowerCase()) ||
                  listing.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      });
    } catch (e) {
      throw 'Failed to search listings: $e';
    }
  }

  
  Future<Listing> getListing(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('listings')
          .doc(id)
          .get();
      if (doc.exists) {
        return Listing.fromFirestore(doc);
      }
      throw 'Listing not found';
    } catch (e) {
      throw 'Failed to fetch listing: $e';
    }
  }

  Future<void> updateListing({
    required String id,
    required Listing listing,
  }) async {
    try {
      await _firestore.collection('listings').doc(id).update(listing.toJson());
    } catch (e) {
      throw 'Failed to update listing: $e';
    }
  }

  
  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection('listings').doc(id).delete();
    } catch (e) {
      throw 'Failed to delete listing: $e';
    }
  }

  
  Future<List<Listing>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      final listings = await _firestore.collection('listings').get();

      List<Listing> nearbyListings = [];

      for (var doc in listings.docs) {
        final listing = Listing.fromFirestore(doc);
        final distance = _calculateDistance(
          latitude,
          longitude,
          listing.latitude,
          listing.longitude,
        );

        if (distance <= radiusInKm) {
          nearbyListings.add(listing);
        }
      }

      return nearbyListings;
    } catch (e) {
      throw 'Failed to fetch nearby listings: $e';
    }
  }

  
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371; 

    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);

    final double a =
        (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_toRad(lat1)) *
            Math.cos(_toRad(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2));

    final double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    final double distance = R * c;

    return distance;
  }

  double _toRad(double degree) {
    return degree * (3.14159265359 / 180);
  }
}


class Math {
  static double sin(double x) => _sin(x);
  static double cos(double x) => _cos(x);
  static double atan2(double y, double x) => _atan2(y, x);
  static double sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0 || x == 1) return x;

    double guess = x / 2;
    double previous;
    do {
      previous = guess;
      guess = (guess + x / guess) / 2;
    } while ((guess - previous).abs() > 1e-10);

    return guess;
  }

  static double _sin(double x) {
    
    x = x % (2 * 3.14159265359);
    if (x > 3.14159265359) x -= 2 * 3.14159265359;
    if (x < -3.14159265359) x += 2 * 3.14159265359;

    
    double result = 0;
    double term = x;
    for (int i = 1; i < 20; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }
    return result;
  }

  static double _cos(double x) {
    x = x % (2 * 3.14159265359);
    double result = 1;
    double term = 1;
    for (int i = 1; i < 20; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _atan2(double y, double x) {
    if (x > 0) {
      return _atan(y / x);
    } else if (x < 0 && y >= 0) {
      return _atan(y / x) + 3.14159265359;
    } else if (x < 0 && y < 0) {
      return _atan(y / x) - 3.14159265359;
    } else if (x == 0 && y > 0) {
      return 3.14159265359 / 2;
    } else if (x == 0 && y < 0) {
      return -3.14159265359 / 2;
    }
    return 0;
  }

  static double _atan(double x) {
    double result = 0;
    double xSquared = x * x;
    double numerator = x;
    double denominator = 1;

    for (int n = 0; n < 20; n++) {
      result += numerator / denominator;
      numerator *= -xSquared * (2 * n + 1);
      denominator += 2;
    }

    return result;
  }
}
