import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';

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

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .document(kullaniciId)
        .collection("kullanicininTakipcileri")
        .getDocuments();

    return snapshot.documents.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipedilenler")
        .document(kullaniciId)
        .collection("kullanicininTakipleri")
        .getDocuments();

    return snapshot.documents.length;
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
  }
}
