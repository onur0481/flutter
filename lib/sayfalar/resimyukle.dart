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
            icon: Icon(Icons.cancel_rounded, size: 35.0, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          "Fotograf",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.blue),
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
          style: TextStyle(color: Colors.blue),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.cancel_rounded,
              size: 35.0,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                dosya = null;
              });
            }),
        actions: [
          IconButton(
              icon: Icon(Icons.send_outlined),
              color: Colors.blue,
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
                                  Icon(Icons.camera),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                    "Fotoğraf Çek",
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            fotoCek();
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
                                  Icon(Icons.photo_album_outlined),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                    "Galeriden Yükle",
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            galeridenSec();
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
