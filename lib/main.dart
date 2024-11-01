import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:submission_dicoding_decisioner/input-decide.dart';

import 'db/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                        color: Color.fromRGBO(230, 230, 230, 1)
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color.fromRGBO(33, 33, 33, 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(1),
                            offset: const Offset(3, 3), // changes position of shadow
                          ),
                        ],
                        border: Border.all(
                          color: Colors.black,
                          width: 1.25,
                        ),
                      ),
                      child: const IconButton(
                        onPressed: null,
                        iconSize: 20,
                        icon: Icon(
                          CupertinoIcons.arrow_counterclockwise,
                          color: Color.fromRGBO(230, 230, 230, 1),
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: const MyHomePage(),
          )
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _decisions = [];

  @override
  void initState() {
    super.initState();
    _loadDecisions();
  }

  // Memanggil fungsi untuk mendapatkan data dari database
  void _loadDecisions() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getItems();
    if (kDebugMode) {
      print(data);
    }
    setState(() {
      _decisions = data.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: _decisions.isEmpty
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
                  offset: const Offset(5, 5), // changes position of shadow
                ),
              ],
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: ElevatedButton(
              onPressed: () => dialogBuilder(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
                        fontWeight: FontWeight.w600
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
        : ListView.builder(
          itemCount: _decisions.length,
          itemBuilder: (context, index) {
            return DecideResult(_decisions[index]);
          },
        ),
    );
  }
}

class DecideResult extends StatelessWidget {
  final Map<String, dynamic> decision;

  const DecideResult(this.decision, {super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Decision: ${decision['decision']}');
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromRGBO(33, 33, 33, 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(1),
            offset: const Offset(5, 5), // changes position of shadow
          ),
        ],
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: ListTile(
        title: Text(
          decision['decision'],
          style: const TextStyle(
              color: Color.fromRGBO(230, 230, 230, 1),
              fontWeight: FontWeight.w600
          ),
        ),
        subtitle: Text(
          decision['result'],
          style: const TextStyle(
              color: Color.fromRGBO(230, 230, 230, 1)
          ),
        ),
      ),
    );
  }
}
