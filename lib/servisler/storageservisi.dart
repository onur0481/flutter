import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  StorageReference _storage = FirebaseStorage.instance.ref();
  String resiimId;

  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resiimId = Uuid().v4();
    StorageUploadTask yuklemeYoneticisi = _storage
        .child("resimler/gonderiler/gonderi_$resiimId.jpg")
        .putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeYoneticisi.onComplete;
    String yuklenenResimURL = await snapshot.ref.getDownloadURL();
    return yuklenenResimURL;
  }
}
