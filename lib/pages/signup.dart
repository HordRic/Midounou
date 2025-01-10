import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:midounou/pages/bottomnav.dart';
import 'package:midounou/pages/home.dart';
import 'package:midounou/widget/widget_support.dart';

import '../service/database.dart';
import '../service/shared_pref.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  registration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        if (userCredential.user != null) {
          String userId = userCredential.user!.uid;
          Map<String, dynamic> userInfoMap = {
            "name": name,
            "email": email,
            "id": userId,
          };

          await DatabaseMethods().addUserDetail(userInfoMap, userId);
          await SharedPreferenceHelper().saveUserId(userId);
          await SharedPreferenceHelper().saveUserName(name);
          await SharedPreferenceHelper().saveUserEmail(email);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(e.message ?? "An error occurred during registration")));
      }
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return Future.error('Sign in aborted by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        setState(() {
          isLoading = false;
        });
        return Future.error('Missing Google Auth Token');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        Map<String, dynamic> userInfoMap = {
          "name": userCredential.user!.displayName,
          "email": userCredential.user!.email,
          "id": userId,
        };

        await DatabaseMethods().addUserDetail(userInfoMap, userId);
        await SharedPreferenceHelper().saveUserId(userId);
        await SharedPreferenceHelper()
            .saveUserName(userCredential.user!.displayName!);
        await SharedPreferenceHelper()
            .saveUserEmail(userCredential.user!.email!);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomNav()));
      }

      return userCredential;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sign in with Google: $e")));
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.5,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                            Color(0xFFff5c30),
                            Color(0xFFe74b1a),
                          ])),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 3),
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
                      child: Text(""),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                      child: Column(
                        children: [
                          Center(
                              child: Image.asset(
                            "assets/logo.png",
                            width: MediaQuery.of(context).size.width / 1.5,
                            fit: BoxFit.cover,
                          )),
                          SizedBox(
                            height: 50.0,
                          ),
                          Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 1.7,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    Text(
                                      "Sign up",
                                      style: AppWidget.HeadLineTextFeildStyle(),
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    TextFormField(
                                      controller: nameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Name';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Name',
                                          hintStyle: AppWidget
                                              .semiBooldTextFeildStyle(),
                                          prefixIcon:
                                              Icon(Icons.person_outlined)),
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    TextFormField(
                                      controller: mailController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter E-mail';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Email',
                                          hintStyle: AppWidget
                                              .semiBooldTextFeildStyle(),
                                          prefixIcon:
                                              Icon(Icons.email_outlined)),
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    TextFormField(
                                      controller: passwordController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Password';
                                        }
                                        return null;
                                      },
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          hintText: 'Password',
                                          hintStyle: AppWidget
                                              .semiBooldTextFeildStyle(),
                                          prefixIcon:
                                              Icon(Icons.password_outlined)),
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            email = mailController.text;
                                            name = nameController.text;
                                            password = passwordController.text;
                                          });
                                          registration();
                                        }
                                      },
                                      child: Material(
                                        elevation: 5.0,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          width: 200,
                                          decoration: BoxDecoration(
                                              color: Color(0Xffff5722),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                              child: Text(
                                            "SIGN UP",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontFamily: 'Poppins1',
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: signInWithGoogle,
                                      icon: SvgPicture.asset(
                                        'assets/google_logo.svg',
                                        height: 24.0,
                                        width: 24.0,
                                      ),
                                      label: Text("Sign Up with Google"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 70.0,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LogIn()));
                              },
                              child: Text(
                                "Already have an account? Log In",
                                style: AppWidget.semiBooldTextFeildStyle(),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
