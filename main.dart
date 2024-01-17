import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'update_location.dart'; // Import the update_location.dart file
import 'location_service.dart';
import 'user_location.dart';


void main() 
{
  runApp(const MainApp());
}

class MainApp extends StatelessWidget 
{
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      debugShowCheckedModeBanner: false,
      theme: ThemeData
      (
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget 
{
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> 
{
  List<Map<String, double>> locations = [];
  String message = '';

  bool isLoading = false;

  LocationService locationService = LocationService();

  final Map<String, dynamic> certainArea = 
  {
  'latitude': 3.2472606, 
  'longitude': 101.739514, 
  'radius': 100.0 // Radius in meters
  }; // Replace with your values

  @override

  void dispose() 
  {
    locationService.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar
      (
        title: Text('Geofencing Application'),
        centerTitle: true, // Center the title
      ),
      body: Column
      (
        children: <Widget>
        [
          Padding
          (
            padding: EdgeInsets.only(top: 20), // Add space between AppBar and container
            child: Container
            (
              width: 400, // Set width of the container
              height: 100, // Set height of the container
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration
              (
                color: Color.fromARGB(255, 223, 223, 223),
                borderRadius: BorderRadius.circular(10), // Add rounded corners
              ),
              child: Center
              ( // Center the text inside the container
                child: Text
                (
                  'App Instructions: Press the button to get and save your current location.', 
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center, // Center align the text
                ),
              ),
            ),
          ),
          Expanded
          (
            child: Center
            (
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>
                [
                  StreamBuilder<UserLocation>
                  (
                    stream: locationService.locationStream,
                    builder: (context, snapshot) 
                    {
                      if (snapshot.hasData) 
                      {
                        return Text('Latitude: ${snapshot.data!.latitude}, Longitude: ${snapshot.data!.longitude}');
                      } 
                      
                      else 
                      {
                        return Text('Getting location...');
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton
                  (
                    child: isLoading ? CircularProgressIndicator() : Text('Save Location'),
                    onPressed: isLoading ? null : () async 
                    {
                      setState(() 
                      {
                        isLoading = true;
                      });
                      Position currentLocationData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                      Map<String, double> location = 
                      {
                        'latitude': currentLocationData.latitude,
                        'longitude': currentLocationData.longitude,
                      };
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      List<String> locationsList = prefs.getStringList('locations') ?? [];
                      locationsList.add(jsonEncode(location));
                      prefs.setStringList('locations', locationsList);
                      setState(() 
                      {
                        locations.add(location);
                        isLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar
                      (
                        SnackBar
                        (
                          content: Text('Your location has been saved'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                  Text(message),
                ],
              ),
            ),
          ),
          Container
          (
            padding: EdgeInsets.only(bottom: 100),
            child: Column
            (
              children: <Widget>
              [
                Text('Saved Locations', style: TextStyle(fontSize: 24)),
                Padding
                (
                  padding: EdgeInsets.only(bottom: 10), // Add space below the Container
                  child: Container
                  (
                    height: 300, // Adjust this value to make the DataTable bigger
                    width: 400,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration
                    (
                      color: Color.fromARGB(255, 223, 223, 223),
                      borderRadius: BorderRadius.circular(50), // Add rounded corners
                    ),
                    child: DataTable
                    (
                      columns: const <DataColumn>
                      [
                        DataColumn
                        (
                          label: Text('Latitude'),
                        ),
                        DataColumn
                        (
                          label: Text('Longitude'),
                        ),
                      ],
                      rows: locations.reversed.take(3).map((location) => DataRow
                      (
                        cells: <DataCell>
                        [
                          DataCell(Text(location['latitude'].toString())),
                          DataCell(Text(location['longitude'].toString())),
                        ],
                      )).toList(),
                    ),
                  ),
                ),
                ElevatedButton
                (
                  child: Text('Go to Update Location Screen'),
                  onPressed: () 
                  {
                    Navigator.push
                    (
                      context,
                      MaterialPageRoute(builder: (context) => UpdateLocationScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
