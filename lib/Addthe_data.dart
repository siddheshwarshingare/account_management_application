import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddtheDataInFirebase extends StatelessWidget {
  const AddtheDataInFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    final AddDataController controller = Get.put(AddDataController());
    final _formKey = GlobalKey<FormState>(); // GlobalKey for Form validation

    Color buttonColor = Colors.pink.shade200;

    return Scaffold(
      backgroundColor: Colors.greenAccent[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent[400],
        title: Text("Add The Data In Firestore"),
      ),
      body: Form(
        key: _formKey, // Assign GlobalKey to the Form
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // First Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onChanged: (value) => controller.firstName.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Last Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onChanged: (value) => controller.lastName.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Mobile Number
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => controller.mobile.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mobile Number is required';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit Mobile Number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Email ID
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email ID',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => controller.email.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid Email Address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Pick Image
                ElevatedButton(
                  onPressed: () => controller.pickImage(),
                  child: Text("Pick Image from Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent[400],
                  ),
                ),
                SizedBox(height: 10),

                // Display Image
                Obx(() {
                  if (controller.image.value != null) {
                    return Image.file(controller.image.value!,
                        height: 200, width: 200);
                  } else {
                    return Container();
                  }
                }),
                SizedBox(height: 10),

                // Password
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  obscureText: true,
                  onChanged: (value) => controller.password.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Confirm Password
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  obscureText: true,
                  onChanged: (value) =>
                      controller.confirmPassword.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm Password is required';
                    }
                    if (value != controller.password.value) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final CollectionReference items =
                          FirebaseFirestore.instance.collection("UserData");

                      // Check if mobile number already exists
                      QuerySnapshot querySnapshot = await FirebaseFirestore
                          .instance
                          .collection('UserData')
                          .where('mobile', isEqualTo: controller.mobile.value)
                          .get();

                      if (querySnapshot.docs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Mobile number already exists!')));
                      } else {
                        String imageUrl = '';
                        if (controller.image.value != null) {
                          imageUrl = await controller
                              .uploadImage(controller.image.value!);
                        }

                        // Add data to Firebase Firestore
                        items.add({
                          "firstName": controller.firstName.value,
                          "lastName": controller.lastName.value,
                          "email": controller.email.value,
                          "mobile": controller.mobile.value,
                          "imageUrl": imageUrl,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Data added successfully!')));
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddDataController extends GetxController {
  var firstName = ''.obs;
  var lastName = ''.obs;
  var mobile = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var image = Rx<File?>(null);

  final picker = ImagePicker();

  // Function to pick image from gallery
  Future<void> pickImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      image.value = File(pickedFile.path);
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('user_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL; // Return the download URL for the image
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }
}
