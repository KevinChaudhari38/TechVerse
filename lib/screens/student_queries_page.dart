import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentQueriesPage extends StatelessWidget {
  const StudentQueriesPage({super.key});

  Future<void> _markSolved(String docId) async {
    await FirebaseFirestore.instance
        .collection('queries')
        .doc(docId)
        .update({'status': 'Solved'});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Queries")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('queries')
            .where('studentId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No queries yet"));
          }

          final queries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: queries.length,
            itemBuilder: (context, index) {
              final query = queries[index];
              final data = query.data() as Map<String, dynamic>;

              final question = data['question'] ?? 'No Question';
              final answer = (data['answer'] ?? '').toString();
              final status = (data['status'] ?? 'Unknown').toString();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(question),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Answer: ${answer.isNotEmpty ? answer : 'Not Answered Yet'}"),
                      Text("Status: $status"),
                    ],
                  ),
                  trailing: status == 'Pending'
                      ? IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _markSolved(query.id),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
