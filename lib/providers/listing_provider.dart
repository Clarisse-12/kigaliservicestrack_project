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

  // Getters
  List<Listing> get allListings => _allListings;
  List<Listing> get userListings => _userListings;
  List<Listing> get filteredListings =>
      _filteredListings.isEmpty ? _allListings : _filteredListings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Subscribe to all listings
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

  // Subscribe to user listings
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

  // Create listing
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

  // Update listing
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

  // Delete listing
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

  // Get single listing
  Future<Listing?> getListing(String id) async {
    try {
      return await _firestoreService.getListing(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Search listings
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

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredListings = _allListings;

    // Filter by category
    if (_selectedCategory != 'All') {
      _filteredListings = _filteredListings
          .where((listing) => listing.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
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

  // Get nearby listings
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

  // Clear filters
  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _filteredListings = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
