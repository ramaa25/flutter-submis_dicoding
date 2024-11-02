import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:submission_dicoding_decisioner/db/database_helper.dart';
import 'package:submission_dicoding_decisioner/models/my_model.dart';

Future<void> showLoadingDialog(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false, // Jangan biarkan pengguna menutup loading dialog
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

Future<void> dialogBuilderResult(BuildContext context, List<String> resController, Function onDataInserted) async {
  // Tampilkan dialog loading
  await showLoadingDialog(context);

  var random = Random();
  int randomNumber = random.nextInt(resController.length);
  String resultDecision = resController[randomNumber];

  // Simulasikan proses loading, lalu tutup dialog loading setelah selesai
  await Future.delayed(const Duration(seconds: 2));

  // Tutup dialog loading
  if (context.mounted) {
    Navigator.of(context).pop(); // Menutup dialog loading
    Navigator.of(context).pop(); // Menutup dialog utama

    // Tampilkan dialog utama setelah loading selesai
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
              title: const Text('Decision Result', style: TextStyle(color: Colors.white),),
              content: SizedBox.fromSize(
                size: const Size.fromHeight(25),
                child: Center(
                  child: Text(resultDecision, style: const TextStyle(color: Colors.white, fontSize: 20),)
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        DatabaseHelper()
                            .insertItem(MyModel(
                            decisionValue: resController,
                            resultDecision: resultDecision))
                            .then((value) {
                          if (kDebugMode) {
                            print(
                                'insert to database success with id: $value');
                          }
                        }).catchError((e) {
                          if (kDebugMode) {
                            print('insert to database failed: $e');
                          }
                        });
                        onDataInserted();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]
                )
              ],
            );
          },
        );
      },
    );
  }
}