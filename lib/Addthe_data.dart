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

    Color buttonColor = Colors.pink.shade200;

    return Scaffold(
      backgroundColor: Colors.greenAccent[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent[400],
        title: Text("Add The Data In Firestore"),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onChanged: (value) => controller.firstName.value = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onChanged: (value) => controller.lastName.value = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => controller.mobile.value = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email ID',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => controller.email.value = value,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.pickImage(),
                  child: Text("Pick Image from Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent[400],
                  ),
                ),
                SizedBox(height: 10),
                Obx(() {
                  if (controller.image.value != null) {
                    return Image.file(controller.image.value!,
                        height: 200, width: 200);
                  } else {
                    return Container();
                  }
                }),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  obscureText: true,
                  onChanged: (value) => controller.password.value = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  obscureText: true,
                  onChanged: (value) =>
                      controller.confirmPassword.value = value,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                  onPressed: () async {
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

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data added successfully!')));
                      Navigator.pop(context);
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
