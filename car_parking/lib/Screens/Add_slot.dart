import 'package:car_parking/Firebase/Firebase_parking.dart';
import 'package:car_parking/Screens/history.dart';
import 'package:car_parking/Screens/slot-selection.dart';
import 'package:car_parking/models/addslot.dart';
import 'package:flutter/material.dart';

class AddSlot extends StatefulWidget {
  final String? id;
  final String? parkingName;

  AddSlot({required this.id, required this.parkingName});

  @override
  _AddSlotState createState() => _AddSlotState();
}

class _AddSlotState extends State<AddSlot> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1F1E62),
          title: Text("Parking Space",style: TextStyle(color: Colors.white),),
          actions: [
            IconButton(
              onPressed: () {
                if (widget.id != null && widget.parkingName != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => History(parkingName: widget.parkingName!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Parking name not available.")),
                  );
                }
              },
              icon: Icon(Icons.history,color: Colors.white,),
            ),
          ],
        ),
        body: StreamBuilder<List<AddSlotModel>>(
          stream: AddParkingData().listenToSlotUpdates(widget.id, null,null,null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No slots added yet"));
            }

            final data = snapshot.data!;

            return ListView.separated(
              itemBuilder: (context, index) {
                final detail = data[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      key: ValueKey(detail.id),
                      title: Text("Space ${index + 1}"),
                      subtitle: Text(
                        "Available slots: ${detail.available.where((available) => available.isAvailable ?? false).length} / ${detail.available.length}",
                      ),
                      onTap: () {
                        if (widget.id != null && detail.id != null) {
                          Navigator.push(context,MaterialPageRoute(builder:(ctx)=>SlotSelection(parkingId: widget.id, slotId: detail.id, slotindex: index)));
                        }
                      },
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 5),
              itemCount: data.length,
            );
          },
        ),
      ),
    );
  }
}