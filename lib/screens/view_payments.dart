import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPaymentsPage extends StatelessWidget {
  const ViewPaymentsPage({super.key});

  Future<Map<String, String>> _getEmails(String fromId, String toId) async {
    final fromSnap = await FirebaseFirestore.instance.collection('users').doc(fromId).get();
    final toSnap = await FirebaseFirestore.instance.collection('users').doc(toId).get();

    final fromEmail = fromSnap.exists
        ? (fromSnap.data() as Map<String, dynamic>)['email'] ?? fromId
        : fromId;
    final toEmail = toSnap.exists
        ? (toSnap.data() as Map<String, dynamic>)['email'] ?? toId
        : toId;

    return {'fromEmail': fromEmail, 'toEmail': toEmail};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('payments').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Payments Found"));
          }

          final payments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index].data() as Map<String, dynamic>;
              final fromId = payment['from'] ?? 'Unknown';
              final toId = payment['to'] ?? 'Unknown';
              final amount = payment['amount'] ?? 0;
              final transId = payment['transId'] ?? 'N/A';
              final timestamp = payment['timestamp'] as Timestamp?;

              return FutureBuilder<Map<String, String>>(
                future: _getEmails(fromId, toId),
                builder: (context, emailSnapshot) {
                  if (!emailSnapshot.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  final fromEmail = emailSnapshot.data!['fromEmail']!;
                  final toEmail = emailSnapshot.data!['toEmail']!;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.payment, color: Colors.green),
                      title: Text("₹$amount Transaction"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("From: $fromEmail"),
                          Text("To: $toEmail"),
                          Text("Transaction Id: $transId"),
                          Text("Date: ${timestamp != null ? timestamp.toDate().toString() : 'N/A'}"),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
