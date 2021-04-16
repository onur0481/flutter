import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/widgetlar/gonderiKarti.dart';

class Profil extends StatefulWidget {
  final String profilSahibiId;
  final String profilSahibiAdi;

  const Profil({Key key, this.profilSahibiId, this.profilSahibiAdi})
      : super(key: key);
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> with SingleTickerProviderStateMixin {
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  String gonderiStili = "liste";
  Kullanici _profilSahibi;
  List<Gonderi> _gonderiler = [];
  TabController takipkontrol;

  Future _takipciSayisiGetir() async {
    int takipciSayisi =
        await FireStoreServisi().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  Future _takipEdilenSayisiGetir() async {
    int takipEdilenSayisi =
        await FireStoreServisi().takipEdilenSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilenSayisi;
      });
    }
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await FireStoreServisi().gonderiGetir(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayisi = _gonderiler.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();
    takipkontrol = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(
              fontFamily: "NanumBrushScript",
              fontSize: 40.0,
              color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ),
              onPressed: _cikisYap)
        ],
      ),
      body: FutureBuilder<Object>(
          future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            _profilSahibi = snapshot.data;
            return NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: _profilDetaylari(snapshot.data),
                  ),
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
                _gonderileriGoster(snapshot.data),
                Container(
                  color: Colors.red,
                ),
              ]),
            );
          }),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == "liste") {
      return Container(
        child: ListView.builder(
          itemCount: _gonderiler.length,
          itemBuilder: (context, index) {
            return GonderiKarti(
              gonderi: _gonderiler[index],
              yayinlayan: profilData,
            );
          },
        ),
      );
    } else {
      List<GridTile> resimler = [];
      _gonderiler.forEach((gonderi) {
        resimler.add(resimOlustur(gonderi));
      });
      return Container(
        child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            shrinkWrap: true,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            children: resimler),
      );
    }
  }

  GridTile resimOlustur(Gonderi gonderi) {
    return GridTile(
      child: Image.network(
        gonderi.gonderiResmiUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              height: 250.0,
              // color: Colors.yellow,
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: profilData.kapakFotoUrl.isNotEmpty
                      ? NetworkImage(profilData.kapakFotoUrl)
                      : AssetImage("assets/images/profil.png"),
                ),
              ),
            ),
            Positioned(
              left: 145.0,
              bottom: 50.0,
              child: Container(
                height: 120.0,
                width: 120.0,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: profilData.fotoUrl.isNotEmpty
                        ? NetworkImage(profilData.fotoUrl)
                        : AssetImage("assets/images/profil.png"),
                  ),
                  borderRadius: BorderRadius.circular(60.0),
                  border: Border.all(width: 2.0, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 147.0,
              bottom: 0.0,
              child: Column(
                children: [
                  Text(
                    profilData.kullaniciAdi,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    profilData.hakkinda,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 285.0,
              bottom: 50.0,
              child: Container(
                width: 120.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(width: 2.0),
                ),
                child: _profiliDuzenle(),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Container(
          height: 75.0,
          color: Colors.grey.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _sosyalSayac(baslik: "Gönderiler", sayi: _gonderiSayisi),
              _sosyalSayac(baslik: "Takipçi", sayi: _takipci),
              _sosyalSayac(baslik: "Takip", sayi: _takipEdilen),
            ],
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  Widget _profiliDuzenle() {
    return OutlineButton(
      onPressed: () {},
      child: Row(
        children: [
          Icon(Icons.edit),
          SizedBox(
            width: 2.0,
          ),
          Text(
            " Düzenle",
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _sosyalSayac({String baslik, int sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(
          baslik,
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  void _cikisYap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
