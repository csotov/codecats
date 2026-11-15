import 'dart:typed_data';

/// Non-web builds: real downloads and file uploads are not supported yet.
bool get canUseFiles => false;

void downloadBytes(String name, Uint8List bytes, String mime) {}

void openHtml(String html) {}

Future<({String name, String text})?> pickTextFile(String accept) async => null;
