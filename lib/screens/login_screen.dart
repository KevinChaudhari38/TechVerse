import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{
  final _auth = FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
  final emailController=TextEditingController();
  final passwordController=TextEditingController();

  void login() async{
    try{
      UserCredential user=await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      DocumentSnapshot userData= await _firestore.collection('users').doc(user.user!.uid).get();
      if (!userData.exists) {
        throw Exception("User document not found in Firestore.");
      }

      final data = userData.data() as Map<String, dynamic>;

      if (!data.containsKey('role')) {
        throw Exception("User document missing 'role' field.");
      }
      String role=userData['role'];
      emailController.clear();
      passwordController.clear();
      if(role=='Student'){
        Navigator.push(context,MaterialPageRoute(builder:(_)=>StudentDashboard(studentId:user.user!.uid)));

      }else if(role=='Teacher'){
        Navigator.push(context,MaterialPageRoute(builder:(_)=>TeacherDashboard(teacherId:user.user!.uid)));
      }else if (role == 'Admin') {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => AdminDashboard(teacherId:user.user!.uid)));
      }
    }catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed")));
      passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context){
    print("Rendering LoginScreen");
    
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            // Logo or title section
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Text(
                "TechVerse",
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
            
            SizedBox(height: 24),
            
            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Register button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (_)=> RegisterScreen()));
                },
                child: Text(
                  "Don't have an account? Register Here",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            
            SizedBox(height: 8),
            
            // Forgot password button
            TextButton(
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (context){
                    final resetEmailController=TextEditingController();
                    return AlertDialog(
                      title: Text("Reset Password"),
                      content: TextField(
                        controller: resetEmailController,
                        decoration: InputDecoration(
                          labelText: "Enter Your Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed:()=>Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async{
                            try{
                              await _auth.sendPasswordResetEmail(
                                email:resetEmailController.text.trim(),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Password reset email sent")),
                              );
                            }
                            catch(e){
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error ; ${e.toString()}")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                          child: Text("Send", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                "Forgot Password?",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}




