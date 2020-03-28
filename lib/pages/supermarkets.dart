import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';

Widget getSupermarketsPage() {
  return MaterialApp(
    home: FloatingSearchBar.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            leading:
                Container(child: Icon(Icons.shopping_cart, color: Colors.deepOrange)),
            title: Text(
              "test",
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(Icons.keyboard_arrow_right,
                color: Colors.white, size: 30.0));
      },
    ),
  );
}

Widget getCard() {
  return Scaffold(
      body: Container(
    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
    height: 220,
    width: double.maxFinite,
    child: Card(
      elevation: 5,
    ),
  ));
}
