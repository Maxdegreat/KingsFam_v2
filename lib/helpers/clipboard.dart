import 'package:flutter/services.dart';

Future<void> copyTextToClip(String text) async {
// Create a ClipboardData object with the text
  ClipboardData data = ClipboardData(text: text);

// Copy the text to the clipboard
  await Clipboard.setData(data);
}
