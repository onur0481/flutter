import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/sayfalar/sifremiUnuttum.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/hesapolustur.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String de;
  bool yukleniyor = false;
  String email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
            child: Text(
          "Giriş",
          style: TextStyle(color: Colors.blue, fontSize: 25.0),
        )),
      ),
      key: _scaffoldAnahtari,
      body: Stack(
        children: [
          _sayfaElemanlari(),
          _yuklemeAnimasyonu(),
        ],
      ),
    );
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor == true) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center();
    }
  }

  Widget _sayfaElemanlari() {
    return Form(
      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
        children: <Widget>[
          Container(
              width: 140.0,
              height: 100.0,
              child: Image.asset("assets/images/smartphone.png",
                  fit: BoxFit.fitHeight)),
          SizedBox(
            height: 80.0,
          ),
          TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Emailinizi giriniz",
              errorStyle: TextStyle(fontSize: 16.0),
              prefixIcon: Icon(Icons.mail),
            ),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return "Email alanı boş bırakılamaz";
              } else if (!girilenDeger.contains("@")) {
                return "Girilen değer mail formatında olmalı!";
              } else {
                return null;
              }
            },
            onSaved: (girilenDeger) => email = girilenDeger,
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Şifrenizi giriniz",
              errorStyle: TextStyle(fontSize: 16.0),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return "Şifre alanı boş bırakılamaz";
              } else if (girilenDeger.trim().length < 4) {
                return "Şifre 4 karakterden az olmamalıdır!";
              } else {
                return null;
              }
            },
            onSaved: (girilenDeger) => sifre = girilenDeger,
          ),
          SizedBox(
            height: 40.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 40.0,
                  color: Colors.blue,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HesapOlustur()));
                    },
                    child: Text(
                      "Hesap Oluştur",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Container(
                  height: 40.0,
                  color: Colors.green,
                  child: TextButton(
                    onPressed: _girisYap,
                    child: Text(
                      "Giriş Yap",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Text(
              "veya",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Container(
              height: 53.0,
              width: MediaQuery.of(context).size.width / 1.5,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/google.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _googleIleGiris,
                      child: Text(
                        "Google ile Giriş Yapın",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SifremiUnuttum()));
              },
              child: Text(
                "Şifremi unuttum",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  void _girisYap() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    if (_formAnahtari.currentState.validate()) {
      _formAnahtari.currentState.save();
      setState(() {
        yukleniyor = true;
      });
    }
    try {
      await _yetkilendirmeServisi.mailIleGiris(email, sifre);
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata.code);
    }
  }

  void _googleIleGiris() async {
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if (kullanici != null) {
        Kullanici firestoreKullanici =
            await FireStoreServisi().kullaniciGetir(kullanici.id);
        if (firestoreKullanici == null) {
          FireStoreServisi().kullaniciOlustur(
            email: kullanici.email,
            id: kullanici.id,
            kullaniciAdi: kullanici.kullaniciAdi,
            fotoUrl: kullanici.fotoUrl,
          );
        }
      }
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata.code);
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "ERROR_USER_NOT_FOUND") {
      hataMesaji = "Kullanıcı bulunamadı!";
    } else if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir!";
    } else if (hataKodu == "ERROR_WRONG_PASSWORD") {
      hataMesaji = "Şifre yanlış!";
    } else if (hataKodu == "ERROR_USER_DİSABLED") {
      hataMesaji = "Kullanıcı engellenmiş!";
    } else {
      hataMesaji = "Tanımlanmayan bir hata oluştu $hataKodu";
    }
    var _snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(_snackBar);
  }
}
