
import 'package:flutter/material.dart';

import '../../constants/images_names.dart';
import '../../constants/routes.dart';
import 'edit_phone.dart';

class ProfilePage extends StatefulWidget {
  static const route_name=profile_route;
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using an AppBar for a consistent header
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture icon with edit capability
            GestureDetector(
              onTap: () {
                // TODO: Navigate to profile picture editing page
              },
              child: CircleAvatar(
                radius: 50,
                child: MyImages.user_image,
              ),
            ),
            const SizedBox(height: 20),
            // Username display with edit option
            buildUserInfoDisplay(
              label: "Username",
              value:  "No username set",
              onEdit: () {
                // TODO: Navigate to username editing page
                Navigator.of(context).pushNamed(edit_user_name);
              },
            ),
            const SizedBox(height: 10),
            // Email display without edit option
            buildUserInfoDisplay(
              label: "Email",
              value:  "No email set",
              onEdit: () {}, // This callback won't be used since edit is hidden
              showEdit: false,
            ),
            const SizedBox(height: 10),
            // Phone number display with edit option
            buildUserInfoDisplay(
              label: "Phone",
              value:  "+91 12345 6789",
              onEdit: () {
                // TODO: Navigate to phone number editing page
                Navigator.of(context).pushNamed(EditPhoneFormPage.route_name);
              },
            ),
            buildUserInfoDisplay(label: 'Verfication Status', value: 'Verified', onEdit: (){},showEdit: false),
          ],
        ),
      ),
    );
  }

  /// Widget to display each user info item with a label, value, and an optional edit icon.
  Widget buildUserInfoDisplay({
    required String label,
    required String value,
    required VoidCallback onEdit,
    bool showEdit = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            )),
        const SizedBox(height: 5),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              if (showEdit)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
