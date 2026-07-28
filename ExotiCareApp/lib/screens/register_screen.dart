import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();

  Future<void> register() async {

    if (usernameController.text.isEmpty ||
    emailController.text.isEmpty ||
    passwordController.text.isEmpty) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Nazwa użytkownika, email i hasło są wymagane",
      ),
    ),
  );

  return;
}

if (passwordController.text !=
    repeatPasswordController.text) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Hasła nie są takie same"),
    ),
  );

  return;
}

  final response = await http.post(
    Uri.parse("http://10.0.2.2:5138/api/auth/register"),

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode({
      "username": usernameController.text,
      "email": emailController.text,
      "passwordHash": passwordController.text,

      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "phoneNumber": phoneController.text,

      "addressLine": addressController.text,
      "postalCode": postalCodeController.text,
      "city": cityController.text,
}),
  );

  if (response.statusCode == 200) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Konto utworzone"),
      ),
    );

    Navigator.pop(context);

  } else {

    print(response.body);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Błąd rejestracji"),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const SizedBox(height: 20),

const Text(
  "ExotiCare",
  style: TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  ),
),

const SizedBox(height: 10),

const Text(
  "Utwórz nowe konto",
  style: TextStyle(
    fontSize: 18,
    color: Colors.grey,
  ),
),

const SizedBox(height: 35),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Dane logowania",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 15),

            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Nazwa użytkownika *",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.person_outline,),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email *",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.email_outlined,),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Hasło *",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.lock_outline,),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: repeatPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Powtórz hasło *",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.lock_outline,),
              ),
            ),

            const SizedBox(height: 15),

            const SizedBox(height: 25),

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

            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "Imię",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.badge_outlined,),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Nazwisko",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.badge,),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "Telefon",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.phone_outlined,),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Adres",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.home_outlined,),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: postalCodeController,
              decoration: InputDecoration(
                labelText: "Kod pocztowy",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.local_post_office_outlined,),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "Miasto",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),),
                prefixIcon: const Icon(Icons.location_city_outlined,),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

  style: ElevatedButton.styleFrom(

    backgroundColor:
        Colors.green,

    foregroundColor:
        Colors.white,

    elevation: 4,

    shape:
        RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(16),
    ),
  ),

  onPressed: register,

  child: const Text(
    "Utwórz konto",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
),
            ),

const SizedBox(height: 20),

Row(
  mainAxisAlignment:
      MainAxisAlignment.center,

  children: [

    const Text(
      "Masz już konto?",
    ),

    TextButton(

      onPressed: () {

        Navigator.pop(context);
      },

      child: const Text(
        "Zaloguj się",
      ),
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}