import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsAdminScreen extends StatefulWidget {

  final int orderId;

  const OrderDetailsAdminScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsAdminScreen> createState() =>
      _OrderDetailsAdminScreenState();
}

class _OrderDetailsAdminScreenState
    extends State<OrderDetailsAdminScreen> {

  Map? order;
  bool isLoading = true;

  String selectedStatus = "Nowe";

  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  Future<void> fetchOrder() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response = await http.get(

      Uri.parse(
        "http://10.0.2.2:5138/api/Orders/${widget.orderId}",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      setState(() {

        order =
            jsonDecode(response.body);

        selectedStatus =
            order!["status"];

        isLoading = false;
      });
    }
  }

  Future<void> updateStatus() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response = await http.put(
      Uri.parse(
        "http://10.0.2.2:5138/api/Orders/${widget.orderId}/status",
      ),

      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",
      },

      body: jsonEncode({
        "status":
            selectedStatus,
      }),
    );

    if (response.statusCode == 200) {
      await fetchOrder();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Status zaktualizowany",
        ),
      ),
    );
  }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: Text(
          "Zamówienie #${order!["id"]}",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
  padding: const EdgeInsets.all(20),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
      ),
    ],
  ),

  child: Row(
    children: [

      const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.green,
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),

      const SizedBox(width: 15),

      Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "${order!["user"]["firstName"]} ${order!["user"]["lastName"]}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              order!["user"]["email"],
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 20),

Card(
  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(18),
  ),

  child: Padding(
    padding:
        const EdgeInsets.all(16),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "Dane klienta",
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const Divider(),

        Text(
          "Telefon: ${order!["user"]["phoneNumber"] ?? "-"}",
        ),

        const SizedBox(height: 5),

        Text(
          "Adres: ${order!["user"]["addressLine"] ?? "-"}",
        ),

        Text(
          "${order!["user"]["postalCode"] ?? ""} ${order!["user"]["city"] ?? ""}",
        ),
      ],
    ),
  ),
),

const SizedBox(height: 15),

Card(
  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(18),
  ),

  child: Padding(
    padding:
        const EdgeInsets.all(16),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "Informacje o zamówieniu",
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const Divider(),

        Text(
          "Status: ${order!["status"]}",
        ),

        Text(
          "Płatność: ${order!["paymentMethod"]}",
        ),

        Text(
          "Dostawa: ${order!["deliveryMethod"]}",
        ),

        Text(
          "Koszt dostawy: ${order!["deliveryPrice"]} zł",
        ),

        Text(
          "Wartość zamówienia: ${order!["totalPrice"]} zł",
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),

            const SizedBox(height: 20),

            const Text(
              "Produkty",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...order!["items"].map<Widget>(
              (item) => Card(
  margin:
      const EdgeInsets.only(
    bottom: 10,
  ),

  child: ListTile(

    leading: const CircleAvatar(
      backgroundColor:
          Colors.green,
      child: Icon(
        Icons.shopping_bag,
        color: Colors.white,
      ),
    ),

    title: Text(
      item["productName"],
    ),

    subtitle: Text(
      "Ilość: ${item["quantity"]}",
    ),
  ),
),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 20),

Card(
  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(18),
  ),

  child: Padding(
    padding:
        const EdgeInsets.all(16),

    child: Column(
      children: [

        DropdownButtonFormField<String>(

          value: selectedStatus,

          decoration:
              const InputDecoration(
            labelText:
                "Status zamówienia",
          ),

          items: const [

            DropdownMenuItem(
              value: "Nowe",
              child: Text("Nowe"),
            ),

            DropdownMenuItem(
              value: "W realizacji",
              child: Text("W realizacji"),
            ),

            DropdownMenuItem(
              value: "Wysłane",
              child: Text("Wysłane"),
            ),

            DropdownMenuItem(
              value: "Dostarczone",
              child: Text("Dostarczone"),
            ),

            DropdownMenuItem(
              value: "Anulowane",
              child: Text("Anulowane"),
            ),
          ],

          onChanged: (value) {

            setState(() {

              selectedStatus =
                  value!;
            });
          },
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          height: 50,

          child: ElevatedButton(

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.green,
              foregroundColor:
                  Colors.white,
            ),

            onPressed:
                updateStatus,

            child: const Text(
              "Zapisz status",
            ),
          ),
        ),
      ],
    ),
  ),
),
          ]
      ),
      ),
    );
  }
}