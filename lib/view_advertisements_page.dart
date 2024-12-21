import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'full_view_advertisement.dart'; // Import the detailed view

class ViewAdvertisementsPage extends StatefulWidget {
  @override
  _ViewAdvertisementsPageState createState() =>
      _ViewAdvertisementsPageState();
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

  void _showFavorites(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _favoriteAdvertisements.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No favorites added!',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(8.0),
                children: _favoriteAdvertisements.map((ad) {
                  return ListTile(
                    leading: Image.network(
                      ad['photo'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, size: 30),
                        );
                      },
                    ),
                    title: Text(ad['title'] ?? 'No Title'),
                    subtitle: Text(ad['location'] ?? 'No Location'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _favoriteAdvertisements.remove(ad);
                        });
                        Navigator.pop(context); // Close and reopen modal
                        _showFavorites(context);
                      },
                    ),
                  );
                }).toList(),
              );
      },
    );
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
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Rental Houses'),
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: Column(
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
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredAdvertisements.length,
              itemBuilder: (context, index) {
                final ad = _filteredAdvertisements[index];
                final isFavorite = _favoriteAdvertisements.contains(ad);
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(ad: ad),
                    ),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                ad['photo'] ?? '',
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 140,
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '₹${ad['rent'] ?? 'N/A'} / month',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 5),
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
                                            fontSize: 14,
                                            color: Colors.grey[700],
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _toggleFavorite(ad),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFavorites(context),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.favorite, color: Colors.white),
      ),
    );
  }
}
