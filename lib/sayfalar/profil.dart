import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/yazi.dart';
import 'package:socialapp/sayfalar/profilDuzenle.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/widgetlar/gonderiKarti.dart';
import 'package:socialapp/widgetlar/yaziKarti.dart';

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
  int _yaziSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  String gonderiStili = "liste";
  String _aktifKullaniciId;
  Kullanici _profilSahibi;
  List<Gonderi> _gonderiler = [];
  List<Yazi> _yazilar = [];
  TabController takipkontrol;
  bool _takipEdildi = false;

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

  _yazilariGetir() async {
    List<Yazi> yazilar =
        await FireStoreServisi().yaziGetir(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _yazilar = yazilar;
        _yaziSayisi = _yazilar.length;
      });
      if (yazilar.isEmpty) {
        print("değer geldi");
      }
    }
  }

  _takipKontrol() async {
    bool takipVarmi = await FireStoreServisi().takipKontrol(
        aktifKullaniciId: _aktifKullaniciId,
        profilSahibiId: widget.profilSahibiId);

    setState(() {
      _takipEdildi = takipVarmi;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();
    _yazilariGetir();

    takipkontrol = TabController(length: 2, vsync: this);
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _takipKontrol();
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
              color: Colors.blue),
        ),
        backgroundColor: Colors.grey[100],
        actions: <Widget>[
          widget.profilSahibiId == _aktifKullaniciId
              ? IconButton(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.blue,
                  ),
                  onPressed: _cikisYap)
              : SizedBox(
                  height: 0.0,
                ),
        ],
        iconTheme: IconThemeData(color: Colors.blue),
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
                _yazilariGoster(snapshot.data),
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

  Widget _yazilariGoster(Kullanici profilData) {
    return Container(
      child: ListView.builder(
          itemCount: _yazilar.length,
          itemBuilder: (context, index) {
            return YaziKarti(
              yazi: _yazilar[index],
              yayinlayan: profilData,
            );
          }),
    );
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
              left: 267.0,
              bottom: 50.0,
              child: Container(
                  alignment: Alignment.center,
                  width: 140.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(width: 2.0),
                  ),
                  child: widget.profilSahibiId == _aktifKullaniciId
                      ? _profiliDuzenle()
                      : _takipButonu()),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _sosyalSayac(baslik: "Medya", sayi: _gonderiSayisi),
              _sosyalSayac(baslik: "Yazı", sayi: _yaziSayisi),
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

  Widget _takipButonu() {
    return _takipEdildi ? _takiptenCik() : _takipEt();
  }

  Widget _takipEt() {
    return OutlineButton(
      onPressed: () {
        FireStoreServisi().takipEt(
            aktifKullaniciId: _aktifKullaniciId,
            profilSahibiId: widget.profilSahibiId);
        setState(() {
          _takipEdildi = true;
          _takipci = _takipci + 1;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_add_outlined),
          SizedBox(
            width: 2.0,
          ),
          Text(
            " Takip Et",
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _takiptenCik() {
    return OutlineButton(
      onPressed: () {
        FireStoreServisi().takiptenCik(
            aktifKullaniciId: _aktifKullaniciId,
            profilSahibiId: widget.profilSahibiId);
        setState(() {
          _takipEdildi = false;
          _takipci = _takipci - 1;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel),
          SizedBox(
            width: 2.0,
          ),
          Text(
            "Takip Çık",
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _profiliDuzenle() {
    return OutlineButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilDuzenle(
                      profil: _profilSahibi,
                    )));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
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
