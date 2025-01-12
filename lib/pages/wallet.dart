import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midounou/service/database.dart';
import 'package:midounou/service/shared_pref.dart';
import 'package:midounou/widget/widget_support.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String? wallet, id;
  int? add;
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getthesharedpref() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      id = user.uid;
      wallet = await SharedPreferenceHelper().getUserWallet();
      if (wallet == null) {
        // Initialiser le portefeuille avec une valeur par défaut
        wallet = "0";
        await SharedPreferenceHelper().saveUserWallet(wallet!);
        await DatabaseMethods().updateUserWallet(id!, wallet!);
        print("Initialized wallet with default value: $wallet");
      } else {
        print("User ID: $id, Wallet: $wallet");
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> addFunds(String amount) async {
    if (id != null && amount.isNotEmpty) {
      add = int.parse(amount);
      wallet = (int.parse(wallet!) + add!).toString();
      await DatabaseMethods().updateUserWallet(id!, wallet!);
      await SharedPreferenceHelper().saveUserWallet(wallet!);
      if (mounted) {
        setState(() {});
      }
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  Text("Funds added successfully"),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
      ),
      body: wallet == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 60.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      elevation: 2.0,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Center(
                          child: Text(
                            "Wallet",
                            style: AppWidget.HeadLineTextFeildStyle(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/wallet.png",
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 40.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Wallet",
                                  style: AppWidget.LightTextFeildStyle(),
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  "\$${wallet ?? '0'}",
                                  style: AppWidget.boldTextFeildStyle(),
                                ),
                                // Ajout de messages de débogage
                                Text("User ID: $id"),
                                Text("Wallet Balance: $wallet"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Add money",
                        style: AppWidget.semiBooldTextFeildStyle(),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAmountButton("100"),
                        _buildAmountButton("500"),
                        _buildAmountButton("1000"),
                        _buildAmountButton("2000"),
                      ],
                    ),
                    const SizedBox(height: 50.0),
                    GestureDetector(
                      onTap: openEdit,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20.0),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "Add Money",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAmountButton(String amount) {
    return GestureDetector(
      onTap: () {
        addFunds(amount);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE9E2E2)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          "\$$amount",
          style: AppWidget.semiBooldTextFeildStyle(),
        ),
      ),
    );
  }

  Future openEdit() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel),
                      ),
                      const SizedBox(width: 60.0),
                      const Center(
                        child: Text(
                          "Add Money",
                          style: TextStyle(
                            color: Color(0xFF008080),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const Text("Amount"),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Amount',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        addFunds(amountController.text);
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Pay",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
