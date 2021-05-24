import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class YaziYukle extends StatefulWidget {
  final String profilSahibiId;

  const YaziYukle({Key key, this.profilSahibiId}) : super(key: key);
  @override
  _YaziYukleState createState() => _YaziYukleState();
}

class _YaziYukleState extends State<YaziYukle> {
  bool yukleniyor = false;
  Kullanici _profilSahibi;
  String yazi;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.cancel_rounded,
              size: 35.0,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          "Yazı yaz",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.blue),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.send_outlined),
              color: Colors.blue,
              onPressed: () {
                _yaziOlustur();
              })
        ],
      ),
      body: FutureBuilder<Object>(
          future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            _profilSahibi = snapshot.data;

            return profilDetaylari(snapshot.data);
          }),
    );
  }

  profilDetaylari(Kullanici profilData) {
    return ListView(children: [
      yukleniyor
          ? LinearProgressIndicator()
          : SizedBox(
              height: 0.0,
            ),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: profilData.fotoUrl.isNotEmpty
                  ? NetworkImage(profilData.fotoUrl)
                  : AssetImage("assets/images/profil.png"),
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: TextField(
                maxLength: 280,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: "Ne düşünüyorsun?",
                ),
                onChanged: (deger) {
                  yazi = deger;
                },
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  void _yaziOlustur() async {
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });
      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;
      await FireStoreServisi()
          .yaziOlustur(yayinlayanId: aktifKullaniciId, yazi: yazi);

      setState(() {
        yukleniyor = false;
        Navigator.pop(context);
      });
    }
  }
}
