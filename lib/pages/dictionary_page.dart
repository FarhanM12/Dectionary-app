import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DictionaryPage extends StatefulWidget {
  final String name; // Define 'name' parameter

  DictionaryPage({required this.name, Key? key}) : super(key: key); // Constructor with 'name' parameter

  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _controller = TextEditingController();
  String _definition = "";
  List<String> _examples = [];
  List<String> _synonyms = [];
  List<String> _antonyms = [];
  bool _isLoading = false;

  void _searchWord(String word) async {
    if (word.isEmpty) {
      setState(() {
        _definition = "Please enter a word to search.";
        _examples = [];
        _synonyms = [];
        _antonyms = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _definition = "";
      _examples = [];
      _synonyms = [];
      _antonyms = [];
    });

    final response = await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _definition = data[0]['meanings'][0]['definitions'][0]['definition'];

        if (data[0]['meanings'][0]['definitions'][0]['example'] != null) {
          _examples.add(data[0]['meanings'][0]['definitions'][0]['example']);
        }

        if (data[0]['meanings'][0]['definitions'][0]['synonyms'] != null) {
          _synonyms.addAll(List<String>.from(data[0]['meanings'][0]['definitions'][0]['synonyms']));
        }

        if (data[0]['meanings'][0]['definitions'][0]['antonyms'] != null) {
          _antonyms.addAll(List<String>.from(data[0]['meanings'][0]['definitions'][0]['antonyms']));
        }

        _isLoading = false;
      });
    } else {
      setState(() {
        _definition = "Word not found";
        _examples = [];
        _synonyms = [];
        _antonyms = [];
        _isLoading = false;
      });
    }
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return items.isEmpty
        ? Container()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        ...items.map((item) => Text(item)).toList(),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Dictionary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _searchWord(_controller.text);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // App Icon
                  Icon(
                    Icons.book,
                    size: 100,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  // Search Field
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Enter a word',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          color: Colors.blueAccent,
                          onPressed: () {
                            _searchWord(_controller.text);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Search Result
                  _isLoading
                      ? CircularProgressIndicator()
                      : Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _definition,
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        _buildInfoSection('Examples:', _examples),
                        _buildInfoSection('Synonyms:', _synonyms),
                        _buildInfoSection('Antonyms:', _antonyms),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Example or Additional Functionality
                  ElevatedButton(
                    onPressed: () {
                      // Add your functionality here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('This could be additional functionality!'),
                        ),
                      );
                    },
                    child: Text('Explore More'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



