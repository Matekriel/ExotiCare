import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/cart_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import '../models/parcel_locker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'parcel_locker_map_screen.dart';

class PaymentScreen extends StatefulWidget {

  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();

    _loadParcelLockers();

    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {

      if (uri.scheme != "exoticcare") return;

      if (uri.host == "paypal" && uri.path == "/success") {

        print("PAYPAL SUCCESS");

        await _capturePayPalOrder();
      }

      if (uri.host == "payu" && uri.path == "/success") {

        print("PAYU SUCCESS");

        await _saveOrder();
      }

    });

  }

  @override
  void dispose() {

    _linkSubscription?.cancel();

    super.dispose();
  }

  late final AppLinks _appLinks;

  StreamSubscription<Uri>? _linkSubscription;

  String? _paypalOrderId;
  String? _payuOrderId;
  List<ParcelLocker> parcelLockers = [];

  ParcelLocker? selectedLocker;

  String selectedDelivery =
    "Paczkomat";

  double deliveryPrice = 12.99;

  String selectedPayment =
      "BLIK";

  double get finalPrice {

  return widget.totalPrice +
      deliveryPrice;
}

Future<void> _loadParcelLockers() async {

  final response = await http.get(
    Uri.parse("http://10.0.2.2:5138/api/ParcelLockers"),
  );

  if (response.statusCode == 200) {

    final List data = jsonDecode(response.body);

    setState(() {

      parcelLockers =
          data.map((e) => ParcelLocker.fromJson(e)).toList();

    });

  } else {

    print("Błąd pobierania Punktów Odbioru");

  }
  print("Pobrano ${parcelLockers.length} Punktów Odbioru");
}

Future<void> _saveOrder() async {

  final prefs =
      await SharedPreferences.getInstance();

  final userId =
      prefs.getInt("userId");

  final token =
      prefs.getString("token");

  if (userId == null) {
    return;
  }

  final response = await http.post(

    Uri.parse(
      "http://10.0.2.2:5138/api/Orders",
    ),

    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },

    body: jsonEncode({

      "userId": userId,

      "totalPrice": finalPrice,

      "paymentMethod": selectedPayment,

      "deliveryMethod": selectedDelivery,

      "deliveryPrice": deliveryPrice,

      "items": CartData.cartItems.map((item) {

        return {

          "productId": item["productId"],

          "quantity": item["quantity"],

          "price": item["price"],
        };

      }).toList(),

    }),
  );

  if (response.statusCode == 200) {

    CartData.cartItems.clear();

    if (!mounted) return;

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text("Sukces"),

          content: const Text(
            "Zamówienie zostało złożone",
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);
                Navigator.pop(context, true);

              },

              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _payWithPayPal() async {

  final response = await http.post(

    Uri.parse(
      "http://10.0.2.2:5138/api/Payments/create-order",
    ),

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode({
      "amount": finalPrice,
    }),
  );

  if (response.statusCode != 200) {
    return;
  }

  final data = jsonDecode(response.body);

  _paypalOrderId = data["orderId"];

  final approveUrl = data["approveUrl"];

  final uri = Uri.parse(approveUrl);

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}

Future<void> _payWithPayU() async {

  final response = await http.post(

    Uri.parse(
      "http://10.0.2.2:5138/api/Payments/payu/create-order",
    ),

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode({
      "amount": finalPrice,
    }),
  );

  if (response.statusCode != 200) {

    print(response.body);
    return;
  }

  final data = jsonDecode(response.body);

  _payuOrderId = data["orderId"];

  final redirectUrl = data["redirectUri"];

  await launchUrl(

    Uri.parse(redirectUrl),

    mode: LaunchMode.externalApplication,

  );
}

