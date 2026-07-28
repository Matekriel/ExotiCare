import 'package:flutter/material.dart';
import '../data/favorites_data.dart';
import '../data/cart_data.dart';
import 'product_details_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen
    extends StatefulWidget {

  const FavoritesScreen({
    super.key,
  });

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {

    bool favoritesChanged = false;

  @override
  Widget build(BuildContext context) {

    final favorites =
        FavoritesData.favoriteItems;

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              favoritesChanged,
            );
          },
        ),
        title: const Text(
          "Ulubione",
        ),
      ),

      body:

          favorites.isEmpty

              ? const Center(
                  child: Text(
                    "Brak ulubionych produktów",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                )

              : ListView.builder(

                  padding:
                      const EdgeInsets.all(12),

                  itemCount:
                      favorites.length,

                  itemBuilder:
                      (context, index) {

                    final item =
                        favorites[index];

                    return InkWell(

  borderRadius:
      BorderRadius.circular(18),

  onTap: () {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
            ProductDetailsScreen(

          title: item["title"],

          price:
              item["price"]
                  .toString(),

          image: item["image"],

          description: item["description"],
          productId: item["productId"],
        ),
      ),
    );
  },

  child: Card(

  elevation: 3,

  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(18),
  ),

  margin:
      const EdgeInsets.only(
    bottom: 16,
  ),

  child: Padding(
    padding:
        const EdgeInsets.all(12),

    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(
          width: 110,
          height: 110,

          decoration: BoxDecoration(
            color: Colors.grey[200],

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

            child: Image.network(
              item["image"],

              errorBuilder:
                  (
                    context,
                    error,
                    stackTrace,
                  ) {

                return const Icon(
                  Icons.image,
                  size: 50,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  Expanded(
                    child: Text(
                      item["title"],

                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(

                    onPressed: () async {

  final prefs =
      await SharedPreferences
          .getInstance();

  final userId =
      prefs.getInt("userId");

  final token =
    prefs.getString("token");

  if (userId == null) {
    return;
  }

  final response =
    await http.delete(

      Uri.parse(
        "http://10.0.2.2:5138/api/Favorites?userId=$userId&productId=${item["productId"]}",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

  if (response.statusCode == 200) {

    setState(() {

      FavoritesData.removeFavorite(
        item["productId"],
      );
    });
    favoritesChanged = true;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "Usunięto z ulubionych",
        ),
      ),
    );
  }
},

                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                "${item["price"]} zł",

                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: item["stock"] > 0
                          ? Colors.green.shade100
                          : Colors.red.shade100,

                      borderRadius:
                          BorderRadius.circular(10),
                    ),

                    child: Text(
                      item["stock"] > 0
                          ? "Dostępne: ${item["stock"]}"
                          : "Brak w magazynie",

                      style: TextStyle(
                        color: item["stock"] > 0
                            ? Colors.green
                            : Colors.red,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,

                    foregroundColor:
                        Colors.white,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  onPressed: () {

                    CartData.addProduct({

                      "productId":
                          item[
                              "productId"],

                      "title":
                          item["title"],

                      "price":
                          double.parse(
                        item["price"]
                            .toString(),
                      ),

                      "image":
                          item["image"],

                      "quantity": 1,
                    });

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(
                        content: Text(
                          "Dodano do koszyka",
                        ),
                      ),
                    );
                  },

                  child: const Text(
                    "Dodaj do koszyka",
                  ),
                ),
              ),
            ],
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