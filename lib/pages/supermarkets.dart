import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:wimp/model/supermarketModel.dart';
import 'package:wimp/rest/supermarketsApi.dart';

Widget getSupermarketsPage() {
  return MaterialApp(
    home: FutureBuilder<List<SupermarketModel>>(
        future: SupermarketApi.getClosestSupermarkets(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingSearchBar.builder(
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    leading: Container(
                        child: Icon(Icons.shopping_cart,
                            color: Colors.deepOrange)),
                    title: Text(
                      snapshot.data.elementAt(index).name,
                      style: TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right,
                        color: Colors.white, size: 30.0));
              },
            );
          } else if (snapshot.hasError) {
            return Scaffold(body: Text("Can't fetch the data"));
          }
          return Stack(children: [Center(child: CircularProgressIndicator())]);
        }),
  );
}
