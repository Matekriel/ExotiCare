import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {

  final nameController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final priceController =
      TextEditingController();

  final categoryController =
      TextEditingController();

  final stockController =
      TextEditingController();

  File? selectedImage;

  Future<void> addProduct() async {

  if (selectedImage == null) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Wybierz zdjęcie",
        ),
      ),
    );

    return;
  }

  final prefs =
      await SharedPreferences.getInstance();

  final token =
      prefs.getString("token");

  var request =
      http.MultipartRequest(
    "POST",
    Uri.parse(
      "http://10.0.2.2:5138/api/Products",
    ),
  );

  request.headers["Authorization"] =
    "Bearer $token";

  request.fields["name"] =
      nameController.text;

  request.fields["description"] =
      descriptionController.text;

  request.fields["price"] =
      priceController.text;

  request.fields["category"] =
      categoryController.text;

  request.fields["stock"] =
      stockController.text;

  request.files.add(

    await http.MultipartFile
        .fromPath(
      "image",
      selectedImage!.path,
    ),
  );

  final response =
      await request.send();

  if (response.statusCode == 200) {

      Navigator.pop(
    context,
    true,
  );

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "Produkt dodany",
        ),
      ),
    );

  } else {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(
          "Błąd: ${response.statusCode}",
        ),
      ),
    );
  }
}

  Future<void> pickImage() async {

    final image =
        await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {

        selectedImage =
            File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Dodaj produkt",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Nazwa produktu",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  descriptionController,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                labelText: "Opis",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  priceController,
              decoration:
                  const InputDecoration(
                labelText: "Cena",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  categoryController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Kategoria",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  stockController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Stan magazynowy",
              ),
            ),

            const SizedBox(height: 20),

            if (selectedImage != null)

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),

                child: Image.file(
                  selectedImage!,
                  height: 200,
                ),
              ),

            const SizedBox(height: 10),

            ElevatedButton.icon(

              onPressed:
                  pickImage,

              icon: const Icon(
                Icons.image,
              ),

              label: const Text(
                "Wybierz zdjęcie",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed: addProduct,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),

                child: const Text(
                  "Dodaj produkt",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}