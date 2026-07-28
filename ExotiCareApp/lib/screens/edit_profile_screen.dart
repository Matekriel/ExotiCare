import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {

  final Map user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

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

  @override
  void initState() {
    super.initState();

    firstNameController.text =
        widget.user["firstName"] ?? "";

    lastNameController.text =
        widget.user["lastName"] ?? "";

    phoneController.text =
        widget.user["phoneNumber"] ?? "";

    addressController.text =
        widget.user["addressLine"] ?? "";

    postalCodeController.text =
        widget.user["postalCode"] ?? "";

    cityController.text =
        widget.user["city"] ?? "";
  }

  Future<void> saveProfile() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response = await http.put(

      Uri.parse(
        "http://10.0.2.2:5138/api/Users/update-profile/${widget.user["id"]}",
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

      Navigator.pop(
        context,
        true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          "Edytuj profil",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    vertical: 25,
    horizontal: 20,
  ),

  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color.fromARGB(255, 76, 175, 80),
        Color.fromARGB(255, 76, 175, 80),
      ],
    ),

    borderRadius:
        BorderRadius.circular(25),

    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 15,
        offset: Offset(0, 5),
      ),
    ],
  ),

  child: Column(
    children: [

      const CircleAvatar(
        radius: 45,
        backgroundColor:
            Colors.white,

        child: Icon(
          Icons.person,
          size: 45,
          color: Colors.green,
        ),
      ),

      const SizedBox(height: 12),

      Text(
        widget.user["username"] ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight:
              FontWeight.bold,
        ),
      ),

      Text(
        widget.user["email"] ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 25),

            Card(
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  children: [

            TextField(
              controller: firstNameController,

              decoration: InputDecoration(
                labelText: "Imię",

                prefixIcon:
                    const Icon(Icons.person),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Nazwisko",

              prefixIcon:
                    const Icon(Icons.badge),

                filled: true,
                fillColor: Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  phoneController,
              decoration: InputDecoration(
                labelText: "Telefon",
                prefixIcon:
                    const Icon(Icons.phone),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                )
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  addressController,
              decoration: InputDecoration(
                labelText: "Adres",
                prefixIcon:
                    const Icon(Icons.location_on),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                )
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  postalCodeController,
              decoration: InputDecoration(
                labelText:
                    "Kod pocztowy",
                    prefixIcon:
                    const Icon(Icons.markunread_mailbox),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                )
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  cityController,
              decoration: InputDecoration(
                labelText:
                    "Miasto",
                    prefixIcon:
                    const Icon(Icons.home),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                )
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),

                onPressed: saveProfile,

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
                        BorderRadius.circular(18),
                  ),
                ),

                label: const Text(
                  "Zapisz zmiany",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              )
            ),
          ],
        ),
              ),
            ),
          ],
      ),
      ),
    );
  }
}