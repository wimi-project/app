import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:wimi/model/productModel.dart';
import 'package:wimi/model/storeModel.dart';

class StoreApi {
  static Future<List<StoreModel>> getClosestStores() async {
    final response =
        await http.get('http://15.236.118.131:5000/commercial-activities');
    //final response =  await http.get('https://my-json-server.typicode.com/pauln19/demo/supermarkets');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return (json.decode(response.body) as List)
          .map((data) => new StoreModel.fromJson(data))
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to fetch stores');
    }
  }

  static Future<List<StoreModel>> getClosestStoresGivenProduct(
      ProductModel product, LatLng location) async {
    String getUrl = 'http://15.236.118.131:5000/near-product-availability/' +
        location.latitude.toString() +
        '/' +
        location.longitude.toString() +
        '/' +
        '3000.0/' +
        product.id.toString();

    final response = await http.get(getUrl);
    //final response =  await http.get('https://my-json-server.typicode.com/pauln19/demo/supermarkets');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return (json.decode(response.body) as List)
          .map((data) => new StoreModel.fromJson(data))
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to fetch stores');
    }
  }
}
