import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'order_details_admin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() =>
      _AdminOrdersScreenState();
}

class _AdminOrdersScreenState
    extends State<AdminOrdersScreen> {

  List orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {

    final prefs =
        await SharedPreferences
            .getInstance();

    final token =
        prefs.getString("token");

    final response = await http.get(

      Uri.parse(
        "http://10.0.2.2:5138/api/Orders",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      setState(() {

        orders =
            jsonDecode(response.body);

        isLoading = false;
      });

    } else {

      print(response.statusCode);
      print(response.body);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Wszystkie zamówienia",
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : ListView.builder(

              itemCount:
                  orders.length,

              itemBuilder:
                  (context, index) {

                final order =
                    orders[index];

                return Card(

                  margin:
                      const EdgeInsets.all(10),

                  child: ListTile(

                    title: Text(
                      "Zamówienie #${order["id"]}",
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          order["userName"] ??
                              "",
                        ),

                        Text(
                          "${order["totalPrice"]} zł",
                        ),

                        Text(
                          order["status"],
                        ),
                      ],
                    ),

                    trailing:
                        const Icon(
                      Icons.arrow_forward_ios,
                    ),

                    onTap: () {

                      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) =>
        OrderDetailsAdminScreen(
      orderId: order["id"],
    ),
  ),
);

                    },
                  ),
                );
              },
            ),
    );
  }
}