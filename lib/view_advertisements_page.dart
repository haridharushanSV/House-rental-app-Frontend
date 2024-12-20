import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewAdvertisementsPage extends StatefulWidget {
  @override
  _ViewAdvertisementsPageState createState() => _ViewAdvertisementsPageState();
}

class _ViewAdvertisementsPageState extends State<ViewAdvertisementsPage> {
  List<dynamic> _advertisements = [];
  List<dynamic> _filteredAdvertisements = [];
  TextEditingController _searchController = TextEditingController();

  // Fetch advertisements from the API
  Future<void> _fetchAdvertisements() async {
    final String apiUrl = "http://127.0.0.1:8000/api/data/";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        _advertisements = json.decode(response.body);
        _filteredAdvertisements = _advertisements; // Initially show all advertisements
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load advertisements')),
      );
    }
  }

  // Filter advertisements based on the location entered in the search bar
  void _filterAdvertisements(String query) {
    final filtered = _advertisements.where((ad) {
      final location = ad['location'] ?? '';
      return location.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredAdvertisements = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();

    // Listen for changes in the search bar and update the filtered results
    _searchController.addListener(() {
      _filterAdvertisements(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rental Houses'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredAdvertisements.length,
              itemBuilder: (context, index) {
                final ad = _filteredAdvertisements[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      ad['photo'] != null && ad['photo'].isNotEmpty
    ? ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          // Check if the photo URL already has the base URL
          ad['photo'].startsWith('http')
              ? ad['photo'] // Use the full URL if it starts with 'http'
              : 'http://127.0.0.1:8000/${ad["photo"]}', // Otherwise, prepend the base URL
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 180,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, size: 50),
            );
          },
        ),
      )
    : Container(
        height: 180,
        color: Colors.grey[300],
        child: Icon(Icons.image_not_supported, size: 50),
      ),

                        const SizedBox(height: 12),
                        Text(
                          ad['title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ad['description'] ?? 'No Description',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.home, size: 18, color: Colors.blueAccent),
                            const SizedBox(width: 5),
                            Text(
                              ad['BHK'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                            const SizedBox(width: 5),
                            Text(
                              ad['location'] ?? 'N/A',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.copy, size: 18, color: Colors.green),
                            const SizedBox(width: 5),
                            Text(
                              ad['city'] ?? 'N/A',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            Spacer(),
                            Icon(Icons.monetization_on, size: 18, color: Colors.orange),
                            const SizedBox(width: 5),
                            Text(
                              '₹${ad['rent'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 18, color: Colors.blue),
                            const SizedBox(width: 5),
                            Text(
                              ad['contact'] ?? 'N/A',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
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
