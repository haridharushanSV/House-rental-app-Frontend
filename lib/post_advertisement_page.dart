import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PostAdvertisementPage extends StatefulWidget {
  @override
  _PostAdvertisementPageState createState() => _PostAdvertisementPageState();
}

class _PostAdvertisementPageState extends State<PostAdvertisementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String? _selectedBHK;
  String? _selectedCity;
  File? _selectedImage;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/data/'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: pickedFile.name,
      ));

      try {
        final response = await request.send();

        if (response.statusCode == 201) {
          final responseData = await response.stream.bytesToString();
          final imageUrl = json.decode(responseData)['url'];

          setState(() {
            _selectedImage = File(pickedFile.path); // Store the file for later use
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image uploaded successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _postAdvertisement() async {
    final String apiUrl = "http://127.0.0.1:8000/api/data/";

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['BHK'] = _selectedBHK ?? '';
    request.fields['location'] = _locationController.text;
    request.fields['city'] = _selectedCity ?? '';
    request.fields['rent'] = _rentController.text;
    request.fields['contact'] = _contactController.text;

    try {
      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Advertisement posted successfully!')),
        );
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post advertisement: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _rentController.clear();
    _contactController.clear();
    setState(() {
      _selectedBHK = null;
      _selectedCity = null;
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: Icon(Icons.add_a_photo, size: 50),
                  ),
          ),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedBHK,
            decoration: InputDecoration(labelText: 'BHK'),
            items: [
              DropdownMenuItem(value: '', child: Text('')),
              for (var bhk in ['1BHK', '2BHK', '3BHK', '4BHK', '5BHK'])
                DropdownMenuItem(value: bhk, child: Text(bhk)),
            ],
            onChanged: (value) {
              setState(() {
                _selectedBHK = value;
              });
            },
          ),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(labelText: 'Location'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(labelText: 'City'),
            items: [
              DropdownMenuItem(value: '', child: Text('')),
              for (var city in ['Chennai', 'Coimbatore', 'Madurai'])
                DropdownMenuItem(value: city, child: Text(city)),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
          ),
          TextField(
            controller: _rentController,
            decoration: InputDecoration(labelText: 'Rent'),
          ),
          TextField(
            controller: _contactController,
            decoration: InputDecoration(labelText: 'Contact'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _postAdvertisement,
            child: Text('Post Advertisement'),
          ),
        ],
      ),
    );
  }
}
