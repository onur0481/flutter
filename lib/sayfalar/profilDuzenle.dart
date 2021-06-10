import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/storageservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class ProfilDuzenle extends StatefulWidget {
  final Kullanici profil;

  const ProfilDuzenle({Key key, this.profil}) : super(key: key);
  @override
  _ProfilDuzenleState createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String _kullaniciAdi;
  String _hakkinda;
  File _secilmisProfilFoto;
  File _secilmisKapakFoto;
  bool _yukleniyor = false;
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
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              size: 35.0,
              color: Colors.blue,
            ),
            onPressed: _kaydet,
          ),
        ],
        title: Text(
          "Profili Duzenle",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.blue),
        ),
      ),
      body: ListView(
        children: [
          _yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          _kapakFoto(),
          _profilFoto(),
          _profilBilgileri(),
        ],
      ),
    );
  }

  _kaydet() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _yukleniyor = true;
      });
      _formKey.currentState.save();
      String profilFotoUrl;
      String kapakFotoUrl;
      if (_secilmisKapakFoto == null) {
        kapakFotoUrl = widget.profil.kapakFotoUrl;
      } else {
        kapakFotoUrl =
            await StorageServisi().kapakResmiYukle(_secilmisKapakFoto);
      }
      if (_secilmisProfilFoto == null) {
        profilFotoUrl = widget.profil.fotoUrl;
      } else {
        profilFotoUrl =
            await StorageServisi().profilResmiYukle(_secilmisProfilFoto);
      }

      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      FireStoreServisi().kullaniciGuncelle(
        kullaniciId: aktifKullaniciId,
        hakkinda: _hakkinda,
        kullaniciAdi: _kullaniciAdi,
        fotoUrl: profilFotoUrl,
        kapakFotUrl: kapakFotoUrl,
      );
      setState(() {
        _yukleniyor = false;
      });
      Navigator.pop(context);
    }
  }

  _kapakFoto() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 230,
        ),
        Container(
          width: double.infinity,
          height: 200.0,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            image: DecorationImage(
                image: _secilmisKapakFoto == null
                    ? NetworkImage(widget.profil.kapakFotoUrl)
                    : FileImage(_secilmisKapakFoto),
                fit: BoxFit.cover),
          ),
        ),
        Positioned(
          left: 334,
          top: 195,
          child: IconButton(
            icon: Icon(
              Icons.camera_enhance,
              color: Colors.red,
              size: 28.0,
            ),
            onPressed: _galeridenSecKapak,
          ),
        ),
      ],
    );
  }

  _galeridenSecKapak() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);

    setState(() {
      _secilmisKapakFoto = File(image.path);
    });
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Stack(
        children: [
          Container(
            width: 150.0,
            height: 120.0,
          ),
          Center(
            child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 55.0,
                backgroundImage: _secilmisProfilFoto == null
                    ? NetworkImage(widget.profil.fotoUrl)
                    : FileImage(_secilmisProfilFoto)),
          ),
          Positioned(
            left: 234,
            top: 77,
            child: IconButton(
              icon: Icon(
                Icons.camera_enhance,
                color: Colors.red,
                size: 28.0,
              ),
              onPressed: _galeridenSec,
            ),
          ),
        ],
      ),
    );
  }

  _galeridenSec() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);

    setState(() {
      _secilmisProfilFoto = File(image.path);
    });
  }

  _profilBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.profil.kullaniciAdi,
              decoration: InputDecoration(labelText: "Kullanici Adı"),
              validator: (girilenDeger) {
                return girilenDeger.trim().length <= 3
                    ? "Kullanıcı adı en az 4 karakter olmalıdır"
                    : null;
              },
              onSaved: (girilenDeger) {
                _kullaniciAdi = girilenDeger;
              },
            ),
            TextFormField(
              initialValue: widget.profil.hakkinda,
              decoration: InputDecoration(labelText: "Hakkında"),
              validator: (girilenDeger) {
                return girilenDeger.trim().length > 100
                    ? "100 karakterden fazla olmamalıdır"
                    : null;
              },
              onSaved: (girilenDeger) {
                _hakkinda = girilenDeger;
              },
            ),
          ],
        ),
      ),
    );
  }
}
