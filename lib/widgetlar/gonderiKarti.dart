import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/yorumlar.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.gonderi, this.yayinlayan})
      : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendinmi = false;
  String _aktifKullanici;

  @override
  void initState() {
    super.initState();
    _begeniSayisi = widget.gonderi.begeniSayisi;
    _aktifKullanici = Provider.of<YetkilendirmeServisi>(context, listen: false)
        .aktifKullaniciId;
    begeniVarmi();
  }

  begeniVarmi() async {
    bool begendimi =
        await FireStoreServisi().begeniVarmi(widget.gonderi, _aktifKullanici);
    if (begendimi) {
      if (mounted) {
        setState(() {
          _begendinmi = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: <Widget>[_gonderiBasligi(), _gonderiResmi(), _gonderiAlt()],
      ),
    );
  }

  gonderiSecenekleri() {
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
                            FireStoreServisi().resimGonderiSil(
                                aktifKullaniciId: _aktifKullanici,
                                gonderi: widget.gonderi);
                            Navigator.pop(context);
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

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
              ? NetworkImage(widget.yayinlayan.fotoUrl)
              : AssetImage("assets/images/profil.png"),
        ),
      ),
      title: Text(
        widget.yayinlayan.kullaniciAdi,
        style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
      ),
      trailing: _aktifKullanici == widget.gonderi.yayinlayanId
          ? IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.blue,
              ),
              onPressed: () {
                gonderiSecenekleri();
              })
          : null,
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  Widget _gonderiResmi() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onDoubleTap: _begeniDegistir,
        child: Image.network(
          widget.gonderi.gonderiResmiUrl,
          width: MediaQuery.of(context).size.width,
          height: 300.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
                onPressed: _begeniDegistir),
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
                              Yorumlar(gonderi: widget.gonderi)));
                }),
            IconButton(
                icon: Icon(
                  Icons.near_me_rounded,
                  color: Colors.blue,
                  size: 25.0,
                ),
                onPressed: () {})
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$_begeniSayisi beğeni",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                  text: TextSpan(
                    text: widget.yayinlayan.kullaniciAdi + " ",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: widget.gonderi.aciklama,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 0.0,
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
      FireStoreServisi().gonderiBegeniKaldir(widget.gonderi, _aktifKullanici);
    } else {
      if (mounted) {
        setState(() {
          _begendinmi = true;
          _begeniSayisi = _begeniSayisi + 1;
        });
      }
      FireStoreServisi().gonderiBegen(widget.gonderi, _aktifKullanici);
    }
  }
}
