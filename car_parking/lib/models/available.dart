import 'package:car_parking/models/slotime.dart';

class Available {
  bool? isAvailable;
  List<Slotime>? slotime;
  DateTime? bookingStartTime;
  DateTime? bookingEndTime;

  Available({this.isAvailable, this.slotime});

  Map<String, dynamic> toJson() {
    return {
      if (slotime != null)
        "slotime": slotime!.map((slot) => slot.toJson()).toList(),
    };
  }

  factory Available.fromJson(
    Map<String, dynamic> json,
    DateTime bookingStartTime,
    DateTime bookingEndTime,
  ) {
    List<Slotime>? slotimeList;
    bool? calculatedIsAvailable;

    if (json["slotime"] != null) {
      slotimeList =
          (json["slotime"] as List).map((item) => Slotime.fromJson(item)).toList();
      calculatedIsAvailable = true;
      
      for (Slotime slot in slotimeList) {
        if (slot.startTime != null && slot.endTime != null) {
          DateTime slotStart = slot.startTime!.toDate();
          DateTime slotEnd = slot.endTime!.toDate();

          if (!(slotEnd.isBefore(bookingStartTime) || slotStart.isAfter(bookingEndTime))) {
            calculatedIsAvailable = false;
            break;
          }
        } else {
          calculatedIsAvailable = false;
          break;
        }
      }
    } else {
      calculatedIsAvailable = true;
    }

    return Available(slotime: slotimeList, isAvailable: calculatedIsAvailable);
  }

  bool get isAvailableNonNull {
    return isAvailable ?? false;
  }
}
