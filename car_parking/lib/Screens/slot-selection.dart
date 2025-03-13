import 'package:car_parking/Screens/display_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class SlotSelection extends StatefulWidget {
  final String? parkingId;
  final String? slotId;
  final int slotindex;

  SlotSelection({
    required this.parkingId,
    required this.slotId,
    required this.slotindex,
  });

  @override
  _SlotSelectionState createState() => _SlotSelectionState();
}

class _SlotSelectionState extends State<SlotSelection> {
  int _selectedHours = 1;
  int _price = 20;
  bool _isLoading = false;
  TextEditingController controller = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Booking Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _selectDateTime(context),
              child: Text('Select Date and Time'),
            ),
            SizedBox(height: 8),
            Text( 
              'Selected Date and Time: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text("Select Booking Duration:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            RadioListTile<int>(
              title: Text("1 Hour - \₹20"),
              value: 1,
              groupValue: _selectedHours,
              onChanged: (value) => _updateDuration(value!, 20),
            ),
            RadioListTile<int>(
              title: Text("2 Hours - \₹40"),
              value: 2,
              groupValue: _selectedHours,
              onChanged: (value) => _updateDuration(value!, 40),
            ),
            RadioListTile<int>(
              title: Text("4 Hours - \₹80"),
              value: 4,
              groupValue: _selectedHours,
              onChanged: (value) => _updateDuration(value!, 80),
            ),
            RadioListTile<int>(
              title: Text("8 Hours - \₹160"),
              value: 8,
              groupValue: _selectedHours,
              onChanged: (value) => _updateDuration(value!, 160),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Vehicle Number", style: TextStyle(fontSize: 18)),
            ),
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
              controller: controller,
            ),
            SizedBox(height: 20),
            Text("Total Price: \₹${_price}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please enter a vehicle number."),
                          ),
                        );
                        return;
                      }
                      Timestamp start = Timestamp.fromDate(_selectedDateTime);
                      Timestamp end = Timestamp.fromDate( _selectedDateTime.add(Duration(hours: _selectedHours)));
                      print(start);
                      print(end);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => SlotDetailsPage(
                            parkingId: widget.parkingId,
                            slotId: widget.slotId,
                            slotindex: widget.slotindex,
                            price: _price,
                            vehicle: controller.text,
                            bookingEndTime: _selectedDateTime.add(Duration(hours: _selectedHours)).subtract(Duration(seconds: 1)),
                            bookingStartTime: _selectedDateTime,
                          ),
                        ),
                      );
                    },
                    child: Text("Book Slot"),
                  ),
          ],
        ),
      ),
    );
  }

  void _updateDuration(int hours, int price) {
    setState(() {
      _selectedHours = hours;
      _price = price;
    });
  }
}