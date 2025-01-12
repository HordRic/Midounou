import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserDetail(
      Map<String, dynamic> userinfoMap, String id) async {
    try {
      await _firestore.collection('users').doc(id).set(userinfoMap);
    } catch (e) {
      print("Error adding user detail: $e");
      rethrow;
    }
  }

  Future<void> updateUserWallet(String id, String amount) async {
    try {
      await _firestore.collection("users").doc(id).update({"Wallet": amount});
    } catch (e) {
      print("Error updating user wallet: $e");
      rethrow;
    }
  }

  Future<void> addFoodItem(
      Map<String, dynamic> foodInfoMap, String name) async {
    try {
      await _firestore.collection('foodItems').doc(name).set(foodInfoMap);
    } catch (e) {
      print("Error adding food item: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getFoodItems() {
    try {
      return _firestore.collection('foodItems').snapshots();
    } catch (e) {
      print("Error getting food items: $e");
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserDetails(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print("Error getting user details: $e");
      rethrow;
    }
  }

  // New methods for handling orders
  Future<void> addPendingOrder(
      Map<String, dynamic> orderInfo, String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).set(orderInfo);
    } catch (e) {
      print("Error adding pending order: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getPendingOrders() {
    try {
      return _firestore
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .snapshots();
    } catch (e) {
      print("Error getting pending orders: $e");
      rethrow;
    }
  }

  Future<void> approveOrder(String orderId) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': 'approved'});
    } catch (e) {
      print("Error approving order: $e");
      rethrow;
    }
  }

  Future<void> rejectOrder(String orderId) async {
    try {
      DocumentSnapshot orderSnapshot =
          await _firestore.collection('orders').doc(orderId).get();
      Map<String, dynamic> orderData =
          orderSnapshot.data() as Map<String, dynamic>;
      String userId = orderData['userId'];
      int orderTotal = int.parse(orderData['total']);

      // Récupérer le portefeuille de l'utilisateur
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      int currentWalletAmount = int.parse(userData['Wallet']);

      // Rembourser l'utilisateur
      await _firestore.collection('users').doc(userId).update({
        'Wallet': (currentWalletAmount + orderTotal).toString(),
      });

      // Mettre à jour le statut de la commande
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': 'rejected'});
    } catch (e) {
      print("Error rejecting order: $e");
      rethrow;
    }
  }

  Future<void> markOrderAsDelivered(String orderId) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': 'delivered'});
    } catch (e) {
      print("Error marking order as delivered: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUserOrders(String userId) {
    try {
      return _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .snapshots();
    } catch (e) {
      print("Error getting user orders: $e");
      rethrow;
    }
  }

  Future<void> deleteFoodItem(String foodId) async {
    try {
      await _firestore.collection('foodItems').doc(foodId).delete();
    } catch (e) {
      print("Error deleting food item: $e");
      rethrow;
    }
  }

  // Ajouter la méthode deleteOrder
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      print("Error deleting order: $e");
      rethrow;
    }
  }
}
