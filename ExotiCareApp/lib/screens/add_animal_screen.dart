import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/animal.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  final nameController = TextEditingController();
  final speciesController = TextEditingController();
  final ageController = TextEditingController();
  final moltDateController = TextEditingController();
  final feedingDateController = TextEditingController();
  final notesController = TextEditingController();

Future<void> pickImage() async {
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (image != null) {
    setState(() {
      selectedImage = File(image.path);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj zwierzę'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
            child: GestureDetector(
              onTap: pickImage,

              child: Column(
                children: [

                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[300],

                    backgroundImage:
                        selectedImage != null
                            ? FileImage(selectedImage!)
                            : null,

                    child: selectedImage == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.black54,
                          )
                        : null,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Dodaj zdjęcie",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Nazwa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Wpisz nazwę',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Gatunek',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: speciesController,
              decoration: const InputDecoration(
                labelText: 'Wpisz gatunek',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Wiek / rozmiar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Wpisz wiek/rozmiar',
                hintText: "Np. 2 lata / 15 cm / 2 DC",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Ostatnia wylinka',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: moltDateController,
              readOnly: true,

              decoration: const InputDecoration(
                hintText: 'Wybierz datę ostatniej wylinki',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_month),
              ),

              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  String formattedDate =
                      "${pickedDate.day}.${pickedDate.month}.${pickedDate.year}";

                  moltDateController.text = formattedDate;
                }
              },
            ),

            const Text(
              'Data karmienia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: feedingDateController,
              readOnly: true,

              decoration: const InputDecoration(
                labelText: 'Data karmienia',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_month),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                      "${pickedDate.day}.${pickedDate.month}.${pickedDate.year}";

                    feedingDateController.text = formattedDate;
                  }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Notatki',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notatki',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {

                  final animal = Animal(
                    name: nameController.text,
                    species: speciesController.text,
                    age: ageController.text,
                    moltDate: moltDateController.text,
                    feedingDate: feedingDateController.text,
                    notes: notesController.text,
                  );

                  Navigator.pop(context, animal);
                },
                child: const Text(
                  'Zapisz',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}