import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget{
  @override
  _RegisterScreenState createState()=>_RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen>{
  final _auth=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  String selectedRole='Student';

  void register() async{
    try{
      UserCredential user=await _auth.createUserWithEmailAndPassword(
        email:emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await _firestore.collection('users').doc(user.user!.uid).set({
        'email': user.user!.email,
        'role' : selectedRole,
        'uid': user.user!.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registred successfully as $selectedRole")));
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    }catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration failed")));
    }

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title section
            Container(
              margin: EdgeInsets.only(bottom: 40),
              child: Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Email field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            SizedBox(height: 16),
            
            // Password field
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            
            SizedBox(height: 16),
            
            // Role dropdown
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRole,
                  isExpanded: true,
                  items: ["Student","Teacher"].map((role)=>DropdownMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Icon(role == "Student" ? Icons.school : Icons.person),
                        SizedBox(width: 8),
                        Text(role),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val)=> setState(()=>selectedRole=val!),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Register button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Register",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Back to login button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Already have an account? Login",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}