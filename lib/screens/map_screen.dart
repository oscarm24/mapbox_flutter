// mapa con ubicacion actual y zoom
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';


const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? myPosition;
  late MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    getCurrentLocation();
  }

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
       print(myPosition);
    });
  }

  void zoomIn() {
    mapController.move(
        mapController.camera.center, mapController.camera.zoom + 1);
  }

  void zoomOut() {
    mapController.move(
        mapController.camera.center, mapController.camera.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ubicación actual'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: zoomOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: myPosition == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: myPosition!,
                      minZoom: 5,
                      maxZoom: 20,
                      initialZoom: 10,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                        additionalOptions: const {
                          'accessToken': MAPBOX_ACCESS_TOKEN,
                          'id': 'mapbox/streets-v12',
                        },
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: myPosition!,
                            child: const Icon(
                              Icons.person_pin,
                              color: Colors.blueAccent,
                              size: 40,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}