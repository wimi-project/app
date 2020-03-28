import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

Widget getMapPage(mapController, _currentLocationInLatLng, _positionMarker){
  return FlutterMap(
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
  );
}