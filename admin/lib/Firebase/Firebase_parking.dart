import 'package:admin/models/addparking.dart';
import 'package:admin/models/addslot.dart';
import 'package:admin/models/available.dart';
import 'package:admin/models/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AddParkingData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static ValueNotifier<List<Addparking_model>> addvalue = ValueNotifier([]);
  static ValueNotifier<List<AddSlotModel>> addSlot = ValueNotifier([]);

  Future<void> addCollection(Addparking_model data) async {
    try {
      DocumentReference docRef = await _firestore.collection("Parking").add({
        "name": data.name,
        "totalslot": data.slot,
      });

      data.id = docRef.id;
      addvalue.value = List.from(addvalue.value)..add(data);
      addvalue.notifyListeners(); 
    } catch (e) {
      print("Error adding parking: $e");
    }
  }

  Future<String> addSlotLocation(SlotLocation location) async {
  try {
    DocumentReference docRef = await _firestore.collection('slotLocations').add(location.toJson());
    String locationId = docRef.id;

    print("Location ID generated: $locationId");
    return locationId;
  } catch (e) {
    print('Error adding slot location: $e');
    return "";
  }
}

  Future<void> deleteParking(String? parkingId) async {
    if (parkingId == null) return;

    try {
      await _firestore.collection("Parking").doc(parkingId).delete();

      QuerySnapshot slotsSnapshot = await _firestore
          .collection("Parking")
          .doc(parkingId)
          .collection("Slots")
          .get();

      for (DocumentSnapshot doc in slotsSnapshot.docs) {
        await doc.reference.delete();
      }

      addvalue.value = addvalue.value.where((parking) => parking.id != parkingId).toList();
      addvalue.notifyListeners();

      print("Parking location deleted successfully: $parkingId");
    } catch (e) {
      print("Error deleting parking location: $e");
    }
  }

  Future<void> fetchAllParking() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("Parking").get();

      List<Addparking_model> parkingList =
          querySnapshot.docs.map((doc) {
            return Addparking_model(
              id: doc.id,
              name: doc["name"],
              slot: doc["totalslot"],
            );
          }).toList();

      addvalue.value = List.from(parkingList);
      addvalue.notifyListeners(); 
    } catch (e) {
      print("Error fetching parking data: $e");
    }
  }

  Future<void> addSlotDetails(String? parkingId, AddSlotModel model) async {
    String slotId = "";
    try {
        await _firestore.runTransaction((transaction) async {
            DocumentReference parkingRef = _firestore.collection("Parking").doc(parkingId);
            slotId = parkingRef.collection("Slots").doc().id;

            transaction.set(parkingRef.collection("Slots").doc(slotId), {
                "row": model.row,
                "available": model.available.map((a) => a.toJson()).toList(),
                "timestamp": FieldValue.serverTimestamp(),
                "locationId": model.locationId,
            });
            transaction.update(parkingRef, {"totalslot": FieldValue.increment(1)});
        });
        model.id = slotId;
        print("Slot added with ID: $slotId");
        await fetchSlots(parkingId);
    } catch (e) {
        print("Error adding slot: $e");
    }
}

   Future<void> fetchSlots(String? parkingId) async {
    if (parkingId == null) {
        print("Parking ID is null in fetchSlots");
        return;
    }
    try {
        addSlot.value = [];
        QuerySnapshot snapshot = await _firestore
            .collection("Parking")
            .doc(parkingId)
            .collection("Slots")
            .get();
        List<AddSlotModel> slots = snapshot.docs.map((doc) {
            print("Fetched slot ID: ${doc.id}");
            return AddSlotModel(
                id: doc.id,
                row: doc["row"] ?? 0,
                available: (doc["available"] as List<dynamic>)
                    .map((a) => Available.fromJson(a))
                    .toList(),
            );
        }).toList();
        addSlot.value = slots;
        addSlot.notifyListeners();
        print("Slots fetched successfully for parking: $parkingId. Total slots: ${slots.length}");
    } catch (e) {
        print("Error fetching slots: $e");
    }
}

  Future<void> deleteSlot(String? parkingId, String? slotId) async {
    if (parkingId == null || slotId == null) return;
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference parkingRef = _firestore.collection("Parking").doc(parkingId);
        transaction.delete(parkingRef.collection("Slots").doc(slotId));
        transaction.update(parkingRef, {"totalslot": FieldValue.increment(-1)});
      });
      print("Slot deleted with ID: $slotId");
      await fetchSlots(parkingId);
    } catch (e) {
      print("Error deleting slot: $e");
    }
  }

Stream<List<AddSlotModel>> listenToSlotUpdates(String? parkingId, String? slotId) {
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
          return AddSlotModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
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
        return [AddSlotModel.fromJson(snapshot.data() as Map<String, dynamic>, snapshot.id)];
      });
    }
  }

  void listenToParkingUpdates() {
    _firestore.collection("Parking").snapshots().listen((snapshot) {
      List<Addparking_model> parkingList =
          snapshot.docs.map((doc) {
            return Addparking_model(
              id: doc.id,
              name: doc["name"],
              slot: doc["totalslot"],
            );
          }).toList();
      addvalue.value = List.from(parkingList);
    });
  }
}
