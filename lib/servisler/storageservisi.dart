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

  Future<String> profilResmiYukle(File resimDosyasi) async {
    resiimId = Uuid().v4();
    StorageUploadTask yuklemeYoneticisi = _storage
        .child("resimler/profil/profil_$resiimId.jpg")
        .putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeYoneticisi.onComplete;
    String yuklenenResimURL = await snapshot.ref.getDownloadURL();
    return yuklenenResimURL;
  }

  Future<String> kapakResmiYukle(File resimDosyasi) async {
    resiimId = Uuid().v4();
    StorageUploadTask yuklemeYoneticisi = _storage
        .child("resimler/kapakFoto/kapakFoto_$resiimId.jpg")
        .putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeYoneticisi.onComplete;
    String yuklenenResimURL = await snapshot.ref.getDownloadURL();
    return yuklenenResimURL;
  }

  void gonderiResmiSil(String gonderiResmiUrl) {
    RegExp arama = RegExp(r"gonderi_.+\.jpg");
    var eslesme = arama.firstMatch(gonderiResmiUrl);
    String dosyaAdi = eslesme[0];
    if (dosyaAdi != null) {
      _storage.child("resimler/gonderiler/$dosyaAdi").delete();
    }
  }
}
