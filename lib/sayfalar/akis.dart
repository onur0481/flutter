import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/sayfalar/resimyukle.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/sayfalar/yaziyukle.dart';

class Akis extends StatefulWidget {
  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> with SingleTickerProviderStateMixin {
  TabController takipkontrol;

  @override
  void initState() {
    super.initState();
    takipkontrol = TabController(length: 2, vsync: this);
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
