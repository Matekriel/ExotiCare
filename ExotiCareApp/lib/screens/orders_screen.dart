import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'order_details_screen.dart';

class OrdersScreen
    extends StatefulWidget {

  const OrdersScreen({
    super.key,
  });

  @override
  State<OrdersScreen> createState() =>
      _OrdersScreenState();
}

class _OrdersScreenState
    extends State<OrdersScreen> {

  List orders = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchOrders();
  }

  Future<void> fetchOrders() async {

    setState(() {
      isLoading = true;
    });

    final prefs =
        await SharedPreferences
            .getInstance();

    final userId =
        prefs.getInt("userId");

    if (userId == null) {
      return;
    }

    try {

      final token =
          prefs.getString("token");

      final response = await http.get(

        Uri.parse(
          "http://10.0.2.2:5138/api/Orders/user/$userId",
        ),

        headers: {
          "Authorization":
              "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        setState(() {

          orders =
              jsonDecode(
                response.body,
              );

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Moje zamówienia",
        ),
      ),

      body:

          isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : orders.isEmpty

                  ? const Center(
                      child: Text(
                        "Brak zamówień",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )

                  : ListView.builder(

                      padding:
                          const EdgeInsets.all(
                        12,
                      ),

                      itemCount:
                          orders.length,

                      itemBuilder:
                          (context, index) {

                        final order =
                            orders[index];

                        return InkWell(

  borderRadius:
      BorderRadius.circular(18),

  onTap: () {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
            OrderDetailsScreen(
          order: order,
        ),
      ),
    );
  },

  child: Card(

                          margin:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),

                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              18,
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  "Zamówienie #${order["id"]}",

                                  style:
                                      const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 12,
                                ),

                                Text(
                                  "Płatność: ${order["paymentMethod"]}",
                                ),

                                Text(
                                  "Dostawa: ${order["deliveryMethod"]}",
                                ),

                                Text(
                                  "Kwota: ${order["totalPrice"]} zł",
                                ),

                                const SizedBox(height: 6),

Text(

  "Status: ${order["status"]}",

  style: TextStyle(

    color:
        order["status"] == "Anulowane"
            ? Colors.red
            : Colors.green,

    fontWeight: FontWeight.bold,
  ),
),

                                const SizedBox(
                                  height: 10,
                                ),

                                const Divider(),

                                const SizedBox(
                                  height: 10,
                                ),

                                const Text(
                                  "Produkty:",

                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                ...order["orderItems"]
                                    .map<Widget>(
                                  (item) {

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        bottom: 6,
                                      ),

                                      child: Text(
                                        "• ${item["productName"]} x${item["quantity"]}",
                                      ),
                                    );
                                  },
                                ).toList(),
                                const SizedBox(height: 14),

if (order["status"] == "Nowe")

SizedBox(
  width: double.infinity,

  child: ElevatedButton(

    style:
        ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),

    onPressed: () async {

      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString("token");

      final response =
          await http.put(

        Uri.parse(
          "http://10.0.2.2:5138/api/Orders/cancel/${order["id"]}",
        ),

        headers: {
          "Authorization":
              "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(
            content: Text(
              "Zamówienie anulowane",
            ),
          ),
        );

        await fetchOrders();
      }
    },

    child: const Text(
      "Anuluj zamówienie",
    ),
  ),
),
                              ],
                            ),
                          ),
                        ),
                        );
                      },
                    ),
    );
  }
  
}