import 'package:flutter/material.dart';
import 'package:geolocator_realtime/location_service.dart';
import 'package:geolocator_realtime/user_location.dart';

void main() {
  runApp(GeoApp());
}

class GeoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  LocationService locationService = LocationService();
  @override
  void dispose() {
    locationService.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: const Text('Realtime Update for User Location'),
      ),
      body: StreamBuilder<UserLocation>(
        stream: locationService.locationStream,
        builder: (_, snapshot) => (snapshot.hasData) ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Text(
                'Latitude: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text('${snapshot.data?.latitude}',
              style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20,),
              Text(
                'Longitude: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text('${snapshot.data?.longitude}',
              style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          
        ),
            ): SizedBox()
      ));
  }
}