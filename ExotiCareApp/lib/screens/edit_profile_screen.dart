import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {

  final Map user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  File? _selectedImage;
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  final firstNameController =
      TextEditingController();

  final lastNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final addressController =
      TextEditingController();

  final postalCodeController =
      TextEditingController();

  final cityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    firstNameController.text =
        widget.user["firstName"] ?? "";

    lastNameController.text =
        widget.user["lastName"] ?? "";

    phoneController.text =
        widget.user["phoneNumber"] ?? "";

    addressController.text =
        widget.user["addressLine"] ?? "";

    postalCodeController.text =
        widget.user["postalCode"] ?? "";

    cityController.text =
        widget.user["city"] ?? "";

    _profileImageUrl =
      widget.user["profileImageUrl"];
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> saveProfile() async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final imageUploaded = await _uploadProfileImage();

    if (!imageUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nie udało się zapisać zdjęcia profilowego",
          ),
        ),
      );
      return;
    }

    final response = await http.put(

      Uri.parse(
        "http://10.0.2.2:5138/api/Users/update-profile/${widget.user["id"]}",
      ),

      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },

      body: jsonEncode({

        "firstName":
            firstNameController.text,

        "lastName":
            lastNameController.text,

        "phoneNumber":
            phoneController.text,

        "addressLine":
            addressController.text,

        "postalCode":
            postalCodeController.text,

        "city":
            cityController.text,
      }),
    );

    if (response.statusCode == 200) {

      Navigator.pop(
        context,
        true,
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nie udało się zapisać zmian",
          ),
        ),
      );
    }
  }

  Future<bool> _uploadProfileImage() async {
    if (_selectedImage == null) {
      return true;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString("token");

      final request = http.MultipartRequest(
        "POST",
        Uri.parse(
          "http://10.0.2.2:5138/api/Users/${widget.user["id"]}/profile-image",
        ),
      );

      request.headers["Authorization"] =
          "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          _selectedImage!.path,
        ),
      );

      final response =
          await request.send();

      if (response.statusCode == 200) {

        setState(() {
          _selectedImage = null;
        });

        return true;
      }

      return false;

    } catch (e) {
      print(e);
      return false;

    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          "Edytuj profil",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    vertical: 25,
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

      GestureDetector(
        onTap: _pickProfileImage,
        child: Stack(
          children: [

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,

              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (_profileImageUrl != null &&
                          _profileImageUrl!.isNotEmpty
                      ? NetworkImage(
                          "http://10.0.2.2:5138${_profileImageUrl!}",
                        )
                      : null),

              child: _selectedImage == null &&
                      (_profileImageUrl == null ||
                          _profileImageUrl!.isEmpty)
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.green,
                    )
                  : null,
            ),

            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,

                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),

                child: const Icon(
                  Icons.camera_alt,
                  size: 17,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 12),

      Text(
        widget.user["username"] ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight:
              FontWeight.bold,
        ),
      ),

      Text(
        widget.user["email"] ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 25),

            Card(
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  children: [

            TextField(
              controller: firstNameController,

              decoration: InputDecoration(
                labelText: "Imię",

                prefixIcon:
                    const Icon(Icons.person),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Nazwisko",

              prefixIcon:
                    const Icon(Icons.badge),

                filled: true,
                fillColor: Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  phoneController,
              decoration: InputDecoration(
                labelText: "Telefon",
                prefixIcon:
                    const Icon(Icons.phone),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                )
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  addressController,
              decoration: InputDecoration(
                labelText: "Adres",
                prefixIcon:
                    const Icon(Icons.location_on),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                )
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  postalCodeController,
              decoration: InputDecoration(
                labelText:
                    "Kod pocztowy",
                    prefixIcon:
                    const Icon(Icons.markunread_mailbox),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                )
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  cityController,
              decoration: InputDecoration(
                labelText:
                    "Miasto",
                    prefixIcon:
                    const Icon(Icons.home),

                filled: true,
                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                )
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: Icon(
                  _isUploadingImage
                      ? Icons.hourglass_empty
                      : Icons.save,
                ),

                onPressed: _isUploadingImage
                    ? null
                    : saveProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.green.shade300,
                  disabledForegroundColor: Colors.white,
                  elevation: 4,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                label: Text(
                  _isUploadingImage
                      ? "Zapisywanie..."
                      : "Zapisz zmiany",

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
              ),
            ),
          ],
      ),
      ),
    );
  }
}