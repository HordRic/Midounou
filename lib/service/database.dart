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

  Stream<QuerySnapshot> getFoodCart(String userId) {
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

  Future<void> addFoodToCart(
      Map<String, dynamic> addFoodtoCart, String userId) async {
    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .add(addFoodtoCart);
    } catch (e) {
      print("Error adding food to cart: $e");
      throw e;
    }
  }

  Future<void> clearUserCart(String userId) async {
    try {
      var cartItems = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();

      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Error clearing user cart: $e");
      throw e;
    }
  }

  Future<DocumentSnapshot> getUserDetails(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print("Error getting user details: $e");
      throw e;
    }
  }
}
