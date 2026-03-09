import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';

class ListingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Listing> _allListings = [];
  List<Listing> _userListings = [];
  List<Listing> _filteredListings = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Listing> get allListings => _allListings;
  List<Listing> get userListings => _userListings;
  List<Listing> get filteredListings =>
      _filteredListings.isEmpty ? _allListings : _filteredListings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void subscribeToAllListings() {
    _firestoreService.getAllListings().listen(
      (listings) {
        _allListings = listings;
        _applyFilters();
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void subscribeToUserListings(String uid) {
    _firestoreService
        .getUserListings(uid)
        .listen(
          (listings) {
            _userListings = listings;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final listing = Listing(
        id: '',
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: createdBy,
        timestamp: DateTime.now(),
      );

      await _firestoreService.createListing(listing);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateListing({
    required String id,
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final listing = Listing(
        id: id,
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: createdBy,
        timestamp: DateTime.now(),
      );

      await _firestoreService.updateListing(id: id, listing: listing);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteListing(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteListing(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Listing?> getListing(String id) async {
    try {
      return await _firestoreService.getListing(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<void> searchListings(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredListings = [];
    } else {
      _isLoading = true;
      notifyListeners();

      try {
        _firestoreService
            .searchListings(query)
            .listen(
              (listings) {
                _filteredListings = listings;
                _isLoading = false;
                notifyListeners();
              },
              onError: (e) {
                _error = e.toString();
                _isLoading = false;
                notifyListeners();
              },
            );
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
      }
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredListings = _allListings;

    if (_selectedCategory != 'All') {
      _filteredListings = _filteredListings
          .where((listing) => listing.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      _filteredListings = _filteredListings
          .where(
            (listing) =>
                listing.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                listing.address.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  Future<List<Listing>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      return await _firestoreService.getNearbyListings(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
      );
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _filteredListings = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
