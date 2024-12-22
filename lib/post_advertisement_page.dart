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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key

  // Controllers for input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // Dropdown selections
  String? _selectedBHK;
  String? _selectedBachelor;
  String? _selectedCity;

  // List to hold multiple images
  List<Uint8List?> _imageBytesList = [];
  final picker = ImagePicker();

  // Dropdown options
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

  // Method to pick images
  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imageBytesList.clear(); // Clear previous images
        for (var pickedFile in pickedFiles) {
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _imageBytesList.add(bytes);
            });
          });
        }
      });
    }
  }

  // Method to post advertisement
  Future<void> _postAdvertisement() async {
    if (!_formKey.currentState!.validate()) {
      return; // If validation fails, do not proceed
    }

    final String apiUrl = "http://127.0.0.1:8000/api/data/";
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    // Add all the selected images to the request
    for (int i = 0; i < _imageBytesList.length; i++) {
      if (_imageBytesList[i] != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'photo${i + 1}', // Dynamically naming the file fields (photo1, photo2, etc.)
          _imageBytesList[i]! ,
          filename: 'image${i + 1}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }
    }

    // Add other form fields
    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['BHK'] = _selectedBHK ?? '0';
    request.fields['bachelor'] = _selectedBachelor ?? '0';
    request.fields['location'] = _locationController.text;
    request.fields['city'] = _selectedCity ?? '0';
    request.fields['rent'] = _rentController.text.isNotEmpty
        ? int.parse(_rentController.text).toString()
        : '';
    request.fields['contact'] = _contactController.text;

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        // Display success message in AlertDialog
        _showSuccessDialog('Advertisement posted successfully!');
        _clearFields();
      } else {
        // Display error message in AlertDialog
        _showErrorDialog('Failed to post advertisement', 'Please Enter All Details');
      }
    } catch (e) {
      // Display error message in AlertDialog
      _showErrorDialog('Error', e.toString());
    }
  }

  // Helper method to show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to clear input fields
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
      _imageBytesList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Advertisement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: _imageBytesList.isNotEmpty
                    ? Wrap(
                        spacing: 8.0,
                        children: _imageBytesList.map((imageBytes) {
                          return Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: MemoryImage(imageBytes!),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }).toList(),
                      )
                    : Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 50, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              DropdownButtonFormField<String>(
                value: _selectedBHK,
                decoration: const InputDecoration(labelText: 'BHK'),
                items: bhkChoices.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBHK = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedBachelor,
                decoration: const InputDecoration(labelText: 'Bachelor Allowed'),
                items: bachelorChoices.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBachelor = value;
                  });
                },
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(labelText: 'City'),
                items: cityChoices.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
              TextField(
                controller: _rentController,
                decoration: const InputDecoration(labelText: 'Rent'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact number is required';
                  }
                  final regex = RegExp(r'^\d{10}$');
                  if (!regex.hasMatch(value)) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _postAdvertisement,
                child: const Text('Post Advertisement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
