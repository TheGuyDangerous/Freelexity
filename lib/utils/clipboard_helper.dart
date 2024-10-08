import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

Future<void> copyToClipboard(String text, {String? message}) async {
  await Clipboard.setData(ClipboardData(text: text));
  Fluttertoast.showToast(
    msg: message ?? "Copied to clipboard",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey[800],
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
