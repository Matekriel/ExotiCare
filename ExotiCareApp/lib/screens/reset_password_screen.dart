import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> resetPassword() async {

    final password =
        passwordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    if (password.isEmpty ||
        confirmPassword.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Wypełnij oba pola.",
          ),
        ),
      );

      return;
    }

    if (password.length < 6) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Hasło musi mieć co najmniej 6 znaków.",
          ),
        ),
      );

      return;
    }

    if (password != confirmPassword) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Hasła nie są takie same.",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(
          "http://10.0.2.2:5138/api/Auth/reset-password",
        ),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "email": widget.email,
          "code": widget.code,
          "newPassword": password,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Hasło zostało zmienione.",
            ),
          ),
        );

        Navigator.popUntil(
          context,
          (route) => route.isFirst,
        );

      } else {

        String message =
            "Nie udało się zmienić hasła.";

        try {

          final data =
              jsonDecode(response.body);

          if (data is String) {
            message = data;
          } else if (data["message"] != null) {
            message = data["message"];
          }

        } catch (_) {

          if (response.body.isNotEmpty) {
            message = response.body;
          }
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Błąd połączenia z serwerem.",
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Nowe hasło",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(24),

        child: Column(

          children: [

            const SizedBox(height: 35),

            Container(

              width: 90,
              height: 90,

              decoration:
                  BoxDecoration(
                color:
                    Colors.green.shade100,
                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons.lock_reset,
                size: 50,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Ustaw nowe hasło",

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Ustaw nowe hasło dla swojego konta.",

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.email,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(

              controller:
                  passwordController,

              obscureText:
                  obscurePassword,

              decoration:
                  InputDecoration(

                labelText:
                    "Nowe hasło",

                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
                ),

                suffixIcon:
                    IconButton(

                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),

                  onPressed: () {

                    setState(() {

                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(

              controller:
                  confirmPasswordController,

              obscureText:
                  obscureConfirmPassword,

              decoration:
                  InputDecoration(

                labelText:
                    "Powtórz nowe hasło",

                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
                ),

                suffixIcon:
                    IconButton(

                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),

                  onPressed: () {

                    setState(() {

                      obscureConfirmPassword =
                          !obscureConfirmPassword;
                    });
                  },
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : resetPassword,

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
                        BorderRadius.circular(16),
                  ),
                ),

                child: isLoading

                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          color:
                              Colors.white,
                          strokeWidth: 3,
                        ),
                      )

                    : const Text(
                        "Zmień hasło",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(

              onPressed:
                  isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },

              child: const Text(
                "Wróć",
              ),
            ),
          ],
        ),
      ),
    );
  }
}