import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState
    extends State<AdminProductsScreen> {

  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> deleteProduct(
    int productId) async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response =
        await http.delete(

      Uri.parse(
        "http://10.0.2.2:5138/api/Products/$productId",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      fetchProducts();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Produkt usunięty",
          ),
        ),
      );
    }
  }

  Future<void> fetchProducts() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response = await http.get(

      Uri.parse(
        "http://10.0.2.2:5138/api/Products",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      if (!mounted) return;

      setState(() {

        products =
            jsonDecode(response.body);

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
          "Produkty",
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            Colors.green,

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        onPressed: () async {

        final result =
          await Navigator.push(

        context,

    MaterialPageRoute(
      builder: (context) =>
          const AddProductScreen(),
    ),
  );
  if (result == true) {

    fetchProducts();
  }
},
      ),

      body:

          isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : ListView.builder(

                  itemCount:
                      products.length,

                  itemBuilder:
                      (context, index) {

                    final product =
                        products[index];

                    return Card(

                      margin:
                          const EdgeInsets.all(
                        10,
                      ),

                      child: ListTile(

                        title: Text(
                          product["name"],
                        ),

                        subtitle: Text(
                          "${product["price"]} zł",
                        ),

                        trailing: Row(

                          mainAxisSize:
                              MainAxisSize.min,

                          children: [

                            IconButton(

                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),

                              onPressed: () async {

  final result =
      await Navigator.push(

    context,

    MaterialPageRoute(
      builder: (context) =>
          EditProductScreen(
        product: product,
      ),
    ),
  );

  if (result == true) {

    fetchProducts();
  }
},
                            ),

                            IconButton(

                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),

                              onPressed: () async {

  final confirm =
      await showDialog<bool>(

    context: context,

    builder: (context) =>
        AlertDialog(

      title: const Text(
        "Usuń produkt",
      ),

      content: Text(
        "Czy na pewno usunąć ${product["name"]}?",
      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(
              context,
              false,
            );
          },

          child: const Text(
            "Anuluj",
          ),
        ),

        ElevatedButton(

          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                Colors.red,
          ),

          onPressed: () {

            Navigator.pop(
              context,
              true,
            );
          },

          child: const Text(
            "Usuń",
          ),
        ),
      ],
    ),
  );

  if (confirm == true) {

    await deleteProduct(
      product["id"],
    );
  }
},
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}