import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:submission_dicoding_decisioner/input_decide.dart';
import 'package:submission_dicoding_decisioner/models/my_model.dart';

import 'db/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<MyModel> decisionsData = [];
  bool isLoading = true;

  // Fungsi untuk memuat data dari database
  void _loadDecisions() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getItems();
    setState(() {
      decisionsData = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDecisions(); // Load data saat aplikasi pertama kali berjalan
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decisioner',
      theme: ThemeData(
        textTheme: GoogleFonts.dmSansTextTheme(),
      ),
      home: Container(
        color: Theme.of(context).canvasColor,
        child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Decisioner',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(230, 230, 230, 1),
                      ),
                    ),
                    if (decisionsData.isNotEmpty)
                      const Text(
                        'Swipe card to delete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              body: MyHomePage(
                decisionsData: decisionsData,
                onLoadDecisions: _loadDecisions,
                isLoading: isLoading,// Berikan akses ke _loadDecisions
              ),
              floatingActionButton:
                Material(
                  color: Colors.transparent,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadowColor: Colors.white.withOpacity(0.5),
                  child : MyFloatingActionButton(
                    decisions: decisionsData,
                    loadDecisions: _loadDecisions, // Berikan akses ke _loadDecisions
                  )
                  )
            )),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<MyModel> decisionsData;
  final VoidCallback onLoadDecisions;
  final bool isLoading;

  const MyHomePage({super.key, required this.decisionsData, required this.onLoadDecisions, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: isLoading
        ? const Center(child: CircularProgressIndicator())
        : decisionsData.isEmpty
          ? Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.65,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color.fromRGBO(33, 33, 33, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(1),
                  offset: const Offset(5, 5), // Posisi bayangan
                ),
              ],
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: ElevatedButton(
              onPressed: () => dialogBuilder(context, onLoadDecisions),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(15),
                backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(
                    CupertinoIcons.add,
                    color: Color.fromRGBO(230, 230, 230, 1),
                  ),
                  Text(
                    'Buat keputusan baru',
                    style: TextStyle(
                      color: Color.fromRGBO(230, 230, 230, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          : ListView.builder(
        itemCount: decisionsData.length,
        itemBuilder: (context, index) {
          final item = decisionsData[index];
          return Dismissible(
              key: Key(item.id.toString()),
              onDismissed: (direction) {
                final dbHelper = DatabaseHelper();
                dbHelper.deleteItem(decisionsData[index].id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Decision deleted'),
                  ),
                );
                onLoadDecisions();
              },
              child: DecideResult(decisionsData[index]));
        },
      )
    );
  }
}

class DecideResult extends StatelessWidget {
  final MyModel decision;

  const DecideResult(this.decision, {super.key});

  @override
  Widget build(BuildContext context) {
    // Print decision for debugging purposes
    if (kDebugMode) {
      print('Decision: ${decision.decisionValue}');
    }

    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 16.0), // Margin between cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      elevation: 5, // Shadow elevation
      color: const Color.fromRGBO(33, 33, 33, 1), // Background color
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(16.0), // Padding inside the ListTile
        title: Text(
          decision.resultDecision, // Fallback for null decision
          style: const TextStyle(
              color: Color.fromRGBO(230, 230, 230, 1),
              fontWeight: FontWeight.w600,
              fontSize: 18 // Increased font size for better visibility
              ),
        ),
        subtitle: Text(
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1315337671.
          decision.decisionValue.join(', '), // Fallback for null result
          style: const TextStyle(
              color: Color.fromRGBO(230, 230, 230, 1),
              fontSize: 14 // Adjusted font size
              ),
        ),
        onTap: () {
          // Add any action on tap, if needed
        },
      ),
    );
  }
}

class MyFloatingActionButton extends StatelessWidget {
  final List<MyModel> decisions;
  final VoidCallback loadDecisions;

  const MyFloatingActionButton({
    super.key,
    required this.decisions,
    required this.loadDecisions,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: decisions.isNotEmpty,
      child: FloatingActionButton(
        onPressed: () {
          dialogBuilder(context, loadDecisions); // Panggil loadDecisions
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        child: const Icon(
          CupertinoIcons.add,
          color: Color.fromRGBO(230, 230, 230, 1),
        ),
      ),
    );
  }
}

