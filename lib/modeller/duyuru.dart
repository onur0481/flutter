import 'package:cloud_firestore/cloud_firestore.dart';

class Duyuru {
  final String id;
  final String aktiviteYapanId;
  final String aktiviteTipi;
  final String gonderiId;
  final String gonderiFoto;
  final String yaziId;
  final String yazi;
  final String yorum;
  final String tipi;
  final Timestamp olusturulmaZamani;

  Duyuru({
    this.tipi,
    this.id,
    this.aktiviteYapanId,
    this.aktiviteTipi,
    this.gonderiId,
    this.gonderiFoto,
    this.yaziId,
    this.yazi,
    this.yorum,
    this.olusturulmaZamani,
  });

  factory Duyuru.dokumandanUret(DocumentSnapshot doc) {
    return Duyuru(
      id: doc.documentID,
      aktiviteYapanId: doc['aktiviteYapanId'],
      aktiviteTipi: doc['aktiviteTipi'],
      gonderiId: doc['gonderiId'],
      gonderiFoto: doc['gonderiFoto'],
      yaziId: doc['yaziId'],
      yazi: doc['yazi'],
      yorum: doc['yorum'],
      tipi: doc['tipi'],
      olusturulmaZamani: doc['olusturulmaZamani'],
    );
  }
}
