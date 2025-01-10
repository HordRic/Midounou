import 'package:flutter/material.dart';

import '../service/database.dart';
import '../service/shared_pref.dart';
import '../widget/widget_support.dart';

class Details extends StatefulWidget {
  final String image, name, detail, price;
  Details(
      {required this.detail,
      required this.image,
      required this.name,
      required this.price});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int a = 1, total = 0;
  String? id;

  @override
  void initState() {
    super.initState();
    ontheload();
    total = int.parse(widget.price);
  }

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.black,
                  )),
              SizedBox(height: 10.0),
              Image.network(
                widget.image,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 15.0),
              Text(
                widget.name,
                style: AppWidget.semiBooldTextFeildStyle(),
              ),
              SizedBox(height: 10.0),
              Text(
                widget.detail,
                style: AppWidget.LightTextFeildStyle(),
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (a > 1) {
                        --a;
                        total = total - int.parse(widget.price);
                      }
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    a.toString(),
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                  SizedBox(width: 20.0),
                  GestureDetector(
                    onTap: () {
                      ++a;
                      total = total + int.parse(widget.price);
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Text(
                    "Delivery Time",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                  SizedBox(width: 25.0),
                  Icon(
                    Icons.alarm,
                    color: Colors.black54,
                  ),
                  SizedBox(width: 5.0),
                  Text(
                    "30 min",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  )
                ],
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Price",
                        style: AppWidget.semiBooldTextFeildStyle(),
                      ),
                      Text(
                        "\$" + total.toString(),
                        style: AppWidget.HeadLineTextFeildStyle(),
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (id != null) {
                        Map<String, dynamic> addFoodtoCart = {
                          "Name": widget.name,
                          "Quantity": a.toString(),
                          "Total": total.toString(),
                          "Image": widget.image
                        };
                        await DatabaseMethods()
                            .addFoodToCart(addFoodtoCart, id!);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.orangeAccent,
                            content: Text(
                              "Food Added to Cart",
                              style: TextStyle(fontSize: 18.0),
                            )));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text(
                              "Failed to add food to cart. User ID is null.",
                              style: TextStyle(fontSize: 18.0),
                            )));
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Add to cart",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontFamily: 'Poppins'),
                          ),
                          SizedBox(width: 30.0),
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.0),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
