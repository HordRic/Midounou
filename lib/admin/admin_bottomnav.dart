import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:midounou/admin/add_food.dart';
import 'package:midounou/admin/admin_orders.dart';
import 'package:midounou/admin/home_admin.dart';

class AdminBottomNav extends StatefulWidget {
  const AdminBottomNav({super.key});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late HomeAdmin homeAdmin;
  late AddFood addFood;
  late AdminOrders adminOrders;

  @override
  void initState() {
    homeAdmin = const HomeAdmin();
    addFood = const AddFood();
    adminOrders = const AdminOrders();
    pages = [homeAdmin, addFood, adminOrders];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.add,
            color: Colors.white,
          ),
          Icon(
            Icons.list,
            color: Colors.white,
          ),
        ],
      ),
      body: pages[currentTabIndex], // Affichage de la page actuelle
    );
  }
}
