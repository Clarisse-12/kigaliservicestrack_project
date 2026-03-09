import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing_model.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';

// Screen for adding a new listing with form fields and validation
class AddListingScreen extends StatefulWidget {
  const AddListingScreen({Key? key}) : super(key: key);

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

// State class for AddListingScreen, managing form controllers and submission logic
class _AddListingScreenState extends State<AddListingScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  String _selectedCategory = listingCategories.first;

// Initialize text controllers for form fields
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
    _descriptionController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

// Dispose of text controllers to free resources
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

// Build method to render the UI of the AddListingScreen with form fields and submission button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Add New Listing'),
        backgroundColor: const Color(0xFF1F3A93),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Name Field
              _buildTextField(
                label: 'Service Name',
                controller: _nameController,
                hint: 'Enter service or place name',
                icon: Icons.business,
              ),
              const SizedBox(height: 20),
              // Category Dropdown
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              // Address Field
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                hint: 'Enter full address',
                icon: Icons.location_on,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              // Contact Number Field
              _buildTextField(
                label: 'Contact Number',
                controller: _contactController,
                hint: 'Enter phone number',
                icon: Icons.phone,
              ),
              const SizedBox(height: 20),
              // Description Field
              _buildTextField(
                label: 'Description',
                controller: _descriptionController,
                hint: 'Enter detailed description',
                icon: Icons.description,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              // Geographic Coordinates Section
              Text(
                'Geographic Coordinates',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F3A93),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Latitude',
                      controller: _latitudeController,
                      hint: '-1.9536',
                      icon: Icons.public,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Longitude',
                      controller: _longitudeController,
                      hint: '29.8739',
                      icon: Icons.public,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Error Message Display
              Consumer<ListingProvider>(
                builder: (context, listingProvider, _) {
                  if (listingProvider.error != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        listingProvider.error!,
                        style: TextStyle(color: Colors.red[800], fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Add Listing Button with loading state
              Consumer2<AuthProvider, ListingProvider>(
                builder: (context, authProvider, listingProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: listingProvider.isLoading
                          ? null
                          : () {
                              _addListing(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 184, 190, 209),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: listingProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromARGB(255, 185, 24, 24),
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Add Listing',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

// Helper method to build styled text fields for the form
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F3A93),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1F3A93)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1F3A93), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

// Helper method to build a styled dropdown for selecting listing categories
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F3A93),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            onChanged: (String? value) {
              setState(() {
                _selectedCategory = value ?? listingCategories.first;
              });
            },
            items: listingCategories.map<DropdownMenuItem<String>>((
              String value,
            ) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ),
      ],
    );
  }

// Method to handle form submission, including validation and interaction with providers
  void _addListing(BuildContext context) {
    if (!_validateInputs()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final listingProvider = context.read<ListingProvider>();

    listingProvider.createListing(
      name: _nameController.text,
      category: _selectedCategory,
      address: _addressController.text,
      contactNumber: _contactController.text,
      description: _descriptionController.text,
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
      createdBy: authProvider.currentUser!.uid,
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      double.parse(_latitudeController.text);
      double.parse(_longitudeController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid coordinates'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }
}
