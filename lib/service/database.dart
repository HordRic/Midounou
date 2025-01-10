import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserDetail(
      Map<String, dynamic> userinfoMap, String id) async {
    try {
      await _firestore.collection('users').doc(id).set(userinfoMap);
    } catch (e) {
      print("Error adding user detail: $e");
      throw e;
    }
  }

  Future<void> updateUserWallet(String id, String amount) async {
    try {
      await _firestore.collection("users").doc(id).update({"Wallet": amount});
    } catch (e) {
      print("Error updating user wallet: $e");
      throw e;
    }
  }

  Future<void> addFoodItem(
      Map<String, dynamic> foodInfoMap, String name) async {
    try {
      await _firestore.collection('foodItems').doc(name).set(foodInfoMap);
    } catch (e) {
      print("Error adding food item: $e");
      throw e;
    }
  }

  Stream<QuerySnapshot> getFoodItems() {
    try {
      return _firestore.collection('foodItems').snapshots();
    } catch (e) {
      print("Error getting food items: $e");
      throw e;
    }
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String userId) async {
    try {
      return _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .snapshots();
    } catch (e) {
      print("Error getting food cart: $e");
      throw e;
    }
  }

  addFoodToCart(Map<String, dynamic> addFoodtoCart, String s) {}
}
