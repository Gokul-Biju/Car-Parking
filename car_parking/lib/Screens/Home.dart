import 'package:car_parking/Firebase/Firebase_parking.dart';
import 'package:car_parking/Screens/Add_slot.dart';
import 'package:car_parking/models/addparking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isLoading = false;
  final userId = FirebaseAuth.instance.currentUser;

  String? username = "user";

  @override
  void initState() {
    super.initState();
    _fetchData();
    fetchUsername();
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

  Future<void> fetchUsername() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users') 
          .doc(userId?.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          username = snapshot.data()?['username']; 
        });
      } 
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1F1E62),
          title: Text("${username}",style: TextStyle(color: Colors.white),),
          titleSpacing: 0.0,
          leadingWidth: 37.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10,right: 50),
            child: Icon(Icons.account_circle,color: Colors.white,),
          ),
          actions: [
            IconButton(onPressed:()async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).popUntil((route) => route.isFirst);
          }, icon: Icon(Icons.logout,color: Colors.white,)),
          ],
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
                              "Number of space: ${detail.slot.toString()}",
                            ),
                            onTap: () {
                              if(detail.id != null){
                                   Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => AddSlot(id: detail.id,parkingName: detail.name),
                                ),
                              );
                              }
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
      ),
    );
  }
}