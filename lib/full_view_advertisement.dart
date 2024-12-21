import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';  // Import the carousel_slider package

class DetailPage extends StatelessWidget {
  final dynamic ad;

  DetailPage({required this.ad});

  void _makeCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber?text=Hi, I am interested in your property listing!';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch WhatsApp for $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get a list of photos
        List<String> photos = [ad['photo1'] ?? ''];
    if (ad['photo2'] != null && ad['photo2'] != '') {
      photos.add(ad['photo2']);
    }
    if (ad['photo3'] != null && ad['photo3'] != '') {
      photos.add(ad['photo3']);
    }
    if (ad['photo4'] != null && ad['photo4'] != '') {
      photos.add(ad['photo4']);
    }
    if (ad['photo5'] != null && ad['photo5'] != '') {
      photos.add(ad['photo5']);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(ad['title'] ?? 'Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider to display all photos
              CarouselSlider(
                items: photos.map((url) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.network(
                        url,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, size: 50),
                          );
                        },
                      );
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  autoPlay: false,
                ),
              ),
              SizedBox(height: 16),
              Text(
                ad['title'] ?? 'No Title',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '₹${ad['rent'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text(
                ad['description'] ?? 'No Description',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                ad['bachelor_allowed'] == true
                    ? 'Suitable for Bachelors'
                    : 'Not for Bachelors',
                style: TextStyle(
                  fontSize: 16,
                  color: ad['bachelor_allowed'] == true ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => _makeCall(ad['contact'] ?? ''),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone),
                          SizedBox(width: 8),
                          Text('Call Now'),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => _openWhatsApp(ad['contact'] ?? ''),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat),
                          SizedBox(width: 8),
                          Text('Chat'),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
