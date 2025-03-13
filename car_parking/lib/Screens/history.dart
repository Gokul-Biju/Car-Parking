import 'package:car_parking/Firebase/Firebase_parking.dart';
import 'package:car_parking/Screens/booked.dart';
import 'package:car_parking/models/Success.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  final String parkingName;

  History({required this.parkingName});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await AddParkingData().fetchAndSetSuccessData(widget.parkingName);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load history.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF1F1E62),title: Text("Bookings",style: TextStyle(color: Colors.white),)),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage)) 
              : ValueListenableBuilder<List<Success>>(
                valueListenable: AddParkingData.addsuccess,
                builder: (context, data, child) {
                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        'Not available',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      final details = data[index];
                      final formattedTime = DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(details.Start.toDate());
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            leading: Text(details.name),
                            title: Text("Space ${details.space}"),
                            subtitle: Text("Slot ${details.slot}"),
                            trailing: Text(formattedTime),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ReceiptPage(
                                        success: details,
                                      ), 
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 5);
                    },
                    itemCount: data.length,
                  );
                },
              ),
    );
  }
}
