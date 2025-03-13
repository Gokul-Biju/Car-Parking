import 'package:admin/Firebase/Firebase_parking.dart';
import 'package:admin/models/addslot.dart';
import 'package:flutter/material.dart';

class SlotDetailsPage extends StatelessWidget {
  final String? parkingId;
  final String? slotId;

  SlotDetailsPage({required this.parkingId,required this.slotId});

  @override
  Widget build(BuildContext context) {
    print("SlotDetailsPage parkingId : $parkingId");
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF1F1E62),title: Text("Slot Details",style: TextStyle(color: Colors.white),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<AddSlotModel>>(
          stream: AddParkingData().listenToSlotUpdates(parkingId,slotId),
          builder: (context, snapshot) {
            print("SlotDetailsPage StreamBuilder snapshot: ${snapshot.data}");
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(""));
            }

            final slotData = snapshot.data!.first;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: slotData.available.length,
              itemBuilder: (context, index) {
                final availableSlot = slotData.available[index];
                Color boxColor = availableSlot.isAvailable ==null || availableSlot.isAvailable == true  ? Color(0xFF296093) : Color(0xFF0D1D2D);
                return Container(
                  key: ValueKey(index),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "Slot ${index + 1}",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}