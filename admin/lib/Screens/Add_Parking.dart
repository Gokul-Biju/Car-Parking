import 'package:admin/Firebase/Firebase_parking.dart';
import 'package:admin/models/addparking.dart';
import 'package:flutter/material.dart';

class AddParking extends StatefulWidget {
  AddParking({super.key});

  @override
  State<AddParking> createState() => _AddParkingState();
}

class _AddParkingState extends State<AddParking> {
  TextEditingController controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Parking Name"),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(border: OutlineInputBorder()),
            controller: controller,
            keyboardType: TextInputType.text,
          ),
        ),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    if (controller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter a parking name.")),
                      );
                      return;
                    }
                    var parkingData = AddParkingData();
                    await parkingData.addCollection(Addparking_model(
                        name: controller.text, slot: 0)); 
                    await parkingData.fetchAllParking();
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("An error occurred: $e")),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: _isLoading ? CircularProgressIndicator() : Text("OK"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
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