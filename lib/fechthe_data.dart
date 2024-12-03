import 'package:account_management_application/edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FetchTheDataFromFirebase extends StatefulWidget {
  final bool data;
  final bool delete;
  const FetchTheDataFromFirebase(
      {super.key, this.data = false, this.delete = false});

  @override
  State<FetchTheDataFromFirebase> createState() =>
      _FetchTheDataFromFirebaseState();
}

class _FetchTheDataFromFirebaseState extends State<FetchTheDataFromFirebase> {
  final CollectionReference<Map<String, dynamic>> items =
      FirebaseFirestore.instance.collection("UserData");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD Operation"),
        backgroundColor: Colors.pink,
      ),
      body: StreamBuilder(
        stream: items.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                    streamSnapshot.data!.docs[index];

                // Retrieve all fields from the document snapshot
                String firstName = documentSnapshot["firstName"] ?? "N/A";
                String lastName = documentSnapshot["lastName"] ?? "N/A";
                String mobile = documentSnapshot["mobile"] ?? "N/A";
                String email = documentSnapshot["email"] ?? "N/A";

                return Card(
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                      onTap: () {},
                      leading: widget.data
                          ? IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditUserScreen(
                                      documentId: documentSnapshot
                                          .id, // Pass document ID
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit),
                            )
                          : SizedBox(),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('First Name: $firstName'),
                          Text('Last Name: $lastName'),
                          Text('Mobile: $mobile'),
                          Text('Email: $email'),
                        ],
                      ),
                      trailing: widget.delete
                          ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                  context,
                                  documentSnapshot.id,
                                );
                              },
                            )
                          : SizedBox()),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('Do you want to delete this profile?'),
          actions: <Widget>[
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            // Delete button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteProfile(context, docId); // Delete the profile
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProfile(BuildContext context, String docId) {
    items.doc(docId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting profile: $error')),
      );
    });
  }
}
