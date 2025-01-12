import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midounou/service/database.dart';
import 'package:midounou/service/shared_pref.dart';
import 'package:midounou/widget/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id, wallet;
  int total = 0, amount2 = 0;
  Stream<QuerySnapshot>? foodStream;
  Stream<QuerySnapshot>? ordersStream;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    ontheload();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          amount2 = total;
        });
      }
    });
  }

  getthesharedpref() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      id = user.uid;
      wallet = await SharedPreferenceHelper().getUserWallet();
      if (id == null) {
        print("User ID is null");
      } else {
        print("User ID: $id");
      }
      if (wallet == null) {
        print("User wallet is null");
      } else {
        print("User wallet: $wallet");
      }
    } else {
      print("No user is signed in");
    }
    if (mounted) {
      setState(() {});
    }
  }

  ontheload() async {
    await getthesharedpref();
    if (id != null) {
      foodStream = DatabaseMethods().getFoodCart(id!);
      ordersStream = DatabaseMethods().getUserOrders(id!);
      if (mounted) {
        setState(() {});
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Failed to load food cart. User ID is null.",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    }
  }

  Widget foodCart() {
    return StreamBuilder(
      stream: foodStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No items in the cart'));
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              final data = ds.data() as Map<String, dynamic>?;
              total = total + int.parse(data?["Total"] ?? '0');
              return Container(
                margin: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        if (data != null && data.containsKey("Quantity"))
                          Container(
                            height: 90,
                            width: 40,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text(data["Quantity"])),
                          ),
                        const SizedBox(width: 20.0),
                        if (data != null && data.containsKey("Image"))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              data["Image"],
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 20.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data != null && data.containsKey("Name"))
                              Text(
                                data["Name"],
                                style: AppWidget.semiBooldTextFeildStyle(),
                              ),
                            if (data != null && data.containsKey("Total"))
                              Text(
                                "\$" + data["Total"],
                                style: AppWidget.semiBooldTextFeildStyle(),
                              ),
                          ],
                        ),
                      ],
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

  Widget ordersList() {
    return StreamBuilder(
      stream: ordersStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders found'));
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              final data = ds.data() as Map<String, dynamic>?;
              Color statusColor;
              if (data?['status'] == 'approved') {
                statusColor = Colors.green;
              } else if (data?['status'] == 'rejected') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.blue;
              }
              return Container(
                margin: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: statusColor.withOpacity(0.1),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        if (data != null && data.containsKey("Image"))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              data["Image"],
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data != null && data.containsKey("Name"))
                                Text(
                                  data["Name"],
                                  style: AppWidget.semiBooldTextFeildStyle(),
                                ),
                              if (data != null && data.containsKey("Total"))
                                Text(
                                  "\$" + data["Total"],
                                  style: AppWidget.semiBooldTextFeildStyle(),
                                ),
                              if (data != null && data.containsKey("Quantity"))
                                Text(
                                  "Quantity: " + data["Quantity"],
                                  style: AppWidget.semiBooldTextFeildStyle(),
                                ),
                              if (data != null && data.containsKey("status"))
                                Text(
                                  "Status: " + data["status"],
                                  style: AppWidget.semiBooldTextFeildStyle(),
                                ),
                            ],
                          ),
                        ),
                        if (data?['status'] != 'pending')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await DatabaseMethods().deleteOrder(ds.id);
                              if (data?['status'] == 'rejected') {
                                int currentWalletAmount = int.parse(wallet!);
                                int orderTotal =
                                int.parse(data?['Total'] ?? '0');
                                await DatabaseMethods().updateUserWallet(
                                    id!,
                                    (currentWalletAmount + orderTotal)
                                        .toString());
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.greenAccent,
                                    content: Text(
                                      "Order status deleted",
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                      ],
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
      appBar: AppBar(
        title: const Text("Order"),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Center(
                  child: Text(
                    "Food Cart",
                    style: AppWidget.HeadLineTextFeildStyle(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: foodCart(),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Text(
                    "\$$total",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () async {
                if (id != null && wallet != null) {
                  int currentWalletAmount = int.parse(wallet!);
                  if (currentWalletAmount >= amount2) {
                    // Deduct the amount from the user's wallet
                    await DatabaseMethods().updateUserWallet(
                        id!, (currentWalletAmount - amount2).toString());

                    // Add order to pending orders collection
                    String orderId =
                    DateTime.now().millisecondsSinceEpoch.toString();
                    QuerySnapshot cartSnapshot =
                    await DatabaseMethods().getFoodCart(id!).first;
                    List<Map<String, dynamic>> items = cartSnapshot.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    Map<String, dynamic> orderInfo = {
                      "userId": id,
                      "userName": await SharedPreferenceHelper().getUserName(),
                      "total": total.toString(),
                      "status": "pending",
                      "items": items,
                    };
                    await DatabaseMethods().addPendingOrder(orderInfo, orderId);

                    // Clear user cart
                    await DatabaseMethods().clearUserCart(id!);

                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.greenAccent,
                          content: Text(
                            "Order placed successfully",
                            style: TextStyle(fontSize: 18.0),
                          )));
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text(
                            "Insufficient funds",
                            style: TextStyle(fontSize: 18.0),
                          )));
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          "Failed to checkout. User ID or wallet is null.",
                          style: TextStyle(fontSize: 18.0),
                        )));
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 20.0),
                child: const Center(
                  child: Text(
                    "CheckOut",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(
                "Order Status",
                style: AppWidget.boldTextFeildStyle(),
              ),
            ),
            const SizedBox(height: 10.0), // Réduire l'espace ici
            Expanded(
              child: ordersList(),
            ),
          ],
        ),
      ),
    );
  }
}