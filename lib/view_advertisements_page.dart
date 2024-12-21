import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'full_view_advertisement.dart';

class ViewAdvertisementsPage extends StatefulWidget {
  @override
  _ViewAdvertisementsPageState createState() => _ViewAdvertisementsPageState();
}

class _ViewAdvertisementsPageState extends State<ViewAdvertisementsPage> {
  List<dynamic> _advertisements = [];
  List<dynamic> _filteredAdvertisements = [];
  Set<dynamic> _favoriteAdvertisements = {}; // Store favorites
  TextEditingController _searchController = TextEditingController();

  Future<void> _fetchAdvertisements() async {
    final String apiUrl = "http://127.0.0.1:8000/api/data/";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        _advertisements = json.decode(response.body);
        _filteredAdvertisements = _advertisements;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load advertisements')),
      );
    }
  }

  void _filterAdvertisements(String query) {
    final filtered = _advertisements.where((ad) {
      final location = ad['location'] ?? '';
      return location.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredAdvertisements = filtered;
    });
  }

  void _toggleFavorite(dynamic ad) {
    setState(() {
      if (_favoriteAdvertisements.contains(ad)) {
        _favoriteAdvertisements.remove(ad);
      } else {
        _favoriteAdvertisements.add(ad);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final childAspectRatio = screenWidth < 415 ? 0.7 : 0.8;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by location',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: _filteredAdvertisements.length,
                itemBuilder: (context, index) {
                  final ad = _filteredAdvertisements[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(ad: ad),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.network(
                              ad['photo'] ?? '',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image, size: 50),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ad['title'] ?? 'No Title',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '₹${ad['rent'] ?? 'N/A'} / month',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 14, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        ad['location'] ?? 'No Location',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action for favorites
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.favorite),
      ),
    );
  }
}
