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

  // Show the favorites list in a bottom sheet
  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return _favoriteAdvertisements.isEmpty
            ? Center(child: Text('No favorites added yet.'))
            : Container(
                height: MediaQuery.of(context).size.height * 0.5, // Half the screen
                child: ListView.builder(
                  itemCount: _favoriteAdvertisements.length,
                  itemBuilder: (context, index) {
                    final ad = _favoriteAdvertisements.elementAt(index);
                    return Dismissible(
                      key: Key(ad['id'].toString()), // Use a unique key
                      onDismissed: (direction) {
                        setState(() {
                          _favoriteAdvertisements.remove(ad);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Removed from favorites')),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      child: ListTile(
                        title: Text(ad['title'] ?? 'No Title'),
                        subtitle: Text('₹${ad['rent'] ?? 'N/A'}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(ad: ad),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final childAspectRatio = screenWidth < 415 ? 0.7 : 0.8;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Advertisements'),
      //   backgroundColor: Colors.blueAccent,
      // ),
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
                  final isFavorite = _favoriteAdvertisements.contains(ad);
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
                            child: Stack(
                              children: [
                                Image.network(
                                  ad['photo1'] ?? '',
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
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _toggleFavorite(ad),
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
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
        onPressed: _showFavorites, // Open favorites list
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.favorite),
      ),
    );
  }
}
