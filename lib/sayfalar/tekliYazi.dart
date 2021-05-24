import 'package:flutter/material.dart';

import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yazi.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';

import 'package:socialapp/widgetlar/yaziKarti.dart';

class TekliYazi extends StatefulWidget {
  final String yaziId;
  final String yaziSahibiId;

  const TekliYazi({Key key, this.yaziId, this.yaziSahibiId}) : super(key: key);
  @override
  _TekliYaziState createState() => _TekliYaziState();
}

class _TekliYaziState extends State<TekliYazi> {
  Yazi _yazi;
  Kullanici _yaziSahibi;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    yaziGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bildirimler",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.blue),
        ),
        backgroundColor: Colors.grey[100],
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: !_yukleniyor
          ? YaziKarti(
              yazi: _yazi,
              yayinlayan: _yaziSahibi,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  yaziGetir() async {
    Yazi yazi = await FireStoreServisi()
        .tekliYaziGetir(widget.yaziId, widget.yaziSahibiId);

    if (yazi != null) {
      Kullanici yaziSahibi =
          await FireStoreServisi().kullaniciGetir(yazi.yayinlayanId);

      setState(() {
        _yazi = yazi;
        _yaziSahibi = yaziSahibi;
        _yukleniyor = false;
      });
    }
  }
}
