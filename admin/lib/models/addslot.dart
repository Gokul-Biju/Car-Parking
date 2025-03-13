import 'package:admin/models/available.dart';

class AddSlotModel {
  String? id;
  int row;
  List<Available> available;
  String? locationId;

  AddSlotModel({
    this.id,
    required this.row,
    required this.available,
    this.locationId,
  });

  Map<String, dynamic> toJson() {
    return {
      "row": row,
      "available": available.map((a) => a.toJson()).toList(),
      "locationId": locationId,
    };
  }

  factory AddSlotModel.fromJson(Map<String, dynamic> json, String id) {
    return AddSlotModel(
      id: id,
      row: json["row"],
      available: (json["available"] as List<dynamic>)
          .map((a) => Available.fromJson(a))
          .toList(),
      locationId: json["locationId"],
    );
  }
}