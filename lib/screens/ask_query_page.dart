import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AskQueryPage extends StatefulWidget{
  const AskQueryPage({super.key});
  @override
  State<AskQueryPage> createState()=>_AskQueryPageState();
}
class _AskQueryPageState extends State<AskQueryPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _submitQuery() async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('queries').add({
      'studentId': user!.uid,
      'question': _controller.text,
      'answer': '',
      'teacherId':'',
      'status': 'Pending',
      'timestamp': Timestamp.now(),
    });
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Query Submitted')),
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Ask Query")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:[
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter Your Query Here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height:16),
            ElevatedButton(
              onPressed:_submitQuery,
              child: const Text("Submit Query"),
            ),
          ],
        ),
      ),
    );
  }
}