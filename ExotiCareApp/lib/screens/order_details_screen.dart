import 'package:flutter/material.dart';

class OrderDetailsScreen
    extends StatelessWidget {

  final Map order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: Text(
          "Zamówienie #${order["id"]}",
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Status: ${order["status"]}",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          order["status"] ==
                                  "Anulowane"
                              ? Colors.red
                              : Colors.green,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "Płatność: ${order["paymentMethod"]}",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Dostawa: ${order["deliveryMethod"]}",
                  ),

                  const SizedBox(height: 20),

const Divider(),

const SizedBox(height: 20),

const Text(
  "Dane odbiorcy",

  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 14),

Text(
  "${order["user"]["firstName"]} ${order["user"]["lastName"]}",
),

const SizedBox(height: 8),

Text(
  order["user"]["email"],
),

const SizedBox(height: 8),

Text(
  order["user"]["phoneNumber"],
),

const SizedBox(height: 14),

Text(
  "${order["user"]["addressLine"]}",
),

const SizedBox(height: 6),

Text(
  "${order["user"]["postalCode"]} ${order["user"]["city"]}",
),

                  const SizedBox(height: 8),

                  Text(
                    "Kwota: ${order["totalPrice"]} zł",

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Produkty",

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            ...order["orderItems"]
                .map<Widget>(
              (item) {

                return Card(

                  margin:
                      const EdgeInsets.only(
                    bottom: 14,
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

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        Expanded(
                          child: Text(
                            item["productName"],

                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          "x${item["quantity"]}",

                          style:
                              const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          ],
        ),
      ),
    );
  }
}