import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import '../service/auth.dart';
import '../service/database.dart';
import '../service/shared_pref.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profile, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    onthisload();
  }

  Future getImage() async {
    try {
      var image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
          isLoading = true;
        });
        await uploadItem();
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to pick image: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future uploadItem() async {
    try {
      if (selectedImage != null) {
        String addId = randomAlphaNumeric(10);
        Reference ref = FirebaseStorage.instance
            .ref()
            .child("profileImages")
            .child("$addId.jpg");
        UploadTask uploadTask = ref.putFile(selectedImage!);
        var downloadUrl = await (await uploadTask).ref.getDownloadURL();
        profile = downloadUrl;
        await SharedPreferenceHelper().saveUserProfile(profile!);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Profile image uploaded successfully"),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to upload image: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future getthesharedpref() async {
    try {
      setState(() {
        isLoading = true;
      });
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDetails =
            await DatabaseMethods().getUserDetails(user.uid);
        name = userDetails.get('name');
        email = userDetails.get('email');
        profile = userDetails.get('profile');
        await SharedPreferenceHelper().saveUserName(name!);
        await SharedPreferenceHelper().saveUserEmail(email!);
        await SharedPreferenceHelper().saveUserProfile(profile!);
      }
      setState(() {
        isLoading = false;
      });
      print("Profile loaded: name=$name, email=$email, profile=$profile");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Profile loaded successfully"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("Error loading profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to load profile: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  onthisload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("Building Profile Page");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : name == null || email == null
              ? const Center(child: Text("Failed to load profile data"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 45.0, left: 20.0, right: 20.0),
                            height: MediaQuery.of(context).size.height / 4.3,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(
                                    MediaQuery.of(context).size.width, 105.0),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height / 6.5),
                              child: Material(
                                elevation: 10.0,
                                borderRadius: BorderRadius.circular(60),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: GestureDetector(
                                    onTap: getImage,
                                    child: selectedImage == null
                                        ? profile == null
                                            ? Image.asset(
                                                "assets/boy.jpg",
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                profile!,
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                              )
                                        : Image.file(
                                            selectedImage!,
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 70.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name ?? "No Name",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      _buildInfoCard(Icons.person, "Name", name ?? "No Name"),
                      const SizedBox(height: 30.0),
                      _buildInfoCard(Icons.email, "Email", email ?? "No Email"),
                      const SizedBox(height: 30.0),
                      _buildInfoCard(
                          Icons.description, "Terms and Condition", ""),
                      const SizedBox(height: 30.0),
                      _buildActionCard(Icons.delete, "Delete Account", () {
                        AuthMethods().deleteuser();
                      }),
                      const SizedBox(height: 30.0),
                      _buildActionCard(Icons.logout, "LogOut", () {
                        AuthMethods().SignOut();
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 2.0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 20.0),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
