import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class HesapOlustur extends StatefulWidget {
  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String kullaniciAdi, email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Hesap Oluştur"),
      ),
      body: ListView(
        children: [
          yukleniyor == true
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formAnahtari,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    autocorrect: true,
                    decoration: InputDecoration(
                      hintText: "Kullanıcı adınızı giriniz",
                      labelText: "Kullanıcı Adı",
                      labelStyle:
                          TextStyle(color: Colors.orange, fontSize: 20.0),
                      errorStyle: TextStyle(fontSize: 16.0),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (girilenDeger) {
                      if (girilenDeger.isEmpty) {
                        return "Kullanıcı adı boş bırakılamaz";
                      } else if (girilenDeger.trim().length < 4 ||
                          girilenDeger.trim().length > 10) {
                        return "En az 4 en fazla 10 karakter olmalıdır!";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (girilen) => kullaniciAdi = girilen,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    autocorrect: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Emailinizi giriniz",
                      labelText: "Mail",
                      labelStyle:
                          TextStyle(color: Colors.orange, fontSize: 20.0),
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
                    onSaved: (girilen) => email = girilen,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Şifrenizi giriniz",
                      labelText: "Şifre",
                      labelStyle:
                          TextStyle(color: Colors.orange, fontSize: 20.0),
                      errorStyle: TextStyle(fontSize: 16.0),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (girilenDeger) {
                      if (girilenDeger.isEmpty) {
                        return "Şifre alanı bırakılamaz";
                      } else if (girilenDeger.trim().length < 4) {
                        return "Şifre 4 karakterden az olmamalıdır!";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (girilen) => sifre = girilen,
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      onPressed: _kullaniciOlustur,
                      child: Text(
                        "Hesap Oluştur",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _kullaniciOlustur() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formState = _formAnahtari.currentState;
    if (_formState.validate()) {
      _formState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici kullanici =
            await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        if (kullanici != null) {
          FireStoreServisi().kullaniciOlustur(
              id: kullanici.id,
              email: kullanici.email,
              kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.code);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir!";
    } else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hataMesaji = "Girdiğiniz mail daha önceden kullanılmış!";
    } else if (hataKodu == "ERROR_WEAK_PASSWORD") {
      hataMesaji = "Daha güçlü şifre giriniz!";
    }
    var _snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(_snackBar);
  }
}
