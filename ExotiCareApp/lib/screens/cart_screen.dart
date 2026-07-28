import 'package:flutter/material.dart';
import '../data/cart_data.dart';
import 'payment_screen.dart';
import 'complete_profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState
    extends State<CartScreen> {

  List<Map<String, dynamic>> get cartItems =>
    CartData.cartItems;

  double get totalPrice {

  double total = 0;

  for (var item in cartItems) {

    total +=
    double.parse(
      item["price"].toString(),
    ) *
    item["quantity"];
  }

  return total;
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Koszyk"),
      ),

      body:

          cartItems.isEmpty

              ? const Center(
                  child: Text(
                    "Koszyk jest pusty",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                )

              : Column(
                  children: [

                    Expanded(
                      child: ListView.builder(

                        padding:
                            const EdgeInsets.all(12),

                        itemCount:
                            cartItems.length,

                        itemBuilder:
                            (context, index) {

                          final item =
                              cartItems[index];

                          return Card(

                            margin:
                                const EdgeInsets.only(
                              bottom: 14,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),

                            child: Padding(
                              padding:
                                  const EdgeInsets.all(
                                12,
                              ),

                              child: Row(
                                children: [

                                  Container(
                                    width: 90,
                                    height: 90,

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.grey[200],

                                      borderRadius:
                                          BorderRadius.circular(
                                        14,
                                      ),
                                    ),

                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(
                                        10,
                                      ),

                                      child:
                                          Image.network(
                                        item["image"],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 14,
                                  ),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [

                                        Text(
                                          item["title"],

                                          style:
                                              const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 10,
                                        ),

                                        Text(
                                          "${(double.parse(item["price"].toString()) * item["quantity"]).toStringAsFixed(2)} zł",
                                          

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.green,

                                            fontSize: 22,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),

Row(
  children: [

    IconButton(

      onPressed: () {

        setState(() {

          CartData.decreaseQuantity(
            index,
          );
        });
      },

      icon: const Icon(
        Icons.remove_circle,
        color: Colors.green,
      ),
    ),

    Text(
      item["quantity"].toString(),

      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    IconButton(

      onPressed: () {

        setState(() {

          CartData.increaseQuantity(
            index,
          );
        });
      },

      icon: const Icon(
        Icons.add_circle,
        color: Colors.green,
      ),
    ),
  ],
),
                                      ],
                                    ),
                                  ),

                                  IconButton(

                                    onPressed: () {

                                      setState(() {

                                        CartData.removeProduct(index);
                                      });
                                    },

                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Container(

                      padding:
                          const EdgeInsets.all(20),

                      decoration: const BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),

                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              const Text(
                                "Razem:",

                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              Text(
                                "${totalPrice.toStringAsFixed(2)} zł",

                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Colors.green,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 55,

                            child: ElevatedButton(

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green,

                                foregroundColor:
                                    Colors.white,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),

                              onPressed: () async {

  final prefs =
      await SharedPreferences
          .getInstance();

  final userId =
      prefs.getInt("userId");
      print(userId);

  final token =
      prefs.getString("token");

  if (userId == null || token == null) {
    return;
  }

  final response = await http.get(

    Uri.parse(
      "http://10.0.2.2:5138/api/Users/$userId",
    ),

    headers: {
      "Authorization":
          "Bearer $token",
    },
  );

  if (response.statusCode == 200) {

    final data =
        jsonDecode(response.body);

    bool missingData =

    data["firstName"] == null ||
    data["firstName"].toString().trim().isEmpty ||

    data["lastName"] == null ||
    data["lastName"].toString().trim().isEmpty ||

    data["phoneNumber"] == null ||
    data["phoneNumber"].toString().trim().isEmpty ||

    data["addressLine"] == null ||
    data["addressLine"].toString().trim().isEmpty ||

    data["postalCode"] == null ||
    data["postalCode"].toString().trim().isEmpty ||

    data["city"] == null ||
    data["city"].toString().trim().isEmpty;

    if (missingData) {

      final result = await Navigator.push(

      context,

      MaterialPageRoute(
        builder: (context) =>
            CompleteProfileScreen(
          totalPrice: totalPrice,
        ),
      ),
    );

    if (result == true) {

      Navigator.pop(context, true);

    }

    } else {

      final result = await Navigator.push(

        context,

        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            totalPrice: totalPrice,
          ),
        ),
      );

      if (result == true) {

        Navigator.pop(context, true);

      }
    }
  }
},

                              child: const Text(
                                "Przejdź do płatności",

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}