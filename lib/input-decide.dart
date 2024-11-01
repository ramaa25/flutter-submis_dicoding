import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:submission_dicoding_decisioner/db/database_helper.dart';
import 'package:submission_dicoding_decisioner/decide_result.dart';
import 'package:submission_dicoding_decisioner/models/my_model.dart';

Future<void> dialogBuilder(BuildContext context) {
  List<TextEditingController> controllers = [
    TextEditingController(),
  ];

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Decide Options'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  ...List.generate(controllers.length, (index) {
                    TextEditingController controller = controllers[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Isi ${index + 1}',
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Tambah TextField dengan TextEditingController baru
                            if (controllers.length < 5) {
                              controllers.add(TextEditingController());
                            }
                          });
                        },
                        child: const Text('Tambah'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Hapus TextField terakhir
                            if (controllers.length > 1) {
                              controllers.removeLast();
                            }
                          });
                        },
                        child: const Text('Kurangi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('Submit'),
                      onPressed: () {
                        var resController = controllers.map((controller) => controller.text).toList();
                        if(kDebugMode) {
                          print(resController);
                        }
                        var random = Random();
                        int randomNumber = random.nextInt(resController.length);
                        String resultDecision = resController[randomNumber];
                        DatabaseHelper().insertItem(MyModel(decisionValue: resController, resultDecision: resultDecision )).then((value) {
                          if(kDebugMode) {
                            print('insert to database success with id: $value');
                          }
                        }).catchError((e) {
                          if(kDebugMode) {
                            print('insert to database failed: $e');
                          }
                        });
                        dialogBuilderResult(context, resultDecision);
                      },
                    ),
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        if(kDebugMode) {
                          var resController = controllers.map(
                            (controller) => controller.text).toList();
                          print(resController);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              )
            ],
          );
        },
      );
    },
  );
}
