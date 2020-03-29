import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:wimp/rest/feedbacksApi.dart';
import 'package:wimp/rest/storesApi.dart';

import 'model/productModel.dart';
import 'model/storeModel.dart';
import 'model/storesAndProductsModel.dart';
import 'rest/productsApi.dart';

void main() => runApp(Wimp());

class Wimp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Map Place Demo',
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  int _selectedPage = 0;
  MapController mapController;
  LatLng _currentLocationInLatLng = new LatLng(45.0, 8.0);
  Marker _positionMarker = new Marker(
      width: 20.0,
      height: 20.0,
      point: new LatLng(45.0, 8.0),
      builder: (ctx) => new Container(
            child: new FlutterLogo(),
          ));
  var geolocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  bool firstPositionAcquisition = true;

  List<ProductModel> _allProducts;
  List<ProductModel> _productsShown;
  Future<List<ProductModel>> productsFetch;
  final productFilterController = TextEditingController();
  ProductModel productSelected;
  Future<List<StoreModel>> storesAvailabilityFetch;
  List<StoreModel> storesWithAvailabilityForProduct;

  List<StoreModel> _allStores;
  List<StoreModel> _storesShown;
  Future<List<StoreModel>> storesFetch;
  final storeFilterController = TextEditingController();
  StoreModel storeSelected;

  List<BottomNavigationBarItem> _bottomBarOptions = <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.place), title: Text('Map')),
    BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart), title: Text('Stores')),
    BottomNavigationBarItem(icon: Icon(Icons.toc), title: Text('Products')),
  ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    geolocator.getPositionStream(locationOptions).listen(
        (Position position) => setState(() => onPositionUpdate(position)));

    productsFetch = ProductApi.getClosestProducts();
    productFilterController.addListener(onFilterProduct);

    storesFetch = StoreApi.getClosestStores();
    storeFilterController.addListener(onFilterStore);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    productFilterController.dispose();
    storeFilterController.dispose();
    super.dispose();
  }

  void onPositionUpdate(Position position) {
    if (position != null) {
      _currentLocationInLatLng =
          new LatLng(position.latitude, position.longitude);
      _positionMarker = new Marker(
          width: 20.0,
          height: 20.0,
          point: _currentLocationInLatLng,
          builder: (ctx) => new Container(
                child: new FlutterLogo(),
              ));
      if (firstPositionAcquisition) {
        mapController.move(_currentLocationInLatLng, 18.0);
        firstPositionAcquisition = false;
      }
    }
  }

  void _onBottomItemTapped(int value) {
    setState(() {
      _selectedIndex = value;
      _selectedPage = value;
    });
  }

  Widget getMainWidget(int index) {
    switch (index) {
      case 0:
        return getMapPage();
      case 1:
        return getStoresPage();
      case 2:
        return getProductsPage();
      case 3:
        return getStoreDetailPage();
      case 4:
        return getProductDetailPage();
    }
  }

  Widget getMapPage() {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: _currentLocationInLatLng,
          zoom: 18.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            tileProvider: CachedNetworkTileProvider(),
          ),
          MarkerLayerOptions(
            markers: [
              _positionMarker,
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FeedbackPage()));
        },
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget getProductsPage() {
    return MaterialApp(
      home: FutureBuilder<List<ProductModel>>(
          future: productsFetch,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _allProducts = snapshot.data;
              if (_productsShown == null) {
                _productsShown = _allProducts;
              }
              return FloatingSearchBar.builder(
                itemCount: _productsShown.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      leading: Container(
                          child: getImageWidget(
                              _productsShown.elementAt(index).imgUrl)),
                      title: Text(
                        _productsShown.elementAt(index).name,
                        style: TextStyle(
                            color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          getFeedback(_productsShown.elementAt(index).feedback),
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      trailing: Icon(Icons.keyboard_arrow_right,
                          color: Colors.white, size: 30.0),
                      onTap: () =>
                          onProductTapped(_productsShown.elementAt(index)));
                },
                controller: productFilterController,
              );
            } else if (snapshot.hasError) {
              return Scaffold(body: Text("Can't fetch the data"));
            }
            return Stack(
                children: [Center(child: CircularProgressIndicator())]);
          }),
    );
  }

  void onFilterProduct() {
    if (productFilterController.text.isNotEmpty) {
      List<ProductModel> searchResultData = List<ProductModel>();
      _allProducts.forEach((product) {
        if (product.name
            .toLowerCase()
            .contains(productFilterController.text.toLowerCase())) {
          searchResultData.add(product);
        }
      });
      setState(() {
        _productsShown = searchResultData;
      });
    } else {
      setState(() {
        _productsShown = _allProducts;
      });
    }
  }

  void onProductTapped(ProductModel productModel) {
    setState(() {
      productSelected = productModel;
      _selectedPage = 4;
      storesAvailabilityFetch = StoreApi.getClosestStoresGivenProduct(
          productSelected, _currentLocationInLatLng);
    });
  }

  Widget getImageWidget(imgUrl) {
    if (imgUrl == null) {
      return Icon(Icons.shopping_cart, color: Colors.red, size: 30.0);
    }
    return Image.network(
      imgUrl,
      filterQuality: FilterQuality.low,
    );
  }

  String getFeedback(feedback) {
    if (feedback == null || feedback == "null") {
      return "Unknown";
    }
    return feedback;
  }

  Widget getStoresPage() {
    return MaterialApp(
      home: FutureBuilder<List<StoreModel>>(
          future: storesFetch,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _allStores = snapshot.data;
              if (_storesShown == null) {
                _storesShown = _allStores;
              }
              return FloatingSearchBar.builder(
                itemCount: _storesShown.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      leading: Container(
                          child: Icon(Icons.shopping_cart,
                              color: Colors.deepOrange)),
                      title: Text(
                        _storesShown.elementAt(index).name,
                        style: TextStyle(
                            color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right,
                          color: Colors.white, size: 30.0),
                      onTap: () =>
                          onStoreTapped(_storesShown.elementAt(index)));
                },
                controller: storeFilterController,
              );
            } else if (snapshot.hasError) {
              return Scaffold(body: Text("Can't fetch the data"));
            }
            return Stack(
                children: [Center(child: CircularProgressIndicator())]);
          }),
    );
  }

  void onFilterStore() {
    if (storeFilterController.text.isNotEmpty) {
      List<StoreModel> searchResultData = List<StoreModel>();
      _allStores.forEach((store) {
        if (store.name
            .toLowerCase()
            .contains(storeFilterController.text.toLowerCase())) {
          searchResultData.add(store);
        }
      });
      setState(() {
        _storesShown = searchResultData;
      });
    } else {
      setState(() {
        _storesShown = _allStores;
      });
    }
  }

  void onStoreTapped(StoreModel storeModel) {
    setState(() {
      storeSelected = storeModel;
      _selectedPage = 3;
    });
  }

  Widget getStoreDetailPage() {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline
        .copyWith(color: Colors.black87, fontWeight: FontWeight.bold);
    final TextStyle descriptionStyle = theme.textTheme.subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 184,
          child: Stack(
            children: [
              Positioned.fill(
                // In order to have the ink splash appear above the image, you
                // must use Ink.image. This allows the image to be painted as
                // part of the Material and display ink effects above it. Using
                // a standard Image will obscure the ink splash.
                child: Ink.image(
                  image: AssetImage('lib/assets/coop.png'),
                  fit: BoxFit.cover,
                  child: Container(),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    storeSelected.name,
                    style: titleStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Description and share/explore buttons.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: descriptionStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // This array contains the three line description on each card
                // demo.
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(storeSelected.address),
                ),
                Text(
                  "QUEUE TIME: " +
                      getFeedback(storeSelected.queueTime.toString()),
                  style: descriptionStyle.copyWith(
                      color: Colors.black54, fontStyle: FontStyle.italic),
                ),
                /*ListView.builder(
                  itemCount: ,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(storeSelected),
                    );
                  },
                )*/
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getProductDetailPage() {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline
        .copyWith(color: Colors.black87, fontWeight: FontWeight.bold);
    final TextStyle descriptionStyle = theme.textTheme.subtitle;

    return FutureBuilder<List<StoreModel>>(
        future: storesAvailabilityFetch,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            storesWithAvailabilityForProduct = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 184,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        // In order to have the ink splash appear above the image, you
                        // must use Ink.image. This allows the image to be painted as
                        // part of the Material and display ink effects above it. Using
                        // a standard Image will obscure the ink splash.
                        child: Ink.image(
                          image: AssetImage('lib/assets/coop.png'),
                          fit: BoxFit.cover,
                          child: Container(),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            productSelected.name,
                            style: titleStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Description and share/explore buttons.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: DefaultTextStyle(
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: descriptionStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // This array contains the three line description on each card
                        // demo.
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(productSelected.description),
                        ),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: storesWithAvailabilityForProduct.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(storesWithAvailabilityForProduct
                                      .elementAt(index)
                                      .name +
                                  " - " +
                                  storesWithAvailabilityForProduct
                                      .elementAt(index)
                                      .address),
                              subtitle: Text(
                                storesWithAvailabilityForProduct
                                    .elementAt(index)
                                    .availability
                                    .replaceAll('_', ' '),
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Stack(children: [Center(child: CircularProgressIndicator())]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Wimp'),
          backgroundColor: Colors.red[700],
          centerTitle: true,
        ),
        body: getMainWidget(_selectedPage),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: true,
          items: _bottomBarOptions,
          backgroundColor: Colors.red,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white,
          onTap: _onBottomItemTapped,
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  @override
  State<FeedbackPage> createState() => FeedbackState();
}

class FeedbackState extends State<FeedbackPage> {
  int _currentPage = 0;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final productsFetch = ProductApi.getClosestProducts();
  final storesFetch = StoreApi.getClosestStores();
  List<ProductModel> _products;
  List<StoreModel> _stores;

  Future<bool> _futurePostResult;

  Widget getMainWidget(int index) {
    switch (index) {
      case 0:
        return getFeedbackPage();
      case 1:
        return getFeedbackGivenPage();
    }
  }

  Widget getFeedbackPage() {
    List<DropdownMenuItem> productItems = _products
        .map((product) => DropdownMenuItem(
              value: product.id,
              child: Text(product.name),
            ))
        .toList();

    List<DropdownMenuItem> storeItems = _stores
        .map((store) => DropdownMenuItem(
              value: store.id,
              child: Text(store.name),
            ))
        .toList();

    return Column(children: <Widget>[
      FormBuilder(
        key: _fbKey,
        child: Column(
          children: <Widget>[
            FormBuilderDropdown(
                attribute: "store",
                decoration: InputDecoration(labelText: "Store"),
                items: storeItems),
            FormBuilderDropdown(
                attribute: "product",
                decoration: InputDecoration(labelText: "Product"),
                items: productItems),
            FormBuilderDropdown(
                attribute: "feedback",
                decoration: InputDecoration(labelText: "Availability"),
                items: ['No availability', 'Low availability']
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
            if (_fbKey.currentState.saveAndValidate()) {
              print(_fbKey.currentState.value);
              onSubmit(FeedbackApi.postFeedback(_fbKey.currentState.value));
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
    ]);
  }

  Widget getLoadingPage() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Wimp'),
          backgroundColor: Colors.red[700],
          centerTitle: true,
        ),
        body: Stack(children: [Center(child: CircularProgressIndicator())]));
  }

  Widget getFeedbackGivenPage() {
    return MaterialApp(
      home: FutureBuilder<bool>(
          future: _futurePostResult,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data) {
              return SafeArea(
                child: Scaffold(
                  body: Center(
                    child: Text(
                      'Thank you for the feedback! ^^',
                      style: TextStyle(fontSize: 18.0, color: Colors.red),
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Scaffold(body: Text("Error posting the feedback"));
            }
            return Stack(
                children: [Center(child: CircularProgressIndicator())]);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([storesFetch, productsFetch]).then((response) =>
          new StoresAndProducts(stores: response[0], products: response[1])),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _products = snapshot.data.products;
          _stores = snapshot.data.stores;

          return Scaffold(
              appBar: AppBar(
                title: Text('Wimp'),
                backgroundColor: Colors.red[700],
                centerTitle: true,
              ),
              body: getMainWidget(_currentPage));
        } else if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Wimp'),
                backgroundColor: Colors.red[700],
                centerTitle: true,
              ),
              body: Column(children: <Widget>[
                FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        attribute: "store",
                        decoration: InputDecoration(labelText: "Store"),
                      ),
                      FormBuilderTextField(
                        attribute: "product",
                        decoration: InputDecoration(labelText: "Product"),
                      ),
                      FormBuilderDropdown(
                          attribute: "feedback",
                          decoration:
                              InputDecoration(labelText: "Availability"),
                          items: [
                            'No availability',
                            'Low availability',
                            'High availability'
                          ]
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
                      if (_fbKey.currentState.saveAndValidate()) {
                        //TODO Send feedback to backend
                        print(_fbKey.currentState.value);
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

        return getLoadingPage();
      },
    );
  }

  void onSubmit(Future<bool> postFeedback) {
    setState(() {
      _futurePostResult = postFeedback;
      _currentPage = 1;
    });
  }
}
