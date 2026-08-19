import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'shop_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {  

      Map? user;
      bool isLoading = true;

      String? getProfileImageUrl() {
  final imageUrl = user?["profileImageUrl"];

  if (imageUrl == null ||
      imageUrl.toString().isEmpty) {
    return null;
  }

  return "http://10.0.2.2:5138$imageUrl";
}

@override
void initState() {
  super.initState();
  fetchUser();
}

Future<void> fetchUser() async {

  final prefs =
      await SharedPreferences
          .getInstance();

  final userId =
      prefs.getInt("userId");

  final token =
      prefs.getString("token");

  if (userId == null) {
    return;
  }

  final response = await http.get(

    Uri.parse(
      "http://10.0.2.2:5138/api/Users/$userId",
    ),

    headers: {
      "Authorization":
          "Bearer $token",
    },
  );

  if (response.statusCode == 200) {

    setState(() {

      user =
          jsonDecode(response.body);

      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {

if (isLoading) {

  return const Scaffold(
    backgroundColor: const Color(0xFFF5F6FA),

    body: Center(
      child:
          CircularProgressIndicator(),
    ),
  );
}

    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profil"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
  child: Column(
          children: [

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 30,
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

                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    backgroundImage: getProfileImageUrl() != null
                        ? NetworkImage(getProfileImageUrl()!)
                        : null,
                    child: getProfileImageUrl() == null
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.green,
                          )
                        : null,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    user?["username"] ?? "",
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    user?["email"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Align(
  alignment: Alignment.centerLeft,

  child: Text(
    "Moje dane",

    style: TextStyle(
      fontSize: 20,
      fontWeight:
          FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 10),

Card(
  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(18),
  ),

  child: Padding(
    padding:
        const EdgeInsets.all(16),

    child: Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "Dane użytkownika",
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const Divider(),

        buildInfoRow(
          Icons.person_outline,
          "Imię",
          user?["firstName"] ?? "-",
        ),

        buildInfoRow(
          Icons.badge_outlined,
          "Nazwisko",
          user?["lastName"] ?? "-",
        ),

        buildInfoRow(
          Icons.phone_outlined,
          "Telefon",
          user?["phoneNumber"] ?? "-",
        ),

        buildInfoRow(
          Icons.location_on_outlined,
          "Adres",
          "${user?["addressLine"] ?? "-"}",
        ),

        buildInfoRow(
          Icons.home_outlined,
          "Miasto",
          "${user?["postalCode"] ?? ""} ${user?["city"] ?? ""}",
        ),
      ],
    ),
  ),
),
const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(

                onPressed: () async {

                  final result =
                      await Navigator.push(

                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen(
                        user: user!,
                      ),
                    ),
                  );

                  if (result == true) {
                    await fetchUser();
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),

                  elevation: 3,
                ),

                icon: const Icon(Icons.edit),

                label: const Text(
                  "Edytuj profil",
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(

                onPressed: () async {

                  final prefs =
                      await SharedPreferences.getInstance();

                  await prefs.clear();

                  if (!mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(

                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginScreen(),
                    ),

                    (route) => false,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),

                  elevation: 3,
                ),

                icon: const Icon(Icons.logout),

                label: const Text(
                  "Wyloguj",
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(

    type: BottomNavigationBarType.fixed,

    currentIndex: 1,

    selectedItemColor: Colors.green,
    unselectedItemColor: Colors.grey,

    onTap: (index) {

      if (index == 0) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const HomeScreen(),
          ),
        );
      }

      if (index == 1) {
        // Jesteśmy już w profilu
      }

      if (index == 2) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const ShopScreen(),
          ),
        );
      }
    },

    items: const [

      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Ekran główny",
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: "Profil",
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.shop),
        label: "Sklep",
      ),
    ],
    ),
    );
  }
}

Widget buildInfoRow(
  IconData icon,
  String title,
  String value,
) {
  return Padding(
    padding:
        const EdgeInsets.symmetric(
      vertical: 8,
    ),

    child: Row(
      children: [

        Icon(
          icon,
          color: Colors.green,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}