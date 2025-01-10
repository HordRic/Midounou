import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midounou/service/database.dart';
import 'package:midounou/widget/widget_support.dart';

import 'details.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? fooditemStream;
  String? userName;

  ontheload() async {
    fooditemStream = await DatabaseMethods().getFoodItems();
    if (mounted) {
      setState(() {});
    }
  }

  getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc['name'];
      });
    }
  }

  @override
  void initState() {
    ontheload();
    getUserInfo();
    super.initState();
  }

  Widget allItems() {
    return StreamBuilder(
      stream: fooditemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(child: Text('Aucun article trouvé'));
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Details(
                        detail: ds["Detail"],
                        image: ds["Image"],
                        name: ds["Name"],
                        price: ds["Price"],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(4),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              ds["Image"],
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            ds["Name"],
                            style: AppWidget.semiBooldTextFeildStyle(),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            "Déliceux et energétique",
                            style: AppWidget.LightTextFeildStyle(),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            ds["Price"] + " FrCFA",
                            style: AppWidget.semiBooldTextFeildStyle(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(
          top: 50.0,
          left: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hello, ${userName ?? 'User'}",
                    style: AppWidget.boldTextFeildStyle()),
                Container(
                  margin: EdgeInsets.only(right: 20.0),
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Text("Delicious Food", style: AppWidget.HeadLineTextFeildStyle()),
            Text("Discover and Get Great Food",
                style: AppWidget.LightTextFeildStyle()),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 20.0),
                child: allItems(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
