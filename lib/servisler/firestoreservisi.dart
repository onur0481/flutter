import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/modeller/duyuru.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yazi.dart';
import 'package:socialapp/servisler/storageservisi.dart';

class FireStoreServisi {
  final Firestore _firestore = Firestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    await _firestore.collection("kullanicilar").document(id).setData({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "kapakFotoUrl": "",
      "hakkinda": "",
      "olusturulmaZamani": zaman,
    });
  }

  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("kullanicilar").document(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  void kullaniciGuncelle(
      {String kullaniciId,
      String kullaniciAdi,
      String fotoUrl = "",
      String kapakFotUrl = "",
      String hakkinda}) {
    _firestore.collection("kullanicilar").document(kullaniciId).updateData({
      "kullaniciAdi": kullaniciAdi,
      "fotoUrl": fotoUrl,
      "kapakFotoUrl": kapakFotUrl,
      "hakkinda": hakkinda,
    });
  }

  void takipEt({String aktifKullaniciId, String profilSahibiId}) {
    _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("KullanicininTakipcileri")
        .document(aktifKullaniciId)
        .setData({});
    _firestore
        .collection("takipEdilen")
        .document(aktifKullaniciId)
        .collection("KullaniciTakipleri")
        .document(profilSahibiId)
        .setData({});
    gonderiduyuruEkle(
      aktiviteTipi: "takip",
      aktiviteYapanId: aktifKullaniciId,
      profilSahibiId: profilSahibiId,
    );
  }

  void takiptenCik({String aktifKullaniciId, String profilSahibiId}) {
    _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("KullanicininTakipcileri")
        .document(aktifKullaniciId)
        .get()
        .then((value) => (DocumentSnapshot doc) {
              if (doc.exists) {
                doc.reference.delete();
              }
            });
    _firestore
        .collection("takipEdilen")
        .document(aktifKullaniciId)
        .collection("KullaniciTakipleri")
        .document(profilSahibiId)
        .get()
        .then((value) => (DocumentSnapshot doc) {
              if (doc.exists) {
                doc.reference.delete();
              }
            });
  }

  Future<bool> takipKontrol(
      {String aktifKullaniciId, String profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipEdilen")
        .document(aktifKullaniciId)
        .collection("KullaniciTakipleri")
        .document(profilSahibiId)
        .get();
    if (doc.exists) {
      return true;
    }
    return false;
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .getDocuments();

    List<Kullanici> kullanicilar =
        snapshot.documents.map((doc) => Kullanici.dokumandanUret(doc)).toList();

    return kullanicilar;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .document(kullaniciId)
        .collection("KullanicininTakipcileri")
        .getDocuments();

    return snapshot.documents.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipEdilen")
        .document(kullaniciId)
        .collection("KullaniciTakipleri")
        .getDocuments();

    return snapshot.documents.length;
  }

  void gonderiduyuruEkle(
      {String aktiviteYapanId,
      String profilSahibiId,
      String aktiviteTipi,
      String yorum,
      String tipi,
      Gonderi gonderi}) {
    if (aktiviteYapanId == profilSahibiId) {
      return;
    }
    _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "gonderiId": gonderi?.id,
      "gonderiFoto": gonderi?.gonderiResmiUrl,
      "yorum": yorum,
      "tipi": tipi,
      "olusturulmaZamani": zaman,
    });
  }

  void yaziduyuruEkle(
      {String aktiviteYapanId,
      String profilSahibiId,
      String aktiviteTipi,
      String yorum,
      String tipi,
      Yazi yazi}) {
    if (aktiviteYapanId == profilSahibiId) {
      return;
    }
    _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "yaziId": yazi.id,
      "yazi": yazi.yazi,
      "yorum": yorum,
      "tipi": tipi,
      "olusturulmaZamani": zaman,
    });
  }

  Future<List<Duyuru>> duyurulariGetir(String profilSahibiId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .orderBy("olusturulmaZamani", descending: true)
        .limit(20)
        .getDocuments();

    List<Duyuru> duyurular = [];

    snapshot.documents.forEach((DocumentSnapshot doc) {
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });
    return duyurular;
  }

  Future<void> gonderiOlustur(
      {gonderiResmiUrl, aciklama, yayinlayanId, konum}) async {
    await _firestore
        .collection("gonderiler")
        .document(yayinlayanId)
        .collection("kullaniciniGonderileri")
        .add({
      "gonderiResmiUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "begeniSayisi": 0,
      "konum": konum,
      "olusturulmaZamani": zaman,
    });
  }

  Future<void> yaziOlustur({yayinlayanId, yazi, olusturulmaZamani}) async {
    await _firestore
        .collection("yazilar")
        .document(yayinlayanId)
        .collection("kullaniciYazilari")
        .add({
      "yayinlayanId": yayinlayanId,
      "yazi": yazi,
      "begeniSayisi": 0,
      "olusturulmaZamani": zaman,
    });
  }

  Future<List<Gonderi>> gonderiGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("gonderiler")
        .document(kullaniciId)
        .collection("kullaniciniGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .getDocuments();

    List<Gonderi> gonderiler =
        snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> resimGonderiSil(
      {String aktifKullaniciId, Gonderi gonderi}) async {
    _firestore
        .collection("gonderiler")
        .document(aktifKullaniciId)
        .collection("kullaniciniGonderileri")
        .document(gonderi.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //gönderiye ait yorumların silinmesi

    QuerySnapshot yorumlarSnapshot = await _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .getDocuments();

    yorumlarSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Silinen gönderinin duyurularını silme

    QuerySnapshot duyurularSnapshot = await _firestore
        .collection("duyurular")
        .document(aktifKullaniciId)
        .collection("kullanicininDuyurulari")
        .where("gonderiId", isEqualTo: gonderi.id)
        .getDocuments();

    duyurularSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //stroge servisinden resmi sil
    StorageServisi().gonderiResmiSil(gonderi.gonderiResmiUrl);
  }

  Future<Gonderi> tekliGonderiGetir(
      String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection("gonderiler")
        .document(gonderiSahibiId)
        .collection("kullaniciniGonderileri")
        .document(gonderiId)
        .get();
    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  Future<Yazi> tekliYaziGetir(String yaziId, String yaziSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection("yazilar")
        .document(yaziSahibiId)
        .collection("kullaniciYazilari")
        .document(yaziId)
        .get();
    Yazi yazi = Yazi.dokumandanUret(doc);
    return yazi;
  }

  Future<List<Yazi>> yaziGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("yazilar")
        .document(kullaniciId)
        .collection("kullaniciYazilari")
        .orderBy("olusturulmaZamani", descending: true)
        .getDocuments();

    List<Yazi> yazilar =
        snapshot.documents.map((doc) => Yazi.dokumandanUret(doc)).toList();
    return yazilar;
  }

  Future<void> yazigonderiSil({String aktifKullaniciId, Yazi yazi}) async {
    _firestore
        .collection("yazilar")
        .document(aktifKullaniciId)
        .collection("kullaniciYazilari")
        .document(yazi.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //yaziya ait yorumların silinmesi

    QuerySnapshot yorumlarSnapshot = await _firestore
        .collection("yorumlar")
        .document(yazi.id)
        .collection("gonderiYorumlari")
        .getDocuments();

    yorumlarSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Silinen yazinin duyurularını silme

    QuerySnapshot duyurularSnapshot = await _firestore
        .collection("duyurular")
        .document(aktifKullaniciId)
        .collection("kullanicininDuyurulari")
        .where("yaziId", isEqualTo: yazi.id)
        .getDocuments();

    duyurularSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference ref = _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayanId)
        .collection("kullaniciniGonderileri")
        .document(gonderi.id);

    DocumentSnapshot doc = await ref.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yenibegeniSayisi = gonderi.begeniSayisi + 1;
      ref.updateData({
        "begeniSayisi": yenibegeniSayisi,
      });
      _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifKullaniciId)
          .setData({});

      gonderiduyuruEkle(
        aktiviteTipi: "begeni",
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        tipi: "resim",
        profilSahibiId: gonderi.yayinlayanId,
      );
    }
  }

  Future<void> gonderiBegeniKaldir(
      Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference ref = _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayanId)
        .collection("kullaniciniGonderileri")
        .document(gonderi.id);

    DocumentSnapshot doc = await ref.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yenibegeniSayisi = gonderi.begeniSayisi - 1;
      ref.updateData({
        "begeniSayisi": yenibegeniSayisi,
      });
      DocumentSnapshot docBegeni = await _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifKullaniciId)
          .get();

      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begeniVarmi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection("begeniler")
        .document(gonderi.id)
        .collection("gonderiBegenileri")
        .document(aktifKullaniciId)
        .get();

    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _firestore
        .collection("yorumlar")
        .document(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulmaZamani", descending: true)
        .snapshots();
  }

  void yorumEkle({String aktifKullaniciId, Gonderi gonderi, String icerik}) {
    _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });

    gonderiduyuruEkle(
        aktiviteTipi: "yorum",
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilSahibiId: gonderi.yayinlayanId,
        yorum: icerik,
        tipi: "resim");
  }

  Future<void> yaziBegen(Yazi yazi, String aktifKullaniciId) async {
    DocumentReference ref = _firestore
        .collection("yazilar")
        .document(yazi.yayinlayanId)
        .collection("kullaniciYazilari")
        .document(yazi.id);

    DocumentSnapshot doc = await ref.get();

    if (doc.exists) {
      Yazi yazi = Yazi.dokumandanUret(doc);
      int yenibegeniSayisi = yazi.begeniSayisi + 1;
      ref.updateData({
        "begeniSayisi": yenibegeniSayisi,
      });
      _firestore
          .collection("begeniler")
          .document(yazi.id)
          .collection("yaziBegenileri")
          .document(aktifKullaniciId)
          .setData({});
      yaziduyuruEkle(
        aktiviteTipi: "begeni",
        aktiviteYapanId: aktifKullaniciId,
        yazi: yazi,
        tipi: "yazi",
        profilSahibiId: yazi.yayinlayanId,
      );
    }
  }

  Future<void> yaziBegeniKaldir(Yazi yazi, String aktifKullaniciId) async {
    DocumentReference ref = _firestore
        .collection("yazilar")
        .document(yazi.yayinlayanId)
        .collection("kullaniciYazilari")
        .document(yazi.id);

    DocumentSnapshot doc = await ref.get();

    if (doc.exists) {
      Yazi yazi = Yazi.dokumandanUret(doc);
      int yenibegeniSayisi = yazi.begeniSayisi - 1;
      ref.updateData({
        "begeniSayisi": yenibegeniSayisi,
      });
      DocumentSnapshot docBegeni = await _firestore
          .collection("begeniler")
          .document(yazi.id)
          .collection("yaziBegenileri")
          .document(aktifKullaniciId)
          .get();

      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begeniVarmii(Yazi yazi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection("begeniler")
        .document(yazi.id)
        .collection("yaziBegenileri")
        .document(aktifKullaniciId)
        .get();

    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetirr(String yaziId) {
    return _firestore
        .collection("yorumlar")
        .document(yaziId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulmaZamani", descending: true)
        .snapshots();
  }

  void yorumEklee({String aktifKullaniciId, Yazi yazi, String icerik}) {
    _firestore
        .collection("yorumlar")
        .document(yazi.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });

    yaziduyuruEkle(
        aktiviteTipi: "yorum",
        aktiviteYapanId: aktifKullaniciId,
        yazi: yazi,
        profilSahibiId: yazi.yayinlayanId,
        yorum: icerik,
        tipi: "yazi");
  }
}
