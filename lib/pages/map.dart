import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:wimp/main.dart';

Widget getMapPage(context, mapController, _currentLocationInLatLng, _positionMarker) {
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackState()));
      },
      backgroundColor: Colors.red,
    ),
  );
}
