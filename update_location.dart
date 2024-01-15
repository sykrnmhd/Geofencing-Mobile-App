import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UpdateLocationScreen extends StatefulWidget 
{
  @override
  _UpdateLocationScreenState createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> 
{
  Future<List<Map<String, dynamic>>> loadLocations() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> locationsList = prefs.getStringList('locations') ?? [];
    return locationsList.map((location) => jsonDecode(location) as Map<String, dynamic>).toList();
  }

  Future<void> deleteAllLocations() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('locations');
    setState(() {}); // Update the state of the widget
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text('Update Location'),
        centerTitle: true,
      ),
      body: Padding
      (
        padding: EdgeInsets.only(top: 50, bottom: 50),
        child: Column
        (
          children: <Widget>
          [
            Text('Visited Locations', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Padding
            (
              padding: EdgeInsets.only(bottom: 10), // Add space below the Container
              child: Container
              (
                height: 700, // Adjust this value to make the DataTable bigger
                width: 400,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration
                (
                  color: Color.fromARGB(255, 223, 223, 223),
                  borderRadius: BorderRadius.circular(50), // Add rounded corners
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: loadLocations(),
                  builder: (context, snapshot) 
                  {
                    if (snapshot.connectionState == ConnectionState.waiting) 
                    {
                      return CircularProgressIndicator();
                    } 

                    else if (snapshot.hasError) 
                    
                    {
                      return Text('Error: ${snapshot.error}');
                    } 

                    else 
                    {
                      return SingleChildScrollView
                      (
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView
                        (
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
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
                            rows: snapshot.data!.reversed.map((location) => DataRow
                            (
                              cells: <DataCell>
                              [
                                DataCell(Text(location['latitude'].toString())),
                                DataCell(Text(location['longitude'].toString())),
                              ],
                            )).toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ElevatedButton
          (
            child: Text('Add New Location'),
            onPressed: () 
            {
              // Add your "Add New Location" logic here
            },
          ),
          SizedBox(height: 20), // Add space between the buttons
          ElevatedButton
          (
            child: Text('Delete Location'),
            onPressed: () 
            {
              deleteAllLocations();
            },
          ),
          Expanded
          (
            child: FutureBuilder<List<Map<String, dynamic>>>
            (
              future: loadLocations(),
              builder: (context, snapshot) 
              {
                if (snapshot.connectionState == ConnectionState.waiting) 
                {
                  return CircularProgressIndicator();
                } 
                
                else if (snapshot.hasError) 
                {
                  return Text('Error: ${snapshot.error}');
                } 
                
                else 
                {
                  return ListView.builder
                  (
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) 
                    {
                      return ListTile
                      (
                        title: Text('Latitude: ${snapshot.data![index]['latitude']}, Longitude: ${snapshot.data![index]['longitude']}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
          ],
        ),
      ),
    );
  }
}