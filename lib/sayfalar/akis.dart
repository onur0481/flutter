import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yazi.dart';
import 'package:socialapp/sayfalar/resimyukle.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/sayfalar/yaziyukle.dart';
import 'package:socialapp/widgetlar/futureBuilder.dart';
import 'package:socialapp/widgetlar/gonderiKarti.dart';
import 'package:socialapp/widgetlar/yaziKarti.dart';

class Akis extends StatefulWidget {
  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> with SingleTickerProviderStateMixin {
  TabController takipkontrol;
  List<Yazi> _yazilar = [];
  List<Gonderi> _gonderiler = [];

  _akisYazilariGetir() async {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    List<Yazi> yazilar =
        await FireStoreServisi().akisYaziGetir(aktifKullaniciId);
    if (mounted) {
      setState(() {
        _yazilar = yazilar;
        print("deneme");
      });
    }
  }

  _akisGonderileriGetir() async {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    List<Gonderi> gonderiler =
        await FireStoreServisi().akisFotoGetir(aktifKullaniciId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        print("dnee");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    takipkontrol = TabController(length: 2, vsync: this);
    _akisYazilariGetir();
    _akisGonderileriGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Anasayfa",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.blue),
        ),
        centerTitle: true,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              title: TabBar(controller: takipkontrol, tabs: [
                Tab(
                  child: Center(
                    child: Text(
                      "Medya",
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
                ),
                Tab(
                  child: Center(
                    child: Text(
                      "Yazı",
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
                ),
              ]),
            ),
          ];
        },
        body: TabBarView(controller: takipkontrol, children: [
          _medya(),
          _yazi(),
        ]),
      ),
    );
  }

  _medya() {
    return Stack(
      children: [
        Container(
          child: ListView.builder(
            itemCount: _gonderiler.length,
            itemBuilder: (context, index) {
              Gonderi gonderi = _gonderiler[index];
              return SilinmeyenFutureBuilder(
                future: FireStoreServisi().kullaniciGetir(gonderi.yayinlayanId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox();
                  }
                  Kullanici gonderiSahibi = snapshot.data;
                  return GonderiKarti(
                    gonderi: gonderi,
                    yayinlayan: gonderiSahibi,
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(180.0),
                      color: Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 7,
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                        icon: Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Yukle()));
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  _yazi() {
    String aktifKullanici =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    return Stack(
      children: [
        ListView(
          children: [
            ListView.builder(
                shrinkWrap: true,
                primary: false,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _yazilar.length,
                itemBuilder: (context, index) {
                  Yazi yazi = _yazilar[index];
                  return SilinmeyenFutureBuilder(
                      future:
                          FireStoreServisi().kullaniciGetir(yazi.yayinlayanId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox();
                        }

                        Kullanici yaziSahibi = snapshot.data;
                        return YaziKarti(
                          yazi: yazi,
                          yayinlayan: yaziSahibi,
                        );
                      });
                }),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(180.0),
                      color: Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 7,
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                        icon: Icon(
                          Icons.border_color,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => YaziYukle(
                                        profilSahibiId: aktifKullanici,
                                      )));
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
