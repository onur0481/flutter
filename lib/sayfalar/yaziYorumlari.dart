import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yazi.dart';
import 'package:socialapp/modeller/yorum.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class YaziYorumlari extends StatefulWidget {
  final Yazi yazi;

  const YaziYorumlari({Key key, this.yazi}) : super(key: key);

  @override
  _YaziYorumlariState createState() => _YaziYorumlariState();
}

class _YaziYorumlariState extends State<YaziYorumlari> {
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
              color: Colors.blue),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: <Widget>[_yorumlariGoster(), _yorumyap()],
      ),
    );
  }

  _yorumlariGoster() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: FireStoreServisi().yorumlariGetirr(widget.yazi.id),
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
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: _yorumGonderr,
      ),
    );
  }

  void _yorumGonderr() {
    String aktifKullanici =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    FireStoreServisi().yorumEklee(
        aktifKullaniciId: aktifKullanici,
        yazi: widget.yazi,
        icerik: _yorumKontrol.text);
    _yorumKontrol.clear();
  }
}
