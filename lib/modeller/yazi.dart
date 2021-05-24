import 'package:cloud_firestore/cloud_firestore.dart';

class Yazi {
  final String id;
  final String yazi;
  final String yayinlayanId;
  final int begeniSayisi;
  final String konum;

  Yazi({this.id, this.yazi, this.yayinlayanId, this.begeniSayisi, this.konum});

  factory Yazi.dokumandanUret(DocumentSnapshot doc) {
    return Yazi(
      id: doc.documentID,
      yazi: doc['yazi'],
      yayinlayanId: doc['yayinlayanId'],
      begeniSayisi: doc['begeniSayisi'],
      konum: doc['konum'],
    );
  }
}
