import 'package:car_parking/Login/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _password = true;
  bool _password1 = true;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  Future<void> saveUsername() async {
  User? user = _auth.currentUser;
  if (user != null) {
    await _firestore.collection('users').doc(user.uid).set({
      'username': _usernameController.text,
    });
  } else {
    print('User not logged in');
  }
}

  Future<User?> signUpWithEmailAndPassword() async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      await credential.user?.sendEmailVerification();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("Account already exists");
      }
    } catch (e) {
      print("Error occured");
    }
    return null;
  }

  Future checkConnection() async {
    var connectivity = await (Connectivity().checkConnectivity());
    if (connectivity == ConnectivityResult.none) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("No Internet Connection"),
              actions: [
                TextButton(
                    onPressed: Navigator.of(context).pop, child: Text("OK"))
              ],
            );
          });
    } else {
      signup();
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: 0, right: 80, top: 15, bottom: 30),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the name';
                    }
                    return null;
                  },
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the email';
                    }
                    return null;
                  },
                  controller: _emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'example@gmail.com'),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the password';
                    } else if (value.length <= 6) {
                      return 'must be 6 characters';
                    }
                    return null;
                  },
                  controller: _passwordController,
                  enableInteractiveSelection: false,
                  obscureText: _password,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Create a password',
                    hintText: 'must be 6 characters',
                    suffixIcon: togglepassword(),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the password';
                    } else if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      return "Password doesn't match";
                    }
                    return null;
                  },
                  controller: _confirmPasswordController,
                  enableInteractiveSelection: false,
                  obscureText: _password1,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm password',
                    hintText: 'repeat password',
                    suffixIcon: togglepassword1(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SizedBox(
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF1D749A), Color(0xFF296093)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight
                          ),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            checkConnection();
                          }
                        },
                        child: Text(
                          'Sign Up',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                )
                            ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: SizedBox(height: 20.0),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder:(ctx)=>Loginpage()));
                  },
                  child: Text(
                    'Already have an account? Log in',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void signup() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
                child: CircularProgressIndicator(
              color: Colors.blue,
            )));
    User? user = await signUpWithEmailAndPassword();
    if (user != null) {
      saveUsername();
      print("User is created successfully");
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        FirebaseAuth.instance.signOut();
        Navigator.push(context,MaterialPageRoute(builder:(ctx)=>Loginpage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Something went wrong'),
          margin: EdgeInsets.all(5),
          elevation: 10,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } else {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Account already exists'),
        margin: EdgeInsets.all(5),
        elevation: 10,
        behavior: SnackBarBehavior.floating,
      ));
      print("Error occured");
    }
  }

  Widget togglepassword() {
    return IconButton(
      onPressed: () {
        setState(() {
          _password = !_password;
        });
      },
      icon: _password ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
      color: Colors.grey,
    );
  }

  Widget togglepassword1() {
    return IconButton(
      onPressed: () {
        setState(() {
          _password1 = !_password1;
        });
      },
      icon: _password1 ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
      color: Colors.grey,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
