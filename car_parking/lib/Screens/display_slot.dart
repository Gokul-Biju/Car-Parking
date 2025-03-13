import 'package:car_parking/Firebase/Firebase_parking.dart';
import 'package:car_parking/Screens/payment.dart';
import 'package:car_parking/models/addslot.dart';
import 'package:flutter/material.dart';

class SlotDetailsPage extends StatefulWidget {
  final String? parkingId;
  final String? slotId;
  final int slotindex;
  final int price;
  final String vehicle;
  final DateTime bookingStartTime;
  final DateTime bookingEndTime;

  SlotDetailsPage({
    required this.parkingId,
    required this.slotId,
    required this.slotindex,
    required this.price,
    required this.vehicle,
    required this.bookingStartTime,
    required this.bookingEndTime,
  });

  @override
  _SlotDetailsPageState createState() => _SlotDetailsPageState();
}

class _SlotDetailsPageState extends State<SlotDetailsPage> {
  final AddParkingData _parkingData = AddParkingData();
  bool _isLoading = false;

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1E62),
        title: Text(
          "Available Slots",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<List<AddSlotModel>>(
              stream: _parkingData.listenToSlotUpdates(
                  widget.parkingId, widget.slotId, widget.bookingStartTime, widget.bookingEndTime),
              builder: (context, snapshot) {
                print("StreamBuilder Connection State: ${snapshot.connectionState}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No slots found.'));
                }

                if (snapshot.hasData) {
                  final slots = snapshot.data!;
                  final slot = slots.first;
                  print("Firestore Data: ${slot.available}");

                  return Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: slot.available.length,
                          itemBuilder: (context, index) {
                            final availableSlot = slot.available[index];

                            return GestureDetector(
                              key: ValueKey(availableSlot.isAvailable),
                              onTap: availableSlot.isAvailable != null && availableSlot.isAvailable == true
                                  ? () async {
                                      await Payment(
                                        price: widget.price,
                                        parkingId: widget.parkingId,
                                        slotId: widget.slotId,
                                        slotindex: widget.slotindex,
                                        availableIndex: index,
                                        vehicle: widget.vehicle,
                                        bookingStartTime: widget.bookingStartTime,
                                        bookingEndTime: widget.bookingEndTime,
                                        context: context,
                                        setLoading: _setLoading,
                                      ).onPayment();
                                    }
                                  : null,
                              child: Container(
                                margin: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: availableSlot.isAvailable == null || availableSlot.isAvailable == true
                                      ? Color(0xFF296093)
                                      : Color(0xFF0D1D2D),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Slot ${index + 1}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      availableSlot.isAvailable == null || availableSlot.isAvailable == true ? Text("Book",style: TextStyle(color: Colors.white),)
                                       : Text("Booked",style: TextStyle(color: Colors.white),)

                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return Center(child: Text('No slots found.'));
              },
            ),
    );
  }
}