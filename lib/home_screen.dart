import 'package:account_management_application/Addthe_data.dart';
import 'package:account_management_application/fechthe_data.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade200,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade200,
        automaticallyImplyLeading: false,
        title: Text(
          "Home Screen",
          style: TextStyle(shadows: [
            Shadow(blurRadius: 10),
          ], color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Navigate to corresponding screen based on card tapped
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddtheDataInFirebase()),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FetchTheDataFromFirebase()),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FetchTheDataFromFirebase()),
                  );
                  // }
                  //else if (index == 3) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => RetrieveScreen()),
                  //   );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: Colors.primaries)),
                child: Card(
                  shadowColor: Colors.grey,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      getCardTitle(index),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            // Logout button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout(context); // Call your logout function
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
    Navigator.pop(context);

    Navigator.pushReplacementNamed(context, '/login');
  }

  String getCardTitle(int index) {
    switch (index) {
      case 0:
        return 'Create';
      case 1:
        return 'Update';
      case 2:
        return 'Delete';
      case 3:
        return 'Retrieve';
      default:
        return 'Action';
    }
  }
}
