import 'package:car_parking/models/available.dart';

class AddSlotModel {
  String? id;
  int row;
  List<Available> available;
  String locationId;
  DateTime? bookingStartTime;
  DateTime? bookingEndTime;

  AddSlotModel({
    this.id,
    required this.row,
    required this.available,
    required this.locationId,
    this.bookingStartTime,
    this.bookingEndTime
    });

  Map<String, dynamic> toJson() {
    return {
      "row": row,
      "available": available.map((a) => a.toJson()).toList(),
      "locationId": locationId
    };
  }

  factory AddSlotModel.fromJson(Map<String, dynamic> json, String id,DateTime bookingStartTime,DateTime bookingEndTime) {
    return AddSlotModel(
      id: id,
      bookingStartTime: bookingStartTime,
      bookingEndTime: bookingEndTime,
      row: json["row"],
      available: (json["available"] as List<dynamic>)
          .map((a)=> Available.fromJson(a,bookingStartTime,bookingEndTime))
          .toList(),
      locationId: json["locationId"]
    );
  }
}
