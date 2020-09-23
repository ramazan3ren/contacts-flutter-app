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
  Row(this.contact, this.checked);
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
          this.contacts.add(new Row(element, false));
        });
      });
    }
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
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        Row row = contacts[index];
        return _contactCard(row);
      },
    );
  }

  Widget _contactCard(Row row) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              row.contact.displayName,
              style: TextStyle(color: Colors.black87),
            ),
            leading: Icon(
              Icons.account_circle,
              size: 45,
              color: Colors.black87,
            ),
            trailing: Checkbox(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }
}
