import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
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

  Widget _gonderiBasligi() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
            ? NetworkImage(widget.yayinlayan.fotoUrl)
            : AssetImage("assets/images/profil.png"),
      ),
      title: Text(
        widget.yayinlayan.kullaniciAdi,
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: null),
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
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
                        size: 35.0,
                      )
                    : Icon(
                        Icons.favorite,
                        size: 35.0,
                        color: Colors.red,
                      ),
                onPressed: _begeniDegistir),
            IconButton(
                icon: Icon(
                  Icons.comment_outlined,
                  size: 35.0,
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
                  size: 35.0,
                ),
                onPressed: null)
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$_begeniSayisi beğeni",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
