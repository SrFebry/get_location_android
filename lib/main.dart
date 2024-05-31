import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get Location',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Get Location'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const LocationWidget(),
    );
  }
}

class LocationWidget extends StatefulWidget {
  const LocationWidget({Key? key}) : super(key: key);

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String _locationMessage = "";
  Position? _currentPosition;

  Future<void> _getCurrentLocation() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentPosition = position;
          _locationMessage =
              'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
        });
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      setState(() {
        _locationMessage = 'Permission denied!';
      });
    }
  }

  Future<void> _showOnMap() async {
    if (_currentPosition != null) {
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}';
      try {
        await launch(googleMapsUrl);
      } catch (e) {
        print('Error launching maps: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_locationMessage),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text('Get Location'),
          ),
          if (_currentPosition != null) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showOnMap,
              child: const Text('Show on Map'),
            ),
          ],
        ],
      ),
    );
  }
}
