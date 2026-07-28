import 'package:flutter/material.dart';

import '../models/animal.dart';

import 'edit_animal_screen.dart';

class AnimalDetailsScreen extends StatelessWidget {
  final Animal animal;
  final List<Animal> animals;
  final int index;

  const AnimalDetailsScreen({
    super.key,
    required this.animal,
    required this.animals,
    required this.index
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAnimalScreen(
                    animal: animal,
                  )));
                  Navigator.pop(context);
            },
            ),

          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              animals.removeAt(index);
              Navigator.pop(context);
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              animal.name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Gatunek: ${animal.species}",
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 15),

            Text(
              "Wiek / rozmiar: ${animal.age}",
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 15),

            Text(
              "Data ostatniej wylinki: ${animal.moltDate}",
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 15),

            Text(
              "Data karmienia: ${animal.feedingDate}",
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 15),

            Text(
              "Notatki:",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              animal.notes,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}