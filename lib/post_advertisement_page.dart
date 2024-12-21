import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

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
  String? _selectedBachelor;
  String? _selectedCity;

  Uint8List? _imageBytes;

  final picker = ImagePicker();

  final Map<String, String> bhkChoices = {
    '0': ' ',
    '1': '1BHK',
    '2': '2BHK',
    '3': '3BHK',
    '4': '4BHK',
    '5': '5BHK',
    '6': '6BHK',
    '7': '7BHK',
  };

  final Map<String, String> bachelorChoices = {
    '0': ' ',
    '1': 'YES',
    '2': 'NO',
  };

  final Map<String, String> cityChoices = {
    '0': ' ',
    '1': 'Ambur',
    '2': 'Ariyalur',
    '3': 'Chennai',
    '4': 'Coimbatore',
    '5': 'Cuddalore',
    '6': 'Dharmapuri',
    '7': 'Dindigul',
    '8': 'Erode',
    '9': 'Kanchipuram',
    '10': 'Kanyakumari',
    '11': 'Karur',
    '12': 'Krishnagiri',
    '13': 'Madurai',
    '14': 'Nagapattinam',
    '15': 'Namakkal',
    '16': 'Perambalur',
    '17': 'Pudukkottai',
    '18': 'Ramanathapuram',
    '19': 'Salem',
    '20': 'Sivaganga',
    '21': 'Tenkasi',
    '22': 'Thanjavur',
    '23': 'Theni',
    '24': 'Thoothukudi',
    '25': 'Tiruchirappalli',
    '26': 'Tirunelveli',
    '27': 'Tiruppur',
    '28': 'Tiruvallur',
    '29': 'Tiruvannamalai',
    '30': 'Tiruvarur',
    '31': 'Vellore',
    '32': 'Viluppuram',
    '33': 'Virudhunagar',
  };

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _postAdvertisement() async {
    final String apiUrl = "http://127.0.0.1:8000/api/data/";

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    if (_imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        _imageBytes!,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['BHK'] = _selectedBHK ?? '0'; // Sending mapped value
    request.fields['bachelor'] = _selectedBachelor ?? '0'; // Sending mapped value
    request.fields['location'] = _locationController.text;
    request.fields['city'] = _selectedCity ?? '0'; // Sending mapped value
    request.fields['rent'] = _rentController.text.isNotEmpty
        ? int.parse(_rentController.text).toString()
        : '';
    request.fields['contact'] = _contactController.text;

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Advertisement posted successfully!')),
        );
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}\n$responseBody')),
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
      _selectedBachelor = null;
      _selectedCity = null;
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Advertisement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imageBytes != null
                  ? Image.memory(
                      _imageBytes!,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 50, color: Colors.grey[600]),
                    ),
            ),
            SizedBox(height: 16),
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
              items: bhkChoices.entries
                  .map((entry) =>
                      DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBHK = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedBachelor,
              decoration: InputDecoration(labelText: 'Bachelor Allowed'),
              items: bachelorChoices.entries
                  .map((entry) =>
                      DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBachelor = value;
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
              items: cityChoices.entries
                  .map((entry) =>
                      DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
            ),
            TextField(
              controller: _rentController,
              decoration: InputDecoration(labelText: 'Rent'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _postAdvertisement,
              child: Text('Post Advertisement'),
            ),
          ],
        ),
      ),
    );
  }
}
