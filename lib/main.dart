import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:wimp/rest/supermarketsApi.dart';

import 'model/productModel.dart';
import 'model/supermarketModel.dart';
import 'pages/feedback.dart';
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

  List<SupermarketModel> _allSupermarkets;
  List<SupermarketModel> _supermarketsShown;
  Future<List<SupermarketModel>> supermarketsFetch;
  final supermarketFilterController = TextEditingController();

  List<BottomNavigationBarItem> _bottomBarOptions = <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.place), title: Text('Map')),
    BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart), title: Text('Supermarkets')),
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

    supermarketsFetch = SupermarketApi.getClosestSupermarkets();
    supermarketFilterController.addListener(onFilterSupermarket);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    productFilterController.dispose();
    supermarketFilterController.dispose();
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
    });
  }

  Widget mainWidget(int index) {
    switch (index) {
      case 0:
        return getMapPage();
      case 1:
        return getSupermarketsPage();
      case 2:
        return getProductsPage();
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
            // For example purposes. It is recommended to use
            // TileProvider with a caching and retry strategy, like
            // NetworkTileProvider or CachedNetworkTileProvider
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FeedbackState()));
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
                          color: Colors.white, size: 30.0));
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
    if (feedback == null) {
      return "Unknown";
    }
    return feedback;
  }

  Widget getSupermarketsPage() {
    return MaterialApp(
      home: FutureBuilder<List<SupermarketModel>>(
          future: supermarketsFetch,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _allSupermarkets = snapshot.data;
              if (_supermarketsShown == null) {
                _supermarketsShown = _allSupermarkets;
              }
              return FloatingSearchBar.builder(
                itemCount: _supermarketsShown.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      leading: Container(
                          child: Icon(Icons.shopping_cart,
                              color: Colors.deepOrange)),
                      title: Text(
                        _supermarketsShown.elementAt(index).name,
                        style: TextStyle(
                            color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right,
                          color: Colors.white, size: 30.0));
                },
                controller: supermarketFilterController,
              );
            } else if (snapshot.hasError) {
              return Scaffold(body: Text("Can't fetch the data"));
            }
            return Stack(
                children: [Center(child: CircularProgressIndicator())]);
          }),
    );
  }

  void onFilterSupermarket() {
    if (supermarketFilterController.text.isNotEmpty) {
      List<SupermarketModel> searchResultData = List<SupermarketModel>();
      _allSupermarkets.forEach((supermarket) {
        if (supermarket.name
            .toLowerCase()
            .contains(supermarketFilterController.text.toLowerCase())) {
          searchResultData.add(supermarket);
        }
      });
      setState(() {
        _supermarketsShown = searchResultData;
      });
    } else {
      setState(() {
        _supermarketsShown = _allSupermarkets;
      });
    }
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
        body: mainWidget(_selectedIndex),
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

class FeedbackState extends StatelessWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return getFeedbackPage(_fbKey);
  }
}
