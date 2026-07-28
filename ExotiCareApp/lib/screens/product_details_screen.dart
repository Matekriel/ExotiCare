import 'package:flutter/material.dart';
import '../models/review.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsScreen extends StatefulWidget {

  final String title;
  final String price;
  final String image;
  final String description;
  final int productId;  

  const ProductDetailsScreen({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.productId,
  });

  @override
State<ProductDetailsScreen> createState() =>
    _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {

      int selectedTab = 0;

      List<Review> reviews = [];

      final TextEditingController
        reviewController =
          TextEditingController();

      int selectedRating = 5;

      bool isLoadingReviews = true;

      Future<void> fetchReviews() async {

  try {

    final response = await http.get(

      Uri.parse(
        "http://10.0.2.2:5138/api/Reviews/${widget.productId}",
      ),
    );

    if (response.statusCode == 200) {

      final List data =
          jsonDecode(response.body);

      setState(() {

        reviews =
            data
                .map(
                  (json) =>
                      Review.fromJson(
                        json,
                      ),
                )
                .toList();

        isLoadingReviews = false;
      });
    }

  } catch (e) {

    setState(() {

      isLoadingReviews = false;
    });
  }
}

Future<void> addReview() async {

  final prefs =
      await SharedPreferences
          .getInstance();

  final userId =
      prefs.getInt("userId");

  final token =
      prefs.getString("token");

  final username =
      prefs.getString("username");

  if (userId == null ||
      username == null) {

    return;
  }

  try {

    final response = await http.post(

      Uri.parse(
        "http://10.0.2.2:5138/api/Reviews",
      ),

      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",
      },

      body: jsonEncode({

        "productId":
            widget.productId,

        "userId":
            userId,

        "userName":
            username,

        "rating":
            selectedRating,

        "comment":
            reviewController.text,
      }),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      reviewController.clear();

      fetchReviews();

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Dodano opinię",
          ),
        ),
      );
    }

  } catch (e) {

    print(e);
  }
}

@override
void initState() {

  super.initState();

  fetchReviews();
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              width: double.infinity,
              height: 300,

              color: Colors.white,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Image.network(
                  widget.image,

                  fit: BoxFit.contain,

                  errorBuilder:
                      (
                        context,
                        error,
                        stackTrace,
                      ) {

                    return const Icon(
                      Icons.image,
                      size: 100,
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    widget.title,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    widget.price,

                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.green,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(

  children: [

    Expanded(
      child: GestureDetector(

        onTap: () {

          setState(() {

            selectedTab = 0;
          });
        },

        child: Container(

          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),

          decoration: BoxDecoration(

            color:
                selectedTab == 0
                    ? Colors.green
                    : Colors.white,

            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          child: Center(

            child: Text(

              "Opis",

              style: TextStyle(

                color:
                    selectedTab == 0
                        ? Colors.white
                        : Colors.black,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: GestureDetector(

        onTap: () {

          setState(() {

            selectedTab = 1;
          });
        },

        child: Container(

          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),

          decoration: BoxDecoration(

            color:
                selectedTab == 1
                    ? Colors.green
                    : Colors.white,

            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          child: Center(

            child: Text(

              "Opinie",

              style: TextStyle(

                color:
                    selectedTab == 1
                        ? Colors.white
                        : Colors.black,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  ],
),

const SizedBox(height: 20),

selectedTab == 0

? Text(

  widget.description,

  style: const TextStyle(
    fontSize: 16,
    height: 1.5,
  ),
)

: isLoadingReviews

? const Center(
    child:
        CircularProgressIndicator(),
  )

    : Column(

      children: [

        if (reviews.isEmpty)

  const Padding(

    padding: EdgeInsets.only(
      bottom: 20,
    ),

    child: Center(
      child: Text(
        "Brak opinii",
      ),
    ),
  ),

            ...reviews.map((review) {

          return Container(

            width: double.infinity,

            margin:
                const EdgeInsets.only(
              bottom: 12,
            ),

            padding:
                const EdgeInsets.all(
              14,
            ),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Row(

                  children: List.generate(

                    review.rating,

                    (index) =>
                        const Icon(
                      Icons.star,
                      color:
                          Colors.green,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(

                  review.userName,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  review.comment,
                ),
              ],
            ),
          );
        }).toList(),

  Container(

    padding:
        const EdgeInsets.all(16),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
        14,
      ),
    ),

    child: Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          "Dodaj opinię",

          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Row(

          children: List.generate(

            5,

            (index) {

              return IconButton(

                onPressed: () {

                  setState(() {

                    selectedRating =
                        index + 1;
                  });
                },

                icon: Icon(

                  index <
                          selectedRating
                      ? Icons.star
                      : Icons.star_border,

                  color:
                      Colors.green,
                ),
              );
            },
          ),
        ),

        TextField(

          controller:
              reviewController,

          maxLines: 4,

          decoration:
              InputDecoration(

            hintText:
                "Napisz opinię...",

            filled: true,

            fillColor:
                Colors.grey[100],

            border:
                OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(
                14,
              ),

              borderSide:
                  BorderSide.none,
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
            ),

            onPressed: () {

              addReview();
            },

            child: const Text(
              "Dodaj opinię",
            ),
          ),
        ),
      ],
    ),
  ),

  const SizedBox(height: 20),

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

                      onPressed: () {},

                      child: const Text(
                        "Dodaj do koszyka",

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
      ),
    );
  }
}