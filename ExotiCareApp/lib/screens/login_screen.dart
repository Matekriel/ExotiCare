import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  bool rememberMe = false;

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  Future<void> login() async {

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Email i hasło są wymagane",
          ),
        ),
      );

      return;
    }

    try {

      final response = await http.post(
        Uri.parse(
          "http://10.0.2.2:5138/api/Auth/login",
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({
          "email":
              emailController.text,

          "passwordHash":
              passwordController.text,
        }),
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        final prefs =
            await SharedPreferences
                .getInstance();

          await prefs.setString(
            "token",
            data["token"],
          );

          await prefs.setString(
            "username",
            data["username"],
          );

          await prefs.setInt(
            "userId",
            data["id"],
          );

          await prefs.setString(
            "role",
            data["role"],
          );

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Zalogowano pomyślnie",
            ),
          ),
        );

        Navigator.pushReplacement(
          context,

          MaterialPageRoute(
            builder: (context) =>
                const HomeScreen(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Nieprawidłowy email lub hasło",
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Błąd połączenia z serwerem\n$e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.grey[100],

      body: Center(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(24),

        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

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

const SizedBox(height: 25),

              const Text(
                "Logowanie",

                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: emailController,

                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,

                decoration: InputDecoration(
                  labelText: "Hasło",

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

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

                onPressed: login,

                child: const Text(
                  "Zaloguj się",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [

                  Checkbox(
                    value: rememberMe,

                    onChanged: (value) {

                      setState(() {
                        rememberMe =
                            value!;
                      });
                    },
                  ),

                  const Text(
                    "Zapamiętaj mnie",
                  ),
                ],
              ),

              TextButton(
                onPressed: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                          const ForgotPasswordScreen(),
                    ),
                  );
                },

                child: const Text(
                  "Zapomniałeś hasła?",
                ),
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  const Text(
                    "Nie masz konta?",
                  ),

                  TextButton(

                    onPressed: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              const RegisterScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Zarejestruj się",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}