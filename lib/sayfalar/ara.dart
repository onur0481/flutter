import 'package:flutter/material.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';

class Ara extends StatefulWidget {
  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _arama = TextEditingController();
  Future<List<Kullanici>> _aramaSonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[200],
      title: TextFormField(
        onFieldSubmitted: (girilenDeger) {
          setState(() {
            _aramaSonucu = FireStoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _arama,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                icon: Icon(
                  Icons.cancel_outlined,
                  size: 35.0,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _aramaSonucu = null;
                  });
                  _arama.clear();
                }),
            prefixIcon: Icon(
              Icons.search,
              size: 35.0,
              color: Colors.blue,
            ),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            hintText: "Kullanıcı Ara",
            contentPadding: EdgeInsets.only(top: 16.0, left: 5.0)),
      ),
    );
  }

  aramaYok() {
    return Center(child: Text("Kullanıcı Ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
      future: _aramaSonucu,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.length == 0) {
          return Center(
            child: Text("Sonuç bulunamadı"),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            Kullanici kullanici = snapshot.data[index];
            return kullaniciSatiri(kullanici);
          },
        );
      },
    );
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profil(profilSahibiId: kullanici.id)));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: kullanici.fotoUrl.isNotEmpty
              ? NetworkImage(kullanici.fotoUrl)
              : AssetImage("assets/images/profil.png"),
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
