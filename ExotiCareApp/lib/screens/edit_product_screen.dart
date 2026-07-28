import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProductScreen extends StatefulWidget {

  final Map product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {

      @override
void initState() {
  super.initState();

  nameController.text =
      widget.product["name"];

  descriptionController.text =
      widget.product["description"] ?? "";

  priceController.text =
      widget.product["price"]
          .toString();

  categoryController.text =
      widget.product["category"] ?? "";

  stockController.text =
      widget.product["stock"]
          .toString();
}

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

  Future<void> updateProduct() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

  var request =
      http.MultipartRequest(

    "PUT",

    Uri.parse(
      "http://10.0.2.2:5138/api/Products/${widget.product["id"]}",
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

  if (selectedImage != null) {

    request.files.add(

      await http.MultipartFile
          .fromPath(
        "image",
        selectedImage!.path,
      ),
    );
  }

  final response =
      await request.send();

  print(response.statusCode);

  final responseBody =
    await response.stream.bytesToString();

  print(responseBody);

  if (response.statusCode == 200) {

    Navigator.pop(
      context,
      true,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Błąd: ${response.statusCode}",),),
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
          "Edytuj produkt",
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

                onPressed: updateProduct,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),

                child: const Text(
                  "Zapisz zmiany",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}