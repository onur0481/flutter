import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yazi.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/yaziYorumlari.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class YaziKarti extends StatefulWidget {
  final Yazi yazi;
  final Kullanici yayinlayan;

  const YaziKarti({Key key, this.yazi, this.yayinlayan}) : super(key: key);
  @override
  _YaziKartiState createState() => _YaziKartiState();
}

class _YaziKartiState extends State<YaziKarti> {
  int _begeniSayisi = 0;
  bool _begendinmi = false;
  String _aktifKullanici;

  @override
  void initState() {
    super.initState();
    _begeniSayisi = widget.yazi.begeniSayisi;
    _aktifKullanici = Provider.of<YetkilendirmeServisi>(context, listen: false)
        .aktifKullaniciId;
    begeniVarmii();
  }

  begeniVarmii() async {
    bool begendimi =
        await FireStoreServisi().begeniVarmii(widget.yazi, _aktifKullanici);
    if (begendimi) {
      if (mounted) {
        setState(() {
          _begendinmi = true;
        });
      }
    }
  }

  yaziSecenekleri() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              Container(
                height: 30.0,
                width: double.infinity,
                color: Colors.black54,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    )),
              ),
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "Seçenekler",
                        style: TextStyle(fontSize: 25.0, color: Colors.blue),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 22.0, right: 22.0),
                      child: Divider(
                        color: Colors.black,
                        height: 4.0,
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22.0),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.delete_forever),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                    "Gönderiyi Sil",
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            FireStoreServisi().yazigonderiSil(
                                aktifKullaniciId: _aktifKullanici,
                                yazi: widget.yazi);
                          },
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22.0),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.share_outlined),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                    "Paylaş..",
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22.0),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.edit_attributes),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                    "Düzenle",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22.0),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.copy),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                    "Bağlantıyı Kopyala",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22.0),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cancel_presentation,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                    "Vazgeç..",
                                    style: TextStyle(
                                        fontSize: 17.0, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [_yaziBasligi(), _yazi(), _yaziAlt()],
      ),
    );
  }

  _yaziBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profil(
                          profilSahibiId: widget.yazi.yayinlayanId,
                        )));
          },
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
                ? NetworkImage(widget.yayinlayan.fotoUrl)
                : AssetImage("assets/images/profil.png"),
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Profil(
                        profilSahibiId: widget.yazi.yayinlayanId,
                      )));
        },
        child: Text(
          widget.yayinlayan.kullaniciAdi,
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.blue,
          ),
          onPressed: () {
            yaziSecenekleri();
          }),
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  _yazi() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      //onDoubleTap: _begeniDegistir,
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.yazi.yazi,
          style: TextStyle(
            fontSize: 17.0,
          ),
        ),
      ),
    );
  }

  _yaziAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 6.0,
        ),
        Container(
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: !_begendinmi
                        ? Icon(
                            Icons.favorite_border,
                            color: Colors.blue,
                            size: 25.0,
                          )
                        : Icon(
                            Icons.favorite,
                            size: 25.0,
                            color: Colors.red,
                          ),
                    onPressed: _begeniDegistir,
                  ),
                  Text("Beğen"),
                ],
              ),
              Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.comment_outlined,
                        color: Colors.blue,
                        size: 25.0,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    YaziYorumlari(yazi: widget.yazi)));
                      }),
                  Text("Yorum yap"),
                ],
              ),
              Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.near_me_rounded,
                        color: Colors.blue,
                        size: 25.0,
                      ),
                      onPressed: () {}),
                  Text("Gönder"),
                ],
              )
            ],
          ),
        ),
        SizedBox(
          height: 9.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$_begeniSayisi beğeni",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 13.0, right: 13.0),
          child: Container(
            height: 1.0,
            width: double.infinity,
            color: Colors.grey,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendinmi) {
      if (mounted) {
        setState(() {
          _begendinmi = false;
          _begeniSayisi = _begeniSayisi - 1;
        });
      }
      FireStoreServisi().yaziBegeniKaldir(widget.yazi, _aktifKullanici);
    } else {
      if (mounted) {
        setState(() {
          _begendinmi = true;
          _begeniSayisi = _begeniSayisi + 1;
        });
      }
      FireStoreServisi().yaziBegen(widget.yazi, _aktifKullanici);
    }
  }
}
