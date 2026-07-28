import 'package:flutter/material.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_reviews_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Panel administratora",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: ListTile(
                leading: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.green,
                ),

                title: const Text(
                  "Zarządzanie produktami",
                ),

                subtitle: const Text(
                  "Dodawanie, edycja i usuwanie produktów",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),

                onTap: () async {

  final result =
    await Navigator.push(

  context,

  MaterialPageRoute(
    builder: (context) =>
        const AdminProductsScreen(),
  ),
);

if (result == true) {

  Navigator.pop(
    context,
    true,
  );
}
},
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: ListTile(
                leading: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.green,
                ),

                title: const Text(
                  "Zamówienia",
                ),

                subtitle: const Text(
                  "Przegląd wszystkich zamówień",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),

                onTap: () {

  Navigator.push(
    context,

    MaterialPageRoute(
      builder: (context) =>
          const AdminOrdersScreen(),
    ),
  );
},
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: ListTile(
                leading: const Icon(
                  Icons.reviews_outlined,
                  color: Colors.blue,
                ),

                title: const Text(
                  "Opinie",
                ),

                subtitle: const Text(
                  "Zarządzanie opiniami użytkowników",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),

                onTap: () {

  Navigator.push(
    context,

    MaterialPageRoute(
      builder: (context) =>
          const AdminReviewsScreen(),
    ),
  );
},
              ),
            ),
          ],
        ),
      ),
    );
  }
}