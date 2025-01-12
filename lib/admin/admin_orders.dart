import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:midounou/service/database.dart';
import 'package:midounou/widget/widget_support.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  Stream<QuerySnapshot>? ordersStream;

  @override
  void initState() {
    super.initState();
    ordersStream = DatabaseMethods().getPendingOrders();
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
          return const Center(child: Text('No pending orders'));
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              final data = ds.data() as Map<String, dynamic>?;
              if (data == null) {
                return const Center(child: Text('No data available'));
              }
              List<dynamic> items = data['items'] ?? [];
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Customer: ${data['userName']}",
                          style: AppWidget.semiBooldTextFeildStyle(),
                        ),
                        const SizedBox(height: 10.0),
                        ...items.map((item) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.containsKey("Image"))
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    item["Image"],
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 10.0),
                              if (item.containsKey("Name"))
                                Text(
                                  item["Name"],
                                  style: AppWidget.semiBooldTextFeildStyle(),
                                ),
                              if (item.containsKey("Total"))
                                Text(
                                  "\$${item["Total"]}",
                                  style: AppWidget.semiBooldTextFeildStyle(),
                                ),
                              if (item.containsKey("Quantity"))
                                Text(
                                  "Quantity: ${item["Quantity"]}",
                                  style: AppWidget.semiBooldTextFeildStyle(),
                                ),
                              const SizedBox(height: 10.0),
                            ],
                          );
                        }).toList(),
                        const Divider(),
                        Text(
                          "Total: \$${data['total']}",
                          style: AppWidget.semiBooldTextFeildStyle(),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await DatabaseMethods().approveOrder(ds.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await DatabaseMethods().rejectOrder(ds.id);
                              },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Orders"),
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
                    "Pending Orders",
                    style: AppWidget.HeadLineTextFeildStyle(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ordersList(),
            ),
          ],
        ),
      ),
    );
  }
}
