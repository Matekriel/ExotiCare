import 'package:flutter/material.dart';

import '../models/animal.dart';

import 'add_animal_screen.dart';
import 'animal_details_screen.dart';

class AnimalScreen extends StatefulWidget {
  final String categoryName;

  const AnimalScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {

  List<Animal> animals = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),

      body: animals.isEmpty
          ? const Center(
              child: Text(
                "Brak dodanych zwierząt",
                style: TextStyle(fontSize: 22),
              ),
            )
          : ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {

                final animal = animals[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(animal.name),
                    subtitle: Text(animal.species),

                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimalDetailsScreen(
                          animal: animal,
                          animals: animals,
                          index: index,
                          )
                          )
                          );
                          setState(() {});
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          final Animal? newAnimal = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAnimalScreen(),
            ),
          );

          if (newAnimal != null) {
            setState(() {
              animals.add(newAnimal);
            });
          }
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}