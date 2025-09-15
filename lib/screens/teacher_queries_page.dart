import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherQueriesPage extends StatelessWidget{
  final String teacherId;
  const TeacherQueriesPage({super.key,required this.teacherId});

  void _answerQuery(BuildContext context,String docId,String question){
    final controller=TextEditingController();
    showDialog(
      context: context,
      builder: (_)=>AlertDialog(
        title: Text("Answer Query"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Text(question),
            const SizedBox(height:12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter answer",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
          actions:[
            TextButton(onPressed: ()=>Navigator.pop(context),child: const Text("Cancel")),
            ElevatedButton(
              onPressed:() async{
                await FirebaseFirestore.instance.collection('queries').doc(docId).update({
                  'answer':controller.text,
                  'teacherId':teacherId,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Answer Submitted")),
                );
              },
              child: const Text("Submit"),
            )
          ]
      ),

    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
    appBar: AppBar(title: const Text("Student Queries")),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('queries').where('status',isEqualTo:'Pending').orderBy('timestamp',descending:true).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final queries=snapshot.data!.docs;
        return ListView.builder(
          itemCount: queries.length,
          itemBuilder:(context,index){
            final query=queries[index];
            final data=query.data() as Map<String,dynamic>;

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data['question']),
                subtitle: Text("Answer : ${data['answer'].isNotEmpty ? data['answer'] : 'Not Answered Yet'}"),
                trailing: ElevatedButton(
                  child: const Text("Answer"),
                  onPressed: ()=>_answerQuery(context,query.id,data['question']),
                ),
              ),
            );
          },
        );
      },
    ),
    );
  }
}
