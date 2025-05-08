import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parts of Speech Analyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MyHomePage(title: "Parts of Speech Analyzer"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  Future<OutputData>? futureOutput;

  // Helper that joins a list into a comma‑separated string.
  String _join(List<String> words) =>
  words.isEmpty ? '—' : words.join(', ');

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Input text:'),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: myController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste in a piece of text',
                ),
              ),
            ),
            FutureBuilder<OutputData>(
              future: futureOutput,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return DataTable(columns: const [
                    DataColumn(label: Text('Part of Speech', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Words', style: TextStyle(fontWeight: FontWeight.bold))),
                  ], rows: [
                    DataRow(cells: [
                      const DataCell(Text('Nouns')),
                      DataCell(Text(_join(snapshot.data!.nouns))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Proper Nouns')),
                      DataCell(Text(_join(snapshot.data!.nouns)))
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Pronouns')),
                      DataCell(Text(_join(snapshot.data!.prons))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Verbs')),
                      DataCell(Text(_join(snapshot.data!.verbs))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Adjectives')),
                      DataCell(Text(_join(snapshot.data!.adjectives))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Adverbs')),
                      DataCell(Text(_join(snapshot.data!.adverbs))),
                    ]),
                  ],);
                }
                return const Text('Press Fetch');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            futureOutput = fetchData(myController.text);
          });
        },
        child: Text("Parse"),
      ),
    );
  }
}

Future<OutputData> fetchData(String text) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8080/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'text': text}),
  );

  if (response.statusCode == 200) {
    return OutputData.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load words');
  }
}

class OutputData {
  final List<String> nouns;
  final List<String> propns;
  final List<String> prons;
  final List<String> verbs;
  final List<String> adjectives;
  final List<String> adverbs;

  const OutputData({
    required this.nouns,
    required this.propns,
    required this.prons,
    required this.verbs,
    required this.adjectives,
    required this.adverbs,
  });

  factory OutputData.fromJson(Map<String, dynamic> json) {
    List<String> _list(String key) =>
        (json[key] as List<dynamic>).cast<String>();

    return OutputData(
      nouns: _list('nouns'),
      propns: _list('propns'),
      prons: _list('prons'),
      verbs: _list('verbs'),
      adjectives: _list('adjectives'),
      adverbs: _list('adverbs'),
    );
  }
}
