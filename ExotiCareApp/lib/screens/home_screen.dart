import 'package:flutter/material.dart';
import '../widgets/category_tile.dart';
import 'animal_screen.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const SizedBox(height: 20),

const Text(
  "ExotiCare",
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  ),
),

const SizedBox(height: 8),

const Text(
  "Wybierz kategorię zwierząt",
  style: TextStyle(
    fontSize: 16,
    color: Colors.grey,
  ),
),

const SizedBox(height: 25),

Align(
  alignment: Alignment.centerLeft,

  child: Text(
    "Kategorie",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 15),

            CategoryTile(
  title: "Węże",
  icon: Image.asset(
    'lib/assets/icons/snake.png',
    width: 35,
    height: 35,
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnimalScreen(categoryName: "Węże"),
      ),
    );
  },
),

            CategoryTile(
  title: "Gady",
  icon: Image.asset(
    'lib/assets/icons/lizard.png',
    width: 35,
    height: 35,
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnimalScreen(categoryName: "Gady"),
      ),
    );
  },
),

CategoryTile(
  title: "Pajęczaki",
  icon: Image.asset(
    'lib/assets/icons/spider.png',
    width: 35,
    height: 35,
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnimalScreen(categoryName: "Pajęczaki"),
      ),
    );
  },
),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(

        type: BottomNavigationBarType.fixed,
        currentIndex: 0,

        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == 0) {
            // Kategorie
          }

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }

          if (index == 2) {
          Navigator.push(
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
            label:  "Sklep",
          ),
        ],
      ),
    );
  }
}