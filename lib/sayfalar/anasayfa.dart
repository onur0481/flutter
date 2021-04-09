import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/sayfalar/akis.dart';
import 'package:socialapp/sayfalar/ara.dart';
import 'package:socialapp/sayfalar/duyurular.dart';
import 'package:socialapp/sayfalar/profil.dart';

import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Anasayfa extends StatefulWidget {
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  int _aktifNo = 0;
  PageController sayfaKumandasi;

  @override
  void initState() {
    super.initState();
    sayfaKumandasi = PageController();
  }

  @override
  void dispose() {
    sayfaKumandasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullanici =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (acilanSayfaNo) {
          setState(() {
            _aktifNo = acilanSayfaNo;
          });
        },
        controller: sayfaKumandasi,
        children: [
          Akis(),
          Ara(),
          Duyurular(),
          Profil(
            profilSahibiId: aktifKullanici,
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.grey[300]),
        child: BottomNavigationBar(
          iconSize: 30.0,
          currentIndex: _aktifNo,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Akış"),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Keşfet"),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: "Bildirimler"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          ],
          onTap: (secilenSayfaNo) {
            setState(() {
              sayfaKumandasi.jumpToPage(secilenSayfaNo);
            });
          },
        ),
      ),
    );
  }
}
