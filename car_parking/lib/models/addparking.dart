class Addparking_model {
  String? id;
  String name;
  int slot;

  Addparking_model({this.id, required this.name, this.slot = 0});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "totalslot": slot,
    };
  }

  factory Addparking_model.fromJson(Map<String, dynamic> json, String id) {
    return Addparking_model(
      id: id,
      name: json["name"],
      slot: json["totalslot"] ?? 0,
    );
  }
}
