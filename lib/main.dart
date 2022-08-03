import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Employees'),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('employees').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No Records"),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot db = snapshot.data!.docs[index];
                    DateTime date =
                        DateTime.parse(db['joindate'].toDate().toString());
                    String joindate =
                        "${(date.day).toString().padLeft(2, '0')}/${(date.month).toString().padLeft(2, '0')}/${date.year}";

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      subtitle: Text("Join Date: $joindate"),
                      title: Row(
                        children: [
                          Text(
                            db['name'],
                          ),
                          getexperience((db['joindate'])) >= 5
                              ? Icon(
                                  CupertinoIcons.flag_fill,
                                  color: Colors.green.shade900,
                                )
                              : const SizedBox()
                        ],
                      ),
                    );
                  });
            }));
  }
}

int getexperience(date) {
  var today = DateTime.now();
  DateTime joinDate = DateTime.parse(date.toDate().toString());
  var experience = today.year - joinDate.year;
  var m = today.month - joinDate.month;
  if (m < 0 || (m == 0 && today.day < joinDate.day)) {
    experience--;
  }
  return experience;
}
