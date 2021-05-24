import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/duyuru.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/tekliYazi.dart';
import 'package:socialapp/sayfalar/tekligonderi.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:timeago/timeago.dart' as timeago;

class Duyurular extends StatefulWidget {
  @override
  _DuyurularState createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  List<Duyuru> _duyurular;
  String _aktifkullaniciId;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _aktifkullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    duyurulariGetir();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> duyurulariGetir() async {
    List<Duyuru> duyurular =
        await FireStoreServisi().duyurulariGetir(_aktifkullaniciId);
    if (mounted) {
      setState(() {
        _duyurular = duyurular;
        _yukleniyor = false;
      });
    }
  }

  duyulariGoster() {
    if (_yukleniyor) {
      return Center(child: CircularProgressIndicator());
    }
    if (_duyurular.isEmpty) {
      return Center(child: Text("Bildirim bulunmamaktadır"));
    }

    return RefreshIndicator(
      onRefresh: duyurulariGetir,
      child: ListView.builder(
          itemCount: _duyurular.length,
          itemBuilder: (context, index) {
            Duyuru duyuru = _duyurular[index];
            return duyuruSatiri(duyuru);
          }),
    );
  }

  duyuruSatiri(Duyuru duyuru) {
    String mesaj = mesajOlustur(duyuru.aktiviteTipi, duyuru.tipi);
    return FutureBuilder(
      future: FireStoreServisi().kullaniciGetir(duyuru.aktiviteYapanId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 0.0,
          );
        }
        Kullanici aktiviteYapan = snapshot.data;
        return ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profil(
                            profilSahibiId: duyuru.aktiviteYapanId,
                          )));
            },
            child: CircleAvatar(
              backgroundImage: aktiviteYapan.fotoUrl.isNotEmpty
                  ? NetworkImage(aktiviteYapan.fotoUrl)
                  : AssetImage("assets/images/profil.png"),
            ),
          ),
          title: RichText(
            text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profil(
                                  profilSahibiId: duyuru.aktiviteYapanId,
                                )));
                  },
                text: "${aktiviteYapan.kullaniciAdi + " "}",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: duyuru.yorum == null
                        ? "$mesaj"
                        : "$mesaj ${duyuru.yorum}",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ]),
          ),
          trailing: duyuru.tipi == "resim"
              ? gonderiGorsel(
                  duyuru.aktiviteTipi, duyuru.gonderiFoto, duyuru.gonderiId)
              : Text(timeago.format(duyuru.olusturulmaZamani.toDate(),
                  locale: "tr")),
          subtitle: duyuru.tipi == "yazi"
              ? gonderiYazi(duyuru.aktiviteTipi, duyuru.yazi, duyuru.yaziId)
              : Text(timeago.format(duyuru.olusturulmaZamani.toDate(),
                  locale: "tr")),
        );
      },
    );
  }

  gonderiGorsel(String aktiviteTipi, String gonderiFoto, String gonderiId) {
    if (aktiviteTipi == "takip") {
      return null;
    } else if (aktiviteTipi == "begeni" || aktiviteTipi == "yorum") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TekliGonderi(
                        gonderiId: gonderiId,
                        gonderiSahibiId: _aktifkullaniciId,
                      )));
        },
        child: Image.network(
          gonderiFoto,
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  gonderiYazi(String aktiviteTipi, String gonderiYazi, String yaziId) {
    if (aktiviteTipi == "takip") {
      return null;
    } else if (aktiviteTipi == "begeni" || aktiviteTipi == "yorum") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TekliYazi(
                            yaziId: yaziId,
                            yaziSahibiId: _aktifkullaniciId,
                          )));
            },
            child: Container(
              child: Text('"$gonderiYazi"'),
            ),
          ),
        ],
      );
    }
  }

  mesajOlustur(String aktiviteTipi, String tipi) {
    if (aktiviteTipi == "begeni") {
      if (tipi == "resim") {
        return "gönderini begendi.";
      } else if (tipi == "yazi") {
        return "yazını begendi.";
      }
    } else if (aktiviteTipi == "takip") {
      return "seni takip etti.";
    } else if (aktiviteTipi == "yorum") {
      if (tipi == "resim") {
        return "resimine yorum yaptı.";
      } else if (tipi == "yazi") {
        return "yazına yorum yaptı.";
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bildirimler",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.blue),
        ),
        backgroundColor: Colors.grey[100],
      ),
      body: duyulariGoster(),
    );
  }
}
