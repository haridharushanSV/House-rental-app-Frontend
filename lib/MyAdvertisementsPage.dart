import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; 

class MyAdvertisementsPage extends StatefulWidget {
  @override
  _MyAdvertisementsPageState createState() => _MyAdvertisementsPageState();
}

class _MyAdvertisementsPageState extends State<MyAdvertisementsPage> {
  List<dynamic> _advertisements = [];
  bool _isLoading = true;
  String? _userUid;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUserDetails();  // Fetch the current user's details from Firebase
  }

  // Method to get the current user's UID and details from Firebase
  Future<void> _getCurrentUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get current Firebase user
      if (user != null) {
        setState(() {
          _userUid = user.uid; // Set the user UID
          _currentUser = user; // Set the current user
        });
        await _fetchAdvertisements();  // Fetch advertisements after getting the UID
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting user details: $e')),
      );
    }
  }

  // Method to fetch advertisements and filter by user UID
  Future<void> _fetchAdvertisements() async {
    final String apiUrl = "http://127.0.0.1:8000/api/data/"; // Use 10.0.2.2 for emulator

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> ads = json.decode(response.body);

        // Filter advertisements by user UID
        setState(() {
          _advertisements = ads.where((ad) => ad['uid'] == _userUid).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load advertisements');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  // Method to delete an advertisement
  Future<void> _deleteAdvertisement(int id) async {
    final String apiUrl = "http://127.0.0.1:8000/api/data/$id"; // Add the advertisement id in the URL (use 10.0.2.2 for emulator)

    try {
      final response = await http.delete(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Advertisement deleted successfully!')),
        );
        setState(() {
          _advertisements.removeWhere((ad) => ad['id'] == id);
        });
      } else {
        throw Exception('Failed to delete advertisement');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting advertisement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Advertisements'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Display user details
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _currentUser != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${_currentUser?.displayName ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                            Text('Email: ${_currentUser?.email ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                          ],
                        )
                      : Container(),
                ),
                // Display advertisements
                Expanded(
                  child: _advertisements.isEmpty
                      ? Center(child: Text('No advertisements found'))
                      : ListView.builder(
                          itemCount: _advertisements.length,
                          itemBuilder: (context, index) {
                            final ad = _advertisements[index];
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(ad['title']),
                                subtitle: Text(ad['description']),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteAdvertisement(ad['id']),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
