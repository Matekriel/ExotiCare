import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import '../data/cart_data.dart';
import 'orders_screen.dart';
import '../data/favorites_data.dart';
import 'favorites_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_panel_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() =>
      _ShopScreenState();
}

class _ShopScreenState
    extends State<ShopScreen> {

    String selectedSort = "Domyślny";

    final List<String> sortOptions = [
      "Domyślny",
      "Od najniższej ceny",
      "Od najwyższej ceny",
    ];

    String selectedCategory = "Wszystkie";
    bool onlyAvailable = false;

    final List<String> categories = [
      "Wszystkie",
      "Karmówka",
      "Pojemniki plastikowe",
      "Terraria",
      "Podłoże",
      "Wystrój",
      "Akcesoria hodowlane",
      "Inne",
    ];

    void applyFilters() {

      filteredProducts = originalProducts.where((product) {

        bool categoryMatch =
            selectedCategory == "Wszystkie"
                ? true
                : product.category == selectedCategory;

        bool stockMatch =
            !onlyAvailable || product.stock > 0;

        return categoryMatch && stockMatch;

      }).toList();

      if (selectedSort == "Od najniższej ceny") {

        filteredProducts.sort(
          (a, b) => a.price.compareTo(b.price),
        );

      } else if (selectedSort == "Od najwyższej ceny") {

        filteredProducts.sort(
          (a, b) => b.price.compareTo(a.price),
        );
      }
    }

    void sortProducts(String sortType) {

      setState(() {

        selectedSort = sortType;

        applyFilters();
      });
    }

    void filterCategory(String category) {

      setState(() {

        selectedCategory = category;

        applyFilters();
      });
    }

  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Product> originalProducts = [];

  bool isLoading = true;
  String role = "";

  @override
  void initState() {
    super.initState();

    fetchProducts();
    fetchFavorites();
    loadRole();
  }

  Future<void> loadRole() async {

  final prefs =
      await SharedPreferences
          .getInstance();

  setState(() {

    role =
        prefs.getString("role")
            ?? "";
  });
}

  Future<void> fetchProducts() async {

    try {
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

        final List data =
            jsonDecode(response.body);

        setState(() {

          products =
              data
                  .map(
                    (json) =>
                        Product.fromJson(json),
                  )
                  .toList();

          originalProducts =
              List.from(products);

          filteredProducts =
              List.from(products);

          applyFilters();

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

      print(e);
    }
  }

  Future<void> fetchFavorites() async {

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

    final response =
        await http.get(

      Uri.parse(
        "http://10.0.2.2:5138/api/Favorites/user/$userId",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      final List data =
          jsonDecode(
            response.body,
          );

      FavoritesData.setFavorites(

        data.map<Map<String, dynamic>>(
          (favorite) {

            return {

              "productId":
                  favorite["product"]["id"],

              "title":
                  favorite["product"]["name"],

              "price":
                  favorite["product"]["price"],

              "image":
                  favorite["product"]["imageUrl"],

              "stock": favorite["product"]["stock"],
            };
          },
        ).toList(),
      );

      setState(() {});
    }

  } catch (e) {

    print(e);
  }
}

void searchProducts(String query) {

  setState(() {

    filteredProducts =
        products.where((product) {

      return product.name
          .toLowerCase()
          .contains(
            query.toLowerCase(),
          );

    }).toList();
  });
}

void showFilters() {

  showModalBottomSheet(

    context: context,

    builder: (context) {

      return Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          ListTile(
            title: const Text(
              "Domyślnie",
            ),

            onTap: () {

              sortProducts(
                "Domyślny",
              );

              Navigator.pop(context);
            },
          ),

          ListTile(
            title: const Text(
              "Od najniższej ceny",
            ),

            onTap: () {

              sortProducts(
                "Od najniższej ceny",
              );

              Navigator.pop(context);
            },
          ),

          ListTile(
            title: const Text(
              "Od najwyższej ceny",
            ),

            onTap: () {

              sortProducts(
                "Od najwyższej ceny",
              );

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

void showAvailabilityFilters() {

  showModalBottomSheet(

    context: context,

    builder: (context) {

      return StatefulBuilder(

        builder: (context, setModalState) {

          return Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              const SizedBox(height: 10),

              const Text(
                "Filtry",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SwitchListTile(

                title: const Text(
                  "Tylko dostępne produkty",
                ),

                value: onlyAvailable,

                onChanged: (value) {

                  setModalState(() {
                    onlyAvailable = value;
                  });

                  setState(() {
                    applyFilters();
                  });
                },
              ),

              const SizedBox(height: 15),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      drawer: Drawer(
        child: Column(
          children: [

            Container(
              height: 90,

              alignment: Alignment.centerLeft,

              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              color: Colors.green,

              child: Row(
                children: const [

                  Text(
                    "Kategorie",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                children: categories.map((category) {

                  return ListTile(

                    leading: const Icon(
                      Icons.chevron_right,
                    ),

                    title: Text(category),

                    selected:
                        selectedCategory ==
                        category,

                    onTap: () {

                      Navigator.pop(context);

                      filterCategory(
                        category,
                      );
                    },
                  );

                }).toList(),
              ),
            ),
          ],
        ),
      ),

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        automaticallyImplyLeading: false,

        leading: Builder(
          builder: (context) {

            return IconButton(
              icon: const Icon(Icons.menu),

              onPressed: () {
                Scaffold.of(context)
                    .openDrawer();
              },
            );
          },
        ),

        title: const Text("Sklep"),

        elevation: 0,

        actions: [

          if (role == "Admin")

IconButton(

  onPressed: () async {

    final result =
    await Navigator.push(

  context,

  MaterialPageRoute(
    builder: (context) =>
        const AdminPanelScreen(),
  ),
);

if (result == true) {

  fetchProducts();
}
  },

  icon: const Icon(
    Icons.admin_panel_settings,
  ),
),

          IconButton(

  onPressed: () async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const FavoritesScreen(),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  },

  icon: const Icon(
    Icons.favorite_border,
  ),
),

          IconButton(

  onPressed: () {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
            const OrdersScreen(),
      ),
    );
  },

  icon: const Icon(
    Icons.receipt_long,
  ),
),

          IconButton(

  onPressed: () async {

    final result = await Navigator.push(

      context,

      MaterialPageRoute(
        builder: (context) =>
            const CartScreen(),
      ),
    );

    if (result == true) {

      await fetchProducts();

      setState(() {});

    }
  },

  icon: const Icon(
    Icons.shopping_cart_outlined,
  ),
),
        ],

        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(70),

          child: Padding(
            padding:
                const EdgeInsets.all(12),

            child: Container(
              height: 50,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: TextField(
                onChanged: searchProducts,

                decoration: InputDecoration(
                  hintText:
                      "Szukaj produktów...",

                  border: InputBorder.none,

                  prefixIcon: Icon(
                    Icons.search,
                  ),

                  contentPadding:
                      EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body:

          isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : Column(
                children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    child: Row(
                      children: [

                        Expanded(
                          child: ElevatedButton.icon(

                          onPressed: showFilters,

                          icon: const Icon(Icons.tune),

                          label: const Text("Sortuj"),

                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(
                              120,
                              56,
                            ),
                          ),
                        ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: showAvailabilityFilters,
                            icon: const Icon(
                              Icons.filter_alt_outlined,
                            ),
                            label: const Text("Filtry"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(
                                120,
                                56,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),

                  Expanded(
                    child: ListView.builder(
                  padding:
                      const EdgeInsets.all(12),

                  itemCount: filteredProducts.length,

                  itemBuilder:
                      (context, index) {

                    final product =
                        filteredProducts[index];

                    return ProductCard(
                      productId: product.id,
                      title: product.name,
                      price: product.price.toString(),
                      image: product.imageUrl ?? "",
                      stock: product.stock,
                      description: product.description ?? "",
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(

            type: BottomNavigationBarType.fixed,

            currentIndex: 2,

            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,

            onTap: (index) {

              if (index == 0) {

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }

              if (index == 1) {

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }

              if (index == 2) {
                // Jesteśmy już w sklepie
              }

              if (index == 3) {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Wkrótce dostępne"),
                  ),
                );
              }
            },

            items: const [

              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Ekran główny",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profil",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.shop),
                label: "Sklep",
              ),
            ],
          ),
    );
  }
}

class ProductCard extends StatefulWidget {

  final int productId;
  final String title;
  final String price;
  final String image;
  final int stock;
  final String description;

  const ProductCard({
    super.key,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.stock,
    required this.description,
  });

  @override
State<ProductCard> createState() =>
    _ProductCardState();
}

class _ProductCardState
    extends State<ProductCard> {

  @override
  Widget build(BuildContext context) {

    return InkWell(

  borderRadius:
      BorderRadius.circular(18),

  onTap: () {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
            ProductDetailsScreen(
          title: widget.title,
          price: widget.price,
          image: widget.image,
          description: widget.description,
          productId: widget.productId,
        ),
      ),
    );
  },

  child: Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      margin:
          const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              width: 120,
              height: 140,

              decoration: BoxDecoration(
                color: Colors.grey[200],

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(10),

                child: Image.network(
                  widget.image,

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
      MainAxisAlignment.spaceBetween,

  crossAxisAlignment:
      CrossAxisAlignment.start,

  children: [

    Expanded(
      child: Text(
        widget.title,

        style: const TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    ),

    Container(
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      shape: BoxShape.circle,
    ),
    child: IconButton(

      onPressed: () async {

  final prefs =
      await SharedPreferences
          .getInstance();

  final userId =
      prefs.getInt("userId");

  if (userId == null) {
    return;
  }

  if (
    FavoritesData.isFavorite(
      widget.productId,
    )
  ) {

    final token =
        prefs.getString("token");

    final response =
        await http.delete(

      Uri.parse(
        "http://10.0.2.2:5138/api/Favorites?userId=$userId&productId=${widget.productId}",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      setState(() {

        FavoritesData.removeFavorite(
          widget.productId,
        );
      });
    }

  } else {

    final token =
        prefs.getString("token");

    final response =
        await http.post(

      Uri.parse(
        "http://10.0.2.2:5138/api/Favorites",
      ),

      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",
      },

      body: jsonEncode({

        "userId": userId,

        "productId":
            widget.productId,
      }),
    );

    if (response.statusCode == 200) {

      setState(() {

        FavoritesData.addFavorite({

          "productId":
              widget.productId,

          "title":
              widget.title,

          "price":
              widget.price,

          "image":
              widget.image,

          "description": widget.description,
          "stock": widget.stock,
        });
      });
    }
  }
},

      icon: Icon(

        FavoritesData.isFavorite(
          widget.productId,
        )

            ? Icons.favorite
            : Icons.favorite_border,

        color: Colors.red,
      ),
    ),
    ),
  ],
),

const SizedBox(height: 8),

const Text(
  "Dostawa jutro",

  style: TextStyle(
    color: Colors.green,
    fontSize: 14,
  ),
),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Text(
                      "${widget.price} zł",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: widget.stock > 0
                          ? Colors.green.shade100
                          : Colors.red.shade100,

                      borderRadius:
                          BorderRadius.circular(10),
                    ),

                    child: Text(
                      widget.stock > 0
                          ? "Dostępne: ${widget.stock}"
                          : "Brak w magazynie",

                      style: TextStyle(
                        color: widget.stock > 0
                            ? Colors.green
                            : Colors.red,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

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

                      onPressed: widget.stock == 0 ? null : () {

                        CartData.addProduct({

                          "productId": widget.productId,

                          "title": widget.title,

                          "price":
                              double.parse(widget.price),

                          "image": widget.image,

                          "quantity": 1,
                        });

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

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
  }
}