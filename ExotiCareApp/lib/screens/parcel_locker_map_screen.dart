import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/parcel_locker.dart';

class ParcelLockerMapScreen extends StatefulWidget {
  final List<ParcelLocker> parcelLockers;

  const ParcelLockerMapScreen({
    super.key,
    required this.parcelLockers,
  });

  @override
  State<ParcelLockerMapScreen> createState() =>
      _ParcelLockerMapScreenState();
}

class _ParcelLockerMapScreenState
    extends State<ParcelLockerMapScreen> {

  final TextEditingController _searchController =
    TextEditingController();

  List<ParcelLocker> _filteredLockers = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _filteredLockers = List.from(widget.parcelLockers);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapView();
    });
  }

  void _filterLockers(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _filteredLockers = List.from(widget.parcelLockers);
        return;
      }

      final search = value.toLowerCase();

      _filteredLockers = widget.parcelLockers.where((locker) {
        return locker.name.toLowerCase().contains(search) ||
            locker.code.toLowerCase().contains(search) ||
            locker.city.toLowerCase().contains(search) ||
            locker.street.toLowerCase().contains(search);
      }).toList();
    });

    _updateMapView();
  }

  void _updateMapView() {
    if (_filteredLockers.isEmpty) return;

    if (_filteredLockers.length == 1) {
      final locker = _filteredLockers.first;

      _mapController.move(
        LatLng(locker.latitude, locker.longitude),
        16,
      );

      return;
    }

    final points = _filteredLockers
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();

    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  final MapController _mapController = MapController();

  double _currentZoom = 13;

  ParcelLocker? _selectedLocker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wybierz Punkt Odbioru"),
      ),
      body: Column(
        children: [

          Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Wyszukaj punkt odbioru...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onChanged: _filterLockers,
      ),
    ),

    if (_searchController.text.isNotEmpty)
  Container(
    constraints: const BoxConstraints(
      maxHeight: 220,
    ),
    margin: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(
          blurRadius: 8,
          color: Colors.black12,
        ),
      ],
    ),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredLockers.length,
      itemBuilder: (context, index) {

        final locker = _filteredLockers[index];

        return ListTile(

          leading: const Icon(
            Icons.location_on,
            color: Colors.red,
          ),

          title: Text(locker.code),

          subtitle: Text(
            "${locker.city} • ${locker.street}",
          ),

          onTap: () {

            setState(() {
              _selectedLocker = locker;
              _searchController.clear();
              _filteredLockers = List.from(widget.parcelLockers);
            });

            _mapController.move(
              LatLng(locker.latitude, locker.longitude),
              16,
            );

            FocusScope.of(context).unfocus();

          },
        );
      },
    ),
  ),

    Expanded(
      child: Stack(
        children: [

          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(50.6751, 17.9213),
              initialZoom: _currentZoom,
            ),
            children: [

              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.flutter_check",
              ),

              MarkerLayer(
                markers: _filteredLockers.map((locker) {

                  final bool isSelected =
                      _selectedLocker?.id == locker.id;

                  return Marker(
                    point: LatLng(
                      locker.latitude,
                      locker.longitude,
                    ),
                    width: isSelected ? 55 : 45,
                    height: isSelected ? 55 : 45,
                    child: GestureDetector(

                      onTap: () {

                        setState(() {
                          _selectedLocker = locker;
                        });

                        showModalBottomSheet(
                          context: context,
                          builder: (context) {

                            return Padding(
                              padding: const EdgeInsets.all(20),

                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    locker.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(locker.city),

                                  Text(locker.street),

                                  const SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,

                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check),

                                      onPressed: () {

                                        Navigator.pop(context);

                                        Navigator.pop(
                                          context,
                                          locker,
                                        );
                                      },

                                      label: const Text(
                                        "Wybierz Punkt Odbioru",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },

                      child: Icon(
                        Icons.location_on,
                        color: isSelected
                            ? Colors.green
                            : Colors.red,
                        size: isSelected ? 50 : 42,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          Positioned(
            right: 15,
            bottom: 20,

            child: Column(
              children: [

                FloatingActionButton.small(
                  heroTag: "zoomIn",

                  onPressed: () {

                    _currentZoom = (_currentZoom + 1).clamp(5.0, 18.0);

                    _mapController.move(
                      _mapController.camera.center,
                      _currentZoom,
                    );

                    setState(() {});
                  },

                  child: const Icon(Icons.add),
                ),

                const SizedBox(height: 10),

                FloatingActionButton.small(
                  heroTag: "zoomOut",

                  onPressed: () {

                    _currentZoom = (_currentZoom - 1).clamp(5.0, 18.0);

                    _mapController.move(
                      _mapController.camera.center,
                      _currentZoom,
                    );

                    setState(() {});
                  },

                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ],
      ),
    );
  }
}