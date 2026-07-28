import 'package:flutter/material.dart';

import '../models/animal.dart';

class EditAnimalScreen extends StatefulWidget {
  final Animal animal;

  const EditAnimalScreen({
    super.key,
    required this.animal,
  });

  @override
  State<EditAnimalScreen> createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {

  late TextEditingController nameController;
  late TextEditingController speciesController;
  late TextEditingController ageController;
  late TextEditingController moltDateController;
  late TextEditingController feedingDateController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.animal.name);

    speciesController =
        TextEditingController(text: widget.animal.species);

    ageController =
        TextEditingController(text: widget.animal.age);

    moltDateController =
        TextEditingController(text: widget.animal.moltDate);

    feedingDateController =
        TextEditingController(text: widget.animal.feedingDate);

    notesController =
        TextEditingController(text: widget.animal.notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edytuj zwierzę"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: "Nazwa",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: speciesController,

              decoration: const InputDecoration(
                labelText: "Gatunek",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ageController,

              decoration: const InputDecoration(
                labelText: "Wiek / rozmiar",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: moltDateController,
              readOnly: true,

              decoration: const InputDecoration(
                labelText: "Ostatnia wylinka",
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

            const SizedBox(height: 15),
            
            TextField(
              controller: feedingDateController,
              readOnly: true,

              decoration: const InputDecoration(
                labelText: "Data karmienia",
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

            const SizedBox(height: 15),

            TextField(
              controller: notesController,
              maxLines: 3,

              decoration: const InputDecoration(
                labelText: "Notatki",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: () {

                  widget.animal.name =
                      nameController.text;

                  widget.animal.species =
                      speciesController.text;

                  widget.animal.age =
                      ageController.text;

                  widget.animal.moltDate =
                      moltDateController.text;

                  widget.animal.feedingDate =
                      feedingDateController.text;

                  widget.animal.notes =
                      notesController.text;

                  Navigator.pop(context);
                },

                child: const Text(
                  "Zapisz zmiany",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}