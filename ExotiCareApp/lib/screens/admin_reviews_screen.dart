import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() =>
      _AdminReviewsScreenState();
}

class _AdminReviewsScreenState
    extends State<AdminReviewsScreen> {

  List reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response = await http.get(

      Uri.parse(
        "http://10.0.2.2:5138/api/Reviews",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      setState(() {

        reviews =
            jsonDecode(response.body);

        isLoading = false;
      });
    }
  }

  Future<void> deleteReview(
      int reviewId) async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response =
        await http.delete(

      Uri.parse(
        "http://10.0.2.2:5138/api/Reviews/$reviewId",
      ),

      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      fetchReviews();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Opinia usunięta",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Opinie użytkowników",
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : ListView.builder(

              itemCount:
                  reviews.length,

              itemBuilder:
                  (context, index) {

                final review =
                    reviews[index];

                return Card(

                  margin:
                      const EdgeInsets.all(
                    10,
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
                      16,
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Row(

                          children: [

                            Expanded(
                              child: Text(
                                review["userName"],
                                style:
                                    const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            Text(
                              "⭐ ${review["rating"]}/5",
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 10),

                            Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  ),

  decoration: BoxDecoration(
    color: Colors.green.shade100,
    borderRadius:
        BorderRadius.circular(12),
  ),

  child: Text(
    review["productName"],
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 10),

                        Text(
                          review["comment"],
                        ),

                        const SizedBox(height: 10),

Text(
  review["createdAt"]
      .toString()
      .substring(0, 10),

  style: const TextStyle(
    color: Colors.grey,
    fontSize: 12,
  ),
),

                        const SizedBox(
                            height: 15),

                        Align(

                          alignment:
                              Alignment
                                  .centerRight,

                          child:
                              IconButton(

                            icon:
                                const Icon(
                              Icons.delete,
                              color:
                                  Colors.red,
                            ),

                            onPressed: () {

                              deleteReview(
                                review["id"],
                              );
                            },
                          ),
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