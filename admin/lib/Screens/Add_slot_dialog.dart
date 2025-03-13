import 'package:admin/Firebase/Firebase_parking.dart';
import 'package:admin/models/addslot.dart';
import 'package:admin/models/available.dart';
import 'package:admin/models/location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class AddSlotDialog extends StatefulWidget {
  final String? id;

  AddSlotDialog({required this.id, super.key});

  @override
  State<AddSlotDialog> createState() => _AddSlotDialogState();
}

class _AddSlotDialogState extends State<AddSlotDialog> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;
  LatLng? currentLocation;
  LatLng? selectedLocation;
  GoogleMapController? mapController;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndGetCurrentLocation();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermissionAndGetCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = currentLocation;
      });
    } catch (e) {
      print('Location error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.normal)
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onMyLocationButtonPressed() {
    if (mapController != null && currentLocation != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentLocation!, 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Add Slot Details"),
      ),
      children: [
        if (isLoading)
          Center(child: CircularProgressIndicator())
        else
          Column(
            children: [
              Text(
                "Mark the location and enter the row number",
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: Stack(
                    children: [
                      GoogleMap(
                        mapType: _currentMapType,
                        initialCameraPosition: CameraPosition(
                          target: currentLocation ?? LatLng(20.5937, 78.9629),
                          zoom: 15,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                          if (currentLocation != null) {
                            controller.animateCamera(CameraUpdate.newLatLngZoom(currentLocation!, 15));
                          }
                        },
                        onTap: (LatLng tappedLocation) {
                          setState(() {
                            selectedLocation = tappedLocation;
                          });
                        },
                        markers: selectedLocation != null
                            ? {
                                Marker(
                                  markerId: MarkerId('selectedLocation'),
                                  position: selectedLocation!,
                                ),
                              }
                            : {},
                        myLocationEnabled: true,
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              onPressed: _onMapTypeButtonPressed,
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                              backgroundColor: Colors.green,
                              child: Icon(Icons.map, size: 36.0),
                            ),
                            SizedBox(height: 10),
                            FloatingActionButton(
                              onPressed: _onMyLocationButtonPressed,
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.my_location, size: 36.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Row number'),
                  controller: controller,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        if (!isLoading)
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    int rowCount = int.tryParse(controller.text) ?? 0;

                    if (rowCount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter a valid row number.")),
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }

                    try {
                      if (selectedLocation == null) {
                        throw "Location not found.";
                      }

                      print(
                          "Selected Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}");

                      String locationId = await AddParkingData().addSlotLocation(
                        SlotLocation(
                          latitude: selectedLocation!.latitude,
                          longitude: selectedLocation!.longitude,
                        ),
                      );

                      List<Available> available =
                          List.generate(rowCount * 2, (index) => Available());

                      if (widget.id != null) {
                        AddSlotModel model = AddSlotModel(
                          row: rowCount,
                          available: available,
                          locationId: locationId,
                        );
                        await AddParkingData().addSlotDetails(widget.id, model);
                        await AddParkingData().fetchSlots(widget.id);
                      }

                      Navigator.pop(context);
                    } catch (e) {
                      print('Database error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text("OK"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
              )
            ],
          )
      ],
    );
  }
}