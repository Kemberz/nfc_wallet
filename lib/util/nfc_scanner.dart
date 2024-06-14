import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';


//scans the nfc tag and returns the information in nfcTag.id
Future<String> scanNfcTag() async {
  try {
    final nfcTag = await FlutterNfcKit.poll();
    return nfcTag.id ?? 'No ID found';
  } catch (e) {
    return 'Error reading NFC tag: $e';
  }
}
