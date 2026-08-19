import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyCodeScreen> createState() =>
      _VerifyCodeScreenState();
}

class _VerifyCodeScreenState
    extends State<VerifyCodeScreen> {

  final codeController =
      TextEditingController();

  bool isLoading = false;

  int attemptsLeft = 5;

  Future<void> verifyCode() async {

    final code =
        codeController.text.trim();

    if (code.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Wpisz kod weryfikacyjny.",
          ),
        ),
      );

      return;
    }

    if (code.length != 6) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Kod musi mieć 6 cyfr.",
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
          "http://10.0.2.2:5138/api/Auth/verify-reset-code",
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "email":
              widget.email,

          "code":
              code,
        }),
      );

      if (response.statusCode == 200) {

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResetPasswordScreen(
              email: widget.email,
              code: code,
            ),
          ),
        );
      } else {

        String message =
            "Nieprawidłowy kod.";

        try {

          message =
              jsonDecode(response.body);

        } catch (_) {

          message =
              response.body;
        }

        // Aktualizujemy liczbę prób
        if (attemptsLeft > 0) {
          setState(() {
            attemptsLeft--;
          });
        }

        if (!mounted) return;

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
          "Weryfikacja",
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
                Icons.mark_email_read_outlined,
                size: 50,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Wpisz kod weryfikacyjny",

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
              "Na podany adres email "
              "wysłaliśmy 6-cyfrowy kod.",

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
                  codeController,

              keyboardType:
                  TextInputType.number,

              maxLength: 6,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
                letterSpacing: 8,
              ),

              decoration:
                  InputDecoration(

                labelText:
                    "Kod weryfikacyjny",

                counterText: "",

                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
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

            const SizedBox(height: 15),

            Text(
              "Pozostało prób: $attemptsLeft",

              style: TextStyle(
                color: attemptsLeft <= 2
                    ? Colors.red
                    : Colors.grey,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton(

                onPressed:
                    isLoading ||
                            attemptsLeft <= 0
                        ? null
                        : verifyCode,

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
                        "Zweryfikuj kod",

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

              onPressed: () {

                Navigator.pop(
                  context,
                );
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