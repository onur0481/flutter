import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/storageservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Yukle extends StatefulWidget {
  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File dosya;
  bool yukleniyor = false;
  TextEditingController aciklamaTextKontrol = TextEditingController();
  TextEditingController konumTextKontrol = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          "Gonderi",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(
                  Icons.file_upload,
                  size: 50.0,
                ),
                onPressed: () {
                  fotografSec();
                }),
            SizedBox(
              height: 15.0,
            ),
            Text(
              "Gönderi Yükle",
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Gönderi Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                dosya = null;
              });
            }),
        actions: [
          IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ),
              onPressed: _gonderiOlustur),
        ],
      ),
      body: ListView(
        children: <Widget>[
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          SizedBox(
            height: 5.0,
          ),
          TextFormField(
            controller: aciklamaTextKontrol,
            decoration: InputDecoration(
              hintText: "Açıklama yaz",
              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0),
            ),
          ),
          TextFormField(
            controller: konumTextKontrol,
            decoration: InputDecoration(
              hintText: "Konum gir",
              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Image.file(
              dosya,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  void _gonderiOlustur() async {
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });
      String resimURL = await StorageServisi().gonderiResmiYukle(dosya);
      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      await FireStoreServisi().gonderiOlustur(
          gonderiResmiUrl: resimURL,
          aciklama: aciklamaTextKontrol.text,
          konum: konumTextKontrol.text,
          yayinlayanId: aktifKullaniciId);

      setState(() {
        yukleniyor = false;
        aciklamaTextKontrol.clear();
        konumTextKontrol.clear();
        dosya = null;
      });
    }
  }

  fotografSec() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color: Colors.black,
                    width: 3.0,
                  )),
                ),
                child: Center(
                  child: Text(
                    "Gönderi oluştur",
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  )),
                ),
                child: InkWell(
                  onTap: () {
                    fotoCek();
                  },
                  child: Center(
                    child: Text(
                      "Fotoğraf çek",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  )),
                ),
                child: InkWell(
                  onTap: () {
                    galeridenSec();
                  },
                  child: Center(
                    child: Text(
                      "Galeriden yükle",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  )),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      "İptal",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          );
        });
  }

  fotoCek() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);

    setState(() {
      dosya = File(image.path);
    });
  }

  galeridenSec() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);

    setState(() {
      dosya = File(image.path);
    });
  }
}
