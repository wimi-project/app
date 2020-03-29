import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:wimp/model/productModel.dart';
import 'package:wimp/model/supermarketModel.dart';
import 'package:wimp/rest/productsApi.dart';
import 'package:wimp/rest/supermarketsApi.dart';

class SupermarketsAndProducts {
  final List<SupermarketModel> supermarkets;
  final List<ProductModel> products;

  SupermarketsAndProducts({this.supermarkets, this.products});
}

Widget getFeedbackPage(GlobalKey<FormBuilderState> fbKey) {
  Future<List<SupermarketModel>> supermarkets =
      SupermarketApi.getClosestSupermarkets();
  Future<List<ProductModel>> products = ProductApi.getClosestProducts();

  return FutureBuilder(
    future: Future.wait([supermarkets, products]).then((response) =>
        new SupermarketsAndProducts(
            supermarkets: response[0], products: response[1])),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Wimp'),
              backgroundColor: Colors.red[700],
              centerTitle: true,
            ),
            body: Column(children: <Widget>[
              FormBuilder(
                key: fbKey,
                child: Column(
                  children: <Widget>[
                    FormBuilderDropdown(
                        attribute: "supermarket",
                        decoration: InputDecoration(labelText: "Supermarket"),
                        items: snapshot.data.supermarkets
                            .map((supermarket) => DropdownMenuItem(
                                  value: supermarket.id,
                                  child: Text(supermarket.name),
                                ))
                            .toList()),
                    FormBuilderDropdown(
                        attribute: "product",
                        decoration: InputDecoration(labelText: "Product"),
                        items: snapshot.data.products
                            .map((product) => DropdownMenuItem(
                                  value: product.id,
                                  child: Text(product.name),
                                ))
                            .toList()),
                    FormBuilderDropdown(
                        attribute: "feedback",
                        decoration: InputDecoration(labelText: "Availability"),
                        items: ['Low', 'No', 'High']
                            .map((availability) => DropdownMenuItem(
                                  value: availability,
                                  child: Text("$availability"),
                                ))
                            .toList()),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  MaterialButton(
                    child: Text("Submit"),
                    onPressed: () {
                      if (fbKey.currentState.saveAndValidate()) {
                        //TODO Send feedback to backend
                        print(fbKey.currentState.value);
                      }
                    },
                  )
                ],
              )
            ]));
      } else if (snapshot.hasError) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Wimp'),
              backgroundColor: Colors.red[700],
              centerTitle: true,
            ),
            body: Column(children: <Widget>[
              FormBuilder(
                key: fbKey,
                child: Column(
                  children: <Widget>[
                    FormBuilderTextField(
                      attribute: "supermarket",
                      decoration: InputDecoration(labelText: "Supermarket"),
                    ),
                    FormBuilderTextField(
                      attribute: "product",
                      decoration: InputDecoration(labelText: "Product"),
                    ),
                    FormBuilderDropdown(
                        attribute: "feedback",
                        decoration: InputDecoration(labelText: "Availability"),
                        items: ['Low', 'No', 'High']
                            .map((availability) => DropdownMenuItem(
                                  value: availability,
                                  child: Text("$availability"),
                                ))
                            .toList()),
                  ],
                ),
              ),
              Center(
                child: new RaisedButton(
                  onPressed: () {
                    if (fbKey.currentState.saveAndValidate()) {
                      //TODO Send feedback to backend
                      print(fbKey.currentState.value);
                    }
                  },
                  textColor: Colors.white,
                  color: Colors.red,
                  padding: const EdgeInsets.all(8.0),
                  child: new Text(
                    "Submit",
                  ),
                ),
              )
            ]));
      }
      return Scaffold(
          appBar: AppBar(
            title: Text('Wimp'),
            backgroundColor: Colors.red[700],
            centerTitle: true,
          ),
          body: Stack(children: [Center(child: CircularProgressIndicator())]));
    },
  );
}
