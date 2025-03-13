import 'package:admin/Firebase/Firebase_parking.dart';
import 'package:admin/Screens/Add_slot_dialog.dart';
import 'package:admin/Screens/display_slot.dart';
import 'package:admin/models/addslot.dart';
import 'package:flutter/material.dart';

class AddSlot extends StatefulWidget {
  final String? id;

  AddSlot({required this.id});

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
          title: Text("Manage Spaces", style: TextStyle(color: Colors.white)),
        ),
        body: StreamBuilder<List<AddSlotModel>>(
          stream: AddParkingData().listenToSlotUpdates(widget.id, null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No spaces added yet"));
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
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          try {
                            await AddParkingData().deleteSlot(
                              widget.id,
                              detail.id,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error deleting slot: $e"),
                              ),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (ctx) => SlotDetailsPage(
                                  parkingId: widget.id,
                                  slotId: detail.id,
                                ),
                          ),
                        );
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (ctx) => AddSlotDialog(id: widget.id),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
