import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:midounou/pages/bottomnav.dart';
import 'package:midounou/pages/forgotpassword.dart';
import 'package:midounou/pages/signup.dart';

import '../widget/widget_support.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  bool isLoading = false;
  final _formkey = GlobalKey<FormState>();

  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  userLogin() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No User Found for that Email")));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Wrong Password Provided by User")));
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
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Form(
                                key: _formkey,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    Text(
                                      "Login",
                                      style: AppWidget.HeadLineTextFeildStyle(),
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    TextFormField(
                                      controller: useremailcontroller,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Email';
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
                                      controller: userpasswordcontroller,
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
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotPassword()));
                                      },
                                      child: Container(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            "Forgot Password?",
                                            style: AppWidget
                                                .semiBooldTextFeildStyle(),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (_formkey.currentState!.validate()) {
                                          setState(() {
                                            email = useremailcontroller.text;
                                            password =
                                                userpasswordcontroller.text;
                                          });
                                          userLogin();
                                        }
                                      },
                                      child: Material(
                                        elevation: 5.0,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 15),
                                          width: 200,
                                          decoration: BoxDecoration(
                                              color: Color(0Xffff5722),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                              child: Text(
                                            "LOGIN",
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
                                      label: Text("Log In with Google"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50.0,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUp()));
                              },
                              child: Text(
                                "Don't have an account? Sign up",
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
