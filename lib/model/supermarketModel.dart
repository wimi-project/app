import 'dart:ffi';

class SupermarketModel {
  int id;
  String name;
  String address;
  double latitude;
  double longitude;
  int queueTime;

  SupermarketModel({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.queueTime
  });

  factory SupermarketModel.fromJson(Map<String, dynamic> json){
    return SupermarketModel(
      id: json['commercial_activity_id'],
      name: json['name'],
      address: json['address'],
      latitude: json['position_lat'],
      longitude: json['position_lon'],
      queueTime: json['queue_time']
    );
  }
}