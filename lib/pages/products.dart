import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:wimp/model/productModel.dart';
import 'package:wimp/rest/productsApi.dart';

Widget getProductsPage() {
  return MaterialApp(
    home: FutureBuilder<List<ProductModel>>(
        future: ProductApi.getClosestProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingSearchBar.builder(
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    leading: Container(
                        child: Image.network(
                      snapshot.data.elementAt(index).imgUrl,
                      filterQuality: FilterQuality.low,
                    )),
                    title: Text(
                      snapshot.data.elementAt(index).name,
                      style: TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(snapshot.data.elementAt(index).feedback,
                        style: TextStyle(fontStyle: FontStyle.italic)),
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
