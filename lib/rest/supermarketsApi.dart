
import 'dart:convert';

import 'package:wimp/model/supermarketModel.dart';
import 'package:http/http.dart' as http;

class SupermarketApi {

  static Future<List<SupermarketModel>> getClosestSupermarkets() async {
    final response =  await http.get('http://15.236.118.131:5000/commercial-activities');
    //final response =  await http.get('https://my-json-server.typicode.com/pauln19/demo/supermarkets');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return (json.decode(response.body) as List)
          .map((data) => new SupermarketModel.fromJson(data))
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to fetch supermarkets');
    }
  }

}