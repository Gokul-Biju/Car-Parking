import 'package:car_parking/models/Success.dart';
import 'package:car_parking/models/addparking.dart';
import 'package:car_parking/models/addslot.dart';
import 'package:car_parking/models/available.dart';
import 'package:car_parking/models/slotime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AddParkingData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static ValueNotifier<List<Addparking_model>> addvalue = ValueNotifier([]);
  static ValueNotifier<List<AddSlotModel>> addSlot = ValueNotifier([]);
  static ValueNotifier<List<Success>> addsuccess = ValueNotifier([]);

  Future<void> fetchAllParking() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("Parking").get();

      List<Addparking_model> parkingList =
          querySnapshot.docs.map((doc) {
            print("Document ID: ${doc.id}, totalslot: ${doc["totalslot"]}");
            return Addparking_model(
              id: doc.id,
              name: doc["name"],
              slot: doc["totalslot"] ?? 0,
            );
          }).toList();

      addvalue.value = List.from(parkingList);
      addvalue.notifyListeners();
    } catch (e, stackTrace) {
      print("Error fetching parking data: $e");
      print("StackTrace: $stackTrace");
    }
  }

  Future<void> fetchSlots(String? parkingId,DateTime bookingStartTime,DateTime bookingEndTime) async {
    if (parkingId == null) {
      print("Parking ID is null in fetchSlots");
      return;
    }
    try {
      addSlot.value = [];
      QuerySnapshot snapshot =
          await _firestore
              .collection("Parking")
              .doc(parkingId)
              .collection("Slots")
              .get();
      List<AddSlotModel> slots =
          snapshot.docs.map((doc) {
            print("Fetched slot ID: ${doc.id}");
            return AddSlotModel(
              id: doc.id,
              row: doc["row"] ?? 0,
              available:
                  (doc["available"] as List<dynamic>)
                      .map((a) => Available.fromJson(a,bookingStartTime,bookingEndTime))
                      .toList(),
              locationId: doc["locationId"],
              bookingStartTime: bookingStartTime,
              bookingEndTime: bookingEndTime              
            );
          }).toList();
      addSlot.value = slots;
      addSlot.notifyListeners();
      print(
        "Slots fetched successfully for parking: $parkingId. Total slots: ${slots.length}",
      );
    } catch (e, stackTrace) {
      print("Error fetching slots: $e");
      print("StackTrace: $stackTrace");
    }
  }

  Stream<List<AddSlotModel>> listenToSlotUpdates(
    String? parkingId,
    String? slotId,
    DateTime? bookingStartTime,
    DateTime? bookingEndTime
  ) {
    if (parkingId == null) {
      return Stream.value([]);
    }

    if (slotId == null) {
      return _firestore
          .collection("Parking")
          .doc(parkingId)
          .collection("Slots")
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return AddSlotModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
                bookingStartTime ?? DateTime.now(),
                bookingEndTime ?? DateTime.now()
              );
            }).toList();
          });
    } else {
      return _firestore
          .collection("Parking")
          .doc(parkingId)
          .collection("Slots")
          .doc(slotId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              return [];
            }
            return [
              AddSlotModel.fromJson(
                snapshot.data() as Map<String, dynamic>,
                snapshot.id,
                bookingStartTime!,
                bookingEndTime!
              ),
            ];
          });
    }
  }

  
Future<bool> updateSlotAvailability(
  String? parkingId,
  String? slotId,
  int availableIndex,
  DateTime bookingStartTime,
  DateTime bookingEndTime,
  int slotindex,
  String? vehicle,
) async {
  final slotDoc = FirebaseFirestore.instance.collection('Parking').doc(parkingId).collection('Slots').doc(slotId);

  try {
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(slotDoc);

      if (!docSnapshot.exists) {
        print("Error: Slot document does not exist for slotId: $slotId");
        return false;
      }

      final parkingDoc = FirebaseFirestore.instance.collection('Parking').doc(parkingId);
      final parkingSnapshot = await transaction.get(parkingDoc);
      final parkingData = parkingSnapshot.data();
      final parkingName = parkingData?['name'] as String?;

      if (parkingName == null) {
        print("Error: Parking name not found for parkingId: $parkingId");
        return false;
      }

      final slotData = AddSlotModel.fromJson(docSnapshot.data()!, docSnapshot.id, bookingStartTime, bookingEndTime);

      if (availableIndex >= slotData.available.length) {
        print("Error: Invalid slot index: $availableIndex");
        return false;
      }

      if (vehicle != null) {
        final timestampStart = Timestamp.fromDate(bookingStartTime);
        final timestampEnd = Timestamp.fromDate(bookingEndTime);

        final success = Success(
          name: parkingName,
          space: slotindex + 1,
          slot: (availableIndex + 1).toString(),
          Start: timestampStart,
          end: timestampEnd,
          status: "Booked",
          vehicle: vehicle,
          locationId: slotData.locationId,
        );

        final userId = FirebaseAuth.instance.currentUser;

        if (userId != null) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(userId.uid).collection('Success').add(success.toJson());
          } catch (e) {
            print("Error adding success to Firestore: $e");
          }
        }
      }

      final timestampStartTime = Timestamp.fromDate(bookingStartTime);
      final timestampEndTime = Timestamp.fromDate(bookingEndTime);
      final slotime = Slotime(startTime: timestampStartTime, endTime: timestampEndTime);
      final updatedAvailable = List<Available>.from(slotData.available);

      final existingAvailable = updatedAvailable[availableIndex];
      if (existingAvailable.slotime == null) {
        existingAvailable.slotime = []; 
      }
      existingAvailable.slotime!.add(slotime);
      updatedAvailable[availableIndex] = Available(slotime: existingAvailable.slotime);

      transaction.update(slotDoc, {'available': updatedAvailable.map((e) => e.toJson()).toList()});

      return true;
    });
  } catch (error) {
    print("Transaction error: $error");
    return false;
  }
}

  Future<void> fetchAndSetSuccessData(String parkingName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print("User not logged in");
        addsuccess.value = [];
        addsuccess.notifyListeners();
        return;
      }

      print(
        "Fetching success records for user: $userId and parking name: $parkingName",
      );

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('Success')
              .where('name', isEqualTo: parkingName)
              .get();

      print("Number of documents fetched: ${querySnapshot.docs.length}");

      final successList =
          querySnapshot.docs.map((doc) {
            print("Document data: ${doc.data()}");
            return Success.fromJson(doc.data());
          }).toList();

      addsuccess.value = successList;
      addsuccess.notifyListeners();
    } catch (e) {
      print('Error fetching success records: $e');
      addsuccess.value = [];
      addsuccess.notifyListeners();
    }
  }

  void listenToParkingUpdates() {
    _firestore.collection("Parking").snapshots().listen((snapshot) {
      List<Addparking_model> parkingList =
          snapshot.docs.map((doc) {
            print("Document ID: ${doc.id}, totalslot: ${doc["totalslot"]}");
            return Addparking_model(
              id: doc.id,
              name: doc["name"],
              slot: doc["totalslot"] ?? 0,
            );
          }).toList();
      addvalue.value = List.from(parkingList);
    });
  }
}
