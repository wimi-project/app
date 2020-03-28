import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import 'pages/map.dart';
import 'pages/products.dart';
import 'pages/supermarkets.dart';

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
    switch(index){
      case 0:
        return getMapPage(mapController, _currentLocationInLatLng, _positionMarker);
      case 1:
        return getSupermarketsPage();
      case 2:
        return getProductsPage();
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
