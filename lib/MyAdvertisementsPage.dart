import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyAdvertisementsPage extends StatefulWidget {
  @override
  _MyAdvertisementsPageState createState() => _MyAdvertisementsPageState();
}

class _MyAdvertisementsPageState extends State<MyAdvertisementsPage> {
  List<dynamic> _advertisements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();
  }

  Future<void> _fetchAdvertisements() async {
    final String apiUrl = "http://127.0.0.1:8000/api/my-ads/"; // Replace with your endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _advertisements = json.decode(response.body);
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

  Future<void> _deleteAdvertisement(int id) async {
    final String apiUrl = "http://127.0.0.1:8000/api/delete-ad/$id/"; // Replace with your endpoint

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
          : _advertisements.isEmpty
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
    );
  }
}
