import 'package:flutter/material.dart';
import 'add_pdf.dart';
import 'add_video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'teacher_queries_page.dart';

class TeacherDashboard extends StatelessWidget {
  final String teacherId;
  const TeacherDashboard({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    print("TeacherTransactionsPage opened with teacherId: $teacherId");

    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Dashboard")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    const Icon(Icons.person, size: 64, color: Colors.black87),
                    const SizedBox(height: 16),
                    const Text(
                      "Teacher Dashboard",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add videos and PDFs for your course content, answer student queries, and earn money. Manage your course content and view transactions",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              _buildActionButton(
                context: context,
                icon: Icons.picture_as_pdf,
                title: "Add PDF",
                subtitle: "Upload PDF documents to courses",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPdf(teacherId: teacherId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                context: context,
                icon: Icons.video_library,
                title: "Add Video",
                subtitle: "Upload video content to courses",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddVideo(teacherId: teacherId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                context: context,
                icon: Icons.question_answer,
                title: "View Queries",
                subtitle: "Check The Queries By Students",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TeacherQueriesPage(teacherId: teacherId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                context: context,
                icon: Icons.payment,
                title: "View Transactions",
                subtitle: "Check your payment history",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TeacherTransactionsPage(teacherId: teacherId),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class TeacherTransactionsPage extends StatelessWidget {
  final String teacherId;
  const TeacherTransactionsPage({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('to', isEqualTo: teacherId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Transaction Found"));
          }
          final payments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index].data() as Map<String, dynamic>;
              final amount = payment['amount'] ?? 0;
              final timestamp = payment['timestamp'] as Timestamp?;
              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: Text("₹$amount received"),
                  subtitle: Text(
                      "Date: ${timestamp != null ? timestamp.toDate().toString() : 'N/A'}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
