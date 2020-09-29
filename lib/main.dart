import 'package:flutter/material.dart';
import 'package:flutter_contact/contact.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Row {
  Contact contact;
  bool checked;

  Row(
    this.contact,
    this.checked,
  );
}

class _HomePageState extends State<HomePage> {
  bool permissionState = false;
  //Rehber kayıtları bu listede yer alacak.
  //Liste içinde bir adet "contact" bir de "bool" değer var.
  //Her bir contactın kendine ait bool değeri var. Bu bool değerler ile işaretli/işaretsiz durumunu uygulayacağız.
  List<Row> contacts = [];

  @override
  void initState() {
    super.initState();
    _permission();
  }

  _permission() async {
    var permission = await Permission.contacts.status;
    //Eğer kullanıcı izin vermiş ise kayıtları alıyoruz ve metodu bitiriyoruz.
    if (permission.isGranted) {
      setState(() {
        this.permissionState = true;
      });
      _getAllContacts();
      return;
    }
    //Eğer kullanıcıya daha önce hiç izin sorulmadıysa
    //Veya kullanıcı kalıcı olarak reddetmediyse izin istiyoruz.
    if (permission.isUndetermined || !permission.isPermanentlyDenied) {
      await Permission.contacts.request();
      permission = await Permission.contacts.status;
      if (permission.isGranted) {
        setState(() {
          this.permissionState = true;
        });
        _getAllContacts();
        return;
      }
    }
  }

  //Eğer kullanıcı ayarlara gidip rehber iznini tekrar verir ise
  //_permission metodu tekrar çalışacak ve yetki verilmiş mi kontrol edecek.
  _openSettingsForPermission() async {
    openAppSettings();
    _permission();
  }

  _getAllContacts() async {
    if (this.permissionState) {
      await (Contacts.streamContacts()).forEach((element) {
        setState(() {
          this.contacts.add(new Row(
                element,
                false,
              ));
        });
      });
    }
  }

  _deleteSelected(int id) async {
    await Contacts.deleteContact();
  }

  //Eğer kullanıcı rehbere erişim izni vermemiş ise bu ekran açılacak.
  Widget _notPermitted() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Rehberinizi görüntülememiz için izninize ihtiyacımız var."),
          RaisedButton(
            child: Text(
              "Ayarları Aç",
            ),
            onPressed: _openSettingsForPermission,
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (!this.permissionState) {
      return _notPermitted();
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(top: 70, left: 10),
              height: 50,
              child: Text(
                "Contacts",
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: CheckboxListTile(
              value: false,
              onChanged: (value) {},
              title: Text("Tümünü Seç"),
            ),
          ),
          Expanded(
              child: FlatButton(
            child: Text("Sil"),
            onPressed: _deleteSelected(0),
          )),
          Expanded(
            flex: 9,
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Row row = contacts[index];
                return _contactCard(row);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(Row row) {
    return Card(
      margin: EdgeInsets.only(bottom: 6, top: 5, left: 10, right: 10),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            setState(() {
              row.checked = !row.checked;
            });
          },
          child: ListTile(
            title: Text(
              row.contact.displayName,
              style: TextStyle(color: Colors.black87),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              maxRadius: 20,
              minRadius: 20,
              child: Image.asset("assets/data/man.png"),
            ),
            trailing: Checkbox(
              activeColor: Colors.black87,
              value: row.checked,
              onChanged: (incomingValue) {
                setState(() {
                  row.checked = incomingValue;
                });
              },
            ),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
    );
  }

  @override
  Widget build(BuildContext context) {
    int id = 0 ;
    return Scaffold(
      body: _body(),
    );
  }
}
