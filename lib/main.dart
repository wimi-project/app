import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

String apiKey = "AIzaSyBAez6bpIuIpzcJvB5DhocWtrlB1UFzkQw";

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
    }
  }

  @override
  void initState() {
    super.initState();
    geolocator.getPositionStream(locationOptions).listen(
        (Position position) => setState(() => onPositionUpdate(position)));
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
      body: new FlutterMap(
        options: new MapOptions(
          center: _currentLocationInLatLng,
          zoom: 10.0,
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
    ));
  }
}
