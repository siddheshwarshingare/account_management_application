import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditUserScreen extends StatefulWidget {
  final String documentId; // Pass the document ID to fetch specific data

  EditUserScreen({required this.documentId});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController mobileController;
  late TextEditingController emailController;

  // Initial values for fields
  String firstName = '';
  String lastName = '';
  String mobile = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    mobileController = TextEditingController();
    emailController = TextEditingController();
    _fetchUserData();
  }

  // Fetch the user data from Firestore and set default values
  void _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(widget.documentId)
          .get();

      if (userDoc.exists) {
        setState(() {
          // Set the initial values of the fields
          firstName = userDoc['firstName'];
          lastName = userDoc['lastName'];
          mobile = userDoc['mobile'];
          email = userDoc['email'];

          // Pre-fill the text fields with the fetched data
          firstNameController.text = firstName;
          lastNameController.text = lastName;
          mobileController.text = mobile;
          emailController.text = email;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Update user data in Firestore
  void _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('UserData')
            .doc(widget.documentId)
            .update({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'mobile': mobileController.text,
          'email': emailController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("User data updated successfully!"),
        ));
        Navigator.pop(context); // Close the edit screen
      } catch (e) {
        print("Error updating user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Name Field
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the first name';
                  }
                  return null;
                },
                onChanged: (value) {
                  firstName = value; // Track user input for first name
                },
              ),
              // Last Name Field
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the last name';
                  }
                  return null;
                },
                onChanged: (value) {
                  lastName = value;
                },
              ),
              // Mobile Field
              TextFormField(
                controller: mobileController,
                decoration: InputDecoration(labelText: 'Mobile'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mobile number';
                  }
                  return null;
                },
                onChanged: (value) {
                  mobile = value;
                },
              ),
              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email address';
                  }
                  return null;
                },
                onChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateUserData,
                  child: Text('Update User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