Future<void> _capturePayPalOrder() async {
  print("=== CAPTURE START ===");

  if (_paypalOrderId == null) {
    return;
  }

  print("OrderId: $_paypalOrderId");

  final response = await http.post(

    Uri.parse(
      "http://10.0.2.2:5138/api/Payments/capture-order",
    ),

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode({

      "orderId": _paypalOrderId,

    }),
  );

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {

    print("Capture OK");

    await _saveOrder();

  } else {
    print("Capture FAILED");
  }

}

  Widget paymentTile({
    required String title,
    required IconData icon,
  }) {

    final selected =
        selectedPayment == title;

    return GestureDetector(

      onTap: () {

        setState(() {
          selectedPayment = title;
        });
      },

      child: Container(

        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),

        padding:
            const EdgeInsets.all(18),

        decoration: BoxDecoration(

          color:
              selected
                  ? Colors.green[50]
                  : Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(

            color:
                selected
                    ? Colors.green
                    : Colors.grey.shade300,

            width: 2,
          ),
        ),

        child: Row(
          children: [

            Icon(
              icon,
              size: 32,

              color:
                  selected
                      ? Colors.green
                      : Colors.grey,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,

                style: TextStyle(
                  fontSize: 18,

                  fontWeight:
                      FontWeight.bold,

                  color:
                      selected
                          ? Colors.green
                          : Colors.black,
                ),
              ),
            ),

            if (selected)

              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget deliveryTile({
  required String title,
  required String subtitle,
  required double price,
  required IconData icon,
}) {

  final selected =
      selectedDelivery == title;

  return GestureDetector(

    onTap: () {

      setState(() {

        selectedDelivery = title;
        deliveryPrice = price;
      });
    },

    child: Container(

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color:
            selected
                ? Colors.green[50]
                : Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(

          color:
              selected
                  ? Colors.green
                  : Colors.grey.shade300,

          width: 2,
        ),
      ),

      child: Row(
        children: [

          Icon(
            icon,

            size: 30,

            color:
                selected
                    ? Colors.green
                    : Colors.grey,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: TextStyle(
                    fontSize: 18,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        selected
                            ? Colors.green
                            : Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,

                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Text(
            "${price.toStringAsFixed(2)} zł",

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,

              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Płatność",
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

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Row(
                    children: [

                      Icon(
                        Icons.local_shipping,
                        color: Colors.green,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Dostawa",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Container(

                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.green[50],

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),

                        child: const Icon(
                          Icons.home,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              "Adres użytkownika",

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,

                                fontSize: 16,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Dane pobrane z profilu",

                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
  "Metoda dostawy",

  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 18),

deliveryTile(
  title: "Punkt odbioru",
  subtitle: "Dostawa jutro",
  price: 12.99,
  icon: Icons.inventory_2,
),

if (selectedDelivery == "Punkt odbioru")
  Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (selectedLocker == null)
          const Text(
            "Nie wybrano punktu odbioru",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

        if (selectedLocker != null) ...[
          Text(
            selectedLocker!.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 4),

          Text(selectedLocker!.city),

          Text(selectedLocker!.street),
        ],

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            icon: const Icon(
              Icons.map_outlined,
              size: 22,
            ),

            label: Text(
              selectedLocker == null
                  ? "Wybierz na mapie"
                  : "Zmień punkt",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              backgroundColor: Colors.green[50],
              side: const BorderSide(
                color: Colors.green,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            onPressed: () async {
              final locker =
                  await Navigator.push<ParcelLocker>(
                context,
                MaterialPageRoute(
                  builder: (_) => ParcelLockerMapScreen(
                    parcelLockers: parcelLockers,
                  ),
                ),
              );

              if (locker != null) {
                setState(() {
                  selectedLocker = locker;
                });
              }
            },
          ),
        ),
      ],
    ),
  ),

deliveryTile(
  title: "Kurier",
  subtitle: "Dostawa do domu",
  price: 16.99,
  icon: Icons.local_shipping,
),

deliveryTile(
  title: "Odbiór osobisty",
  subtitle: "W sklepie ExotiCare",
  price: 0,
  icon: Icons.store,
),

const SizedBox(height: 30),

            const Text(
              "Metoda płatności",

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            paymentTile(
              title: "PayPal",
              icon: Icons.account_balance_wallet,
            ),

            paymentTile(
              title: "PayU",
              icon: Icons.account_balance,
            ),

            paymentTile(
              title: "Płatność przy odbiorze",
              icon: Icons.credit_card,
            ),

            const SizedBox(height: 24),

            Container(

              padding:
                  const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  22,
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
                        "Wartość produktów",

                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      Text(
                        "${(widget.totalPrice + deliveryPrice).toStringAsFixed(2)} zł",

                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      Text(
                        "Dostawa",

                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      Text(
                        "${deliveryPrice.toStringAsFixed(2)} zł",

                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 18,
                    ),

                    child: Divider(),
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      const Text(
                        "Razem",

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Text(
                        "${(widget.totalPrice + deliveryPrice).toStringAsFixed(2)} zł",

                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.green,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 60,

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
                      18,
                    ),
                  ),
                ),

                onPressed: () async {
                  if (selectedPayment == "PayPal") {

                    await _payWithPayPal();

                  }
                  else if (selectedPayment == "PayU") {

                    await _payWithPayU();

                  }
                  else {

                    await _saveOrder();

                  }
                },

                child: const Text(
                  "Zapłać teraz",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}