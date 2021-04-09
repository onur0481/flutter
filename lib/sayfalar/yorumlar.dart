import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yorum.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;

  const Yorumlar({Key key, this.gonderi}) : super(key: key);

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController _yorumKontrol = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Yorumlar",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[_yorumlariGoster(), _yorumyap()],
      ),
    );
  }

  _yorumlariGoster() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: FireStoreServisi().yorumlariGetir(widget.gonderi.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  Yorum yorum =
                      Yorum.dokumandanUret(snapshot.data.documents[index]);
                  return _yorumStili(yorum);
                });
          }),
    );
  }

  _yorumStili(Yorum yorum) {
    return FutureBuilder<Kullanici>(
        future: FireStoreServisi().kullaniciGetir(yorum.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0.0,
            );
          }
          Kullanici yayinlayan = snapshot.data;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              backgroundImage: NetworkImage(yayinlayan.fotoUrl),
            ),
            title: RichText(
              text: TextSpan(
                text: yayinlayan.kullaniciAdi + " ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: yorum.icerik,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  _yorumyap() {
    return ListTile(
      title: TextFormField(
        controller: _yorumKontrol,
        decoration: InputDecoration(
          hintText: "Yanıtla",
        ),
      ),
      trailing: IconButton(icon: Icon(Icons.send), onPressed: _yorumGonder),
    );
  }

  void _yorumGonder() {
    String aktifKullanici =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    FireStoreServisi().yorumEkle(
        aktifKullaniciId: aktifKullanici,
        gonderi: widget.gonderi,
        icerik: _yorumKontrol.text);
    _yorumKontrol.clear();
  }
}
