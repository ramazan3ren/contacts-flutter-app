import 'package:flutter/material.dart';
import 'package:flutter_contact/base_contacts.dart';
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

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = [];
  

  @override
  void initState() {
    super.initState();
    _getAllContacts();
    
  }

  _getAllContacts() async {
    List<Contact> _contacts = await (Contacts.streamContacts()).toList();
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            Contact contact = contacts[index];
            return Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                margin: EdgeInsets.all(10),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    
                    title: Text(
                      contact.displayName,
                      style: TextStyle(color: Colors.black87),
                    ),
                    leading: Icon(
                      Icons.account_circle,
                      size: 45,
                      color: Colors.black87,
                    ),
                    trailing: Checkbox(
                      value: false,
                      onChanged: (incomingValue) {},
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
