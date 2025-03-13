import 'package:admin/Firebase/Firebase_parking.dart';
import 'package:admin/Screens/Add_slot.dart';
import 'package:admin/models/addparking.dart';
import 'package:flutter/material.dart';
import 'Add_Parking.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    AddParkingData().listenToParkingUpdates();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await AddParkingData().fetchAllParking();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1F1E62),
          title: Text("Admin Panel",style: TextStyle(color: Colors.white),),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ValueListenableBuilder(
                valueListenable: AddParkingData.addvalue,
                builder: (context, List<Addparking_model> data, child) {
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      final detail = data[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            title: Text(detail.name),
                            subtitle: Text(
                              "Number of slots: ${detail.slot.toString()}",
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Confirm Delete"),
                                      content: Text("Are you sure you want to delete this parking location?"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () => Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: Text("Delete"),
                                          onPressed: () => Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirmDelete == true) {
                                  try {
                                    await AddParkingData().deleteParking(detail.id);
                                    await _fetchData();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error deleting parking: $e")),
                                    );
                                  }
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => AddSlot(id: detail.id),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 5),
                    itemCount: data.length,
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(context: context, builder: (ctx) => AddParking());
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}