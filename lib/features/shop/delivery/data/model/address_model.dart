import 'package:hive/hive.dart';

part 'address_model.g.dart';

@HiveType(typeId: 11) // Make sure the typeId is unique across your app
class AddressModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String street;

  @HiveField(3)
  String city;

  @HiveField(4)
  String state;

  @HiveField(5)
  String country;

  @HiveField(6)
  String pincode;

  @HiveField(7)
  bool selection;
  @HiveField(8)
  String phonenumber;

  AddressModel({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.selection,
    required this.phonenumber,
  });

  // From JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
  return AddressModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? "",
    street: json['street'] ?? "",
    city: json['city'] ?? "",
    state: json['state'] ?? "",
    country: json['country'] ?? "",
    pincode: json['pincode'] ?? "",
    selection: json['selection'] ?? false,
    phonenumber: json['phone_number'] ?? "",
  );
}


  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'selection': selection,
      'phone_number': phonenumber,
    };
  }
}
