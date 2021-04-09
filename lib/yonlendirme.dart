import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/anasayfa.dart';
import 'package:socialapp/sayfalar/girisSayfasi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Yonlendirme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    return StreamBuilder(
      stream: _yetkilendirmeServisi.durumTakipcisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          Kullanici aktifkullanici = snapshot.data;
          _yetkilendirmeServisi.aktifKullaniciId = aktifkullanici.id;
          return Anasayfa();
        } else {
          return GirisSayfasi();
        }
      },
    );
  }
}
