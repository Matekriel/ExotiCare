import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'payment_screen.dart';

class CompleteProfileScreen
    extends StatefulWidget {

  final double totalPrice;

  const CompleteProfileScreen({
    super.key,
    required this.totalPrice,
  });

  @override
  State<CompleteProfileScreen>
      createState() =>
          _CompleteProfileScreenState();
}

class _CompleteProfileScreenState
    extends State<CompleteProfileScreen> {

  final firstNameController =
      TextEditingController();

  final lastNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final addressController =
      TextEditingController();

  final postalCodeController =
      TextEditingController();

  final cityController =
      TextEditingController();

  Future<void> saveProfile() async {

    final prefs =
        await SharedPreferences
            .getInstance();

    final userId =
        prefs.getInt("userId");

    final token =
      prefs.getString("token");

    if (userId == null || token == null) {
      return;
    }

    final response = await http.put(

      Uri.parse(
        "http://10.0.2.2:5138/api/Users/update-profile/$userId",
      ),

      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",
      },

      body: jsonEncode({

        "firstName":
            firstNameController.text,

        "lastName":
            lastNameController.text,

        "phoneNumber":
            phoneController.text,

        "addressLine":
            addressController.text,

        "postalCode":
            postalCodeController.text,

        "city":
            cityController.text,
      }),
    );

    if (response.statusCode == 200) {

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(
            totalPrice:
                widget.totalPrice,
          ),
        ),
      );

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Błąd zapisu danych",
          ),
        ),
      );
    }
  }

  Widget buildField(
  String label,
  TextEditingController controller,
  IconData icon,
) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 16,
    ),

    child: TextField(
      controller: controller,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
  "Dane do dostawy",
  style: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  ),
),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

const SizedBox(height: 10),

const Text(
  "Uzupełnij dane potrzebne do realizacji zamówienia",
  textAlign: TextAlign.center,
  style: TextStyle(
    color: Colors.grey,
    fontSize: 16,
  ),
),

const SizedBox(height: 30),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Dane osobowe",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 15),

            buildField(
              "Imię",
              firstNameController,
              Icons.person_outline,
            ),

            buildField(
              "Nazwisko",
              lastNameController,
              Icons.badge_outlined,
            ),

            buildField(
              "Telefon",
              phoneController,
              Icons.phone_outlined,
            ),

            const SizedBox(height: 10),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Adres dostawy",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 15),

            buildField(
              "Adres",
              addressController,
              Icons.home_outlined,
            ),

            buildField(
              "Kod pocztowy",
              postalCodeController,
              Icons.local_post_office_outlined,
            ),

            buildField(
              "Miasto",
              cityController,
              Icons.location_city_outlined,
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

  elevation: 4,

  shape:
      RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
),

                onPressed: saveProfile,

                child: const Text(
                  "Zapisz i przejdź dalej",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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