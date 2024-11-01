import 'package:flutter/material.dart';
import 'dart:async';

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

Future<void> dialogBuilderResult(BuildContext context, String resultDecision) async {
  // Tampilkan dialog loading
  await showLoadingDialog(context);

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
              title: const Text('Decision Result'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    child: Center(
                      child: Text(resultDecision),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                Center(
                  child: TextButton(
                    child: const Text('Yeayyy!'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}