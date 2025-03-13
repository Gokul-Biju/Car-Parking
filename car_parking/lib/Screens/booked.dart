import 'package:car_parking/models/Success.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiptPage extends StatelessWidget {
  final Success success;

  ReceiptPage({required this.success});

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  Future<Map<String, double>> _fetchLocation(String locationId) async {
    try {
      final locationSnapshot = await FirebaseFirestore.instance
          .collection('slotLocations')
          .doc(locationId)
          .get();

      if (locationSnapshot.exists) {
        final latitude = locationSnapshot.data()?['latitude'] as double;
        final longitude = locationSnapshot.data()?['longitude'] as double;
        return {'latitude': latitude, 'longitude': longitude};
      } else {
        return {'latitude': 0.0, 'longitude': 0.0};
      }
    } catch (e) {
      print('Error fetching location: $e');
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedStartTime =
        DateFormat('yyyy-MM-dd hh:mm:ss a').format(success.Start.toDate());
     final formattedEndTime =
        DateFormat('yyyy-MM-dd hh:mm:ss a').format(success.end.toDate());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1E62),
        title: Text(
          'Confirmation',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Booking Confirmed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Parking Name: ${success.name}',
                      textAlign: TextAlign.center),
                  Text('Space: ${success.space}', textAlign: TextAlign.center),
                  Text('Slot: ${success.slot}', textAlign: TextAlign.center),
                  Text('Vehicle Number:${success.vehicle}',
                      textAlign: TextAlign.center),
                  Text('Validity From: $formattedStartTime to: $formattedEndTime',
                      textAlign: TextAlign.center),
                  SizedBox(height: 24),
                  FutureBuilder<Map<String, double>>(
                    future: _fetchLocation(success.locationId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error loading location');
                      } else {
                        final locationData = snapshot.data ??
                            {'latitude': 0.0, 'longitude': 0.0};
                        return ElevatedButton(
                          onPressed: () {
                            _openMap(
                                locationData['latitude']!,
                                locationData['longitude']!);
                          },
                          child: Text('View Location'),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}