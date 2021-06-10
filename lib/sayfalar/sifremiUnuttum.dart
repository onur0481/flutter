import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class SifremiUnuttum extends StatefulWidget {
  @override
  _SifremiUnuttumState createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Şifremi Sıfırla"),
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
                          TextStyle(color: Colors.black, fontSize: 20.0),
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
                    height: 20.0,
                  ),
                  Container(
                    height: 40.0,
                    color: Theme.of(context).primaryColor,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _sifreSifirla,
                      child: Text(
                        "Şifremi Sıfırla",
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
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

  void _sifreSifirla() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formState = _formAnahtari.currentState;
    if (_formState.validate()) {
      _formState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        _yetkilendirmeServisi.sifremiSifirla(email);
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
    } else if (hataKodu == "ERROR_USER_NOT_FOUND") {
      hataMesaji = "Girdiğiniz mail bulunamadı!";
    }

    var _snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(_snackBar);
  }
}
