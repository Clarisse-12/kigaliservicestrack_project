import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DirectionsMapScreen extends StatefulWidget {
  final LatLng targetLocation;
  final String serviceName;

  const DirectionsMapScreen({
    Key? key,
    required this.targetLocation,
    required this.serviceName,
  }) : super(key: key);

  @override
  State<DirectionsMapScreen> createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen> {
  LatLng? _currentLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
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

    _fitBounds();
  }

  void _fitBounds() {
    if (_currentLocation == null) return;

    final bounds = LatLngBounds(
      LatLng(
        _currentLocation!.latitude < widget.targetLocation.latitude
            ? _currentLocation!.latitude
            : widget.targetLocation.latitude,
        _currentLocation!.longitude < widget.targetLocation.longitude
            ? _currentLocation!.longitude
            : widget.targetLocation.longitude,
      ),
      LatLng(
        _currentLocation!.latitude > widget.targetLocation.latitude
            ? _currentLocation!.latitude
            : widget.targetLocation.latitude,
        _currentLocation!.longitude > widget.targetLocation.longitude
            ? _currentLocation!.longitude
            : widget.targetLocation.longitude,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(80),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Directions to ${widget.serviceName}"),
        backgroundColor: const Color(0xFF1F3A93),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.targetLocation,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.kigaliservicestrack",
          ),
          if (_currentLocation != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [_currentLocation!, widget.targetLocation],
                  color: const Color(0xFF1F3A93),
                  strokeWidth: 4,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: widget.targetLocation,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              if (_currentLocation != null)
                Marker(
                  point: _currentLocation!,
                  width: 45,
                  height: 45,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 45,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
