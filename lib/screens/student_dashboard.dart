import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'course_content_page.dart';
import 'payment_page.dart';
import 'ask_query_page.dart';
import 'student_queries_page.dart';

class StudentDashboard extends StatefulWidget {
  final String studentId;
  const StudentDashboard({super.key,required this.studentId});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Razorpay _razorpay;
  bool isPremium = false;

  @override
  void initState(){
    super.initState();
    _loadPremiumStatus();
  }
  Future<void> _loadPremiumStatus() async{
    final snapshot=await FirebaseFirestore.instance.collection('users').doc(widget.studentId).get();
    if(snapshot.exists){
      setState((){
        isPremium=snapshot.data()?['isPremium']??false;
      });
    }
  }
  Future<void> _updatePremiumStatus() async{
    await FirebaseFirestore.instance.collection('users').doc(widget.studentId).update({'isPremium':true});
    setState(()=>isPremium=true);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Notice banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.lightBlue.shade200),
                ),
                child: const Text(
                  "Notice: Access PDFs for free. Get premium to watch videos for selected subjects and ask queries to professional teachers.",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),

              if (docs.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Text("No courses available"),
                ))
              else
                ...docs.map((d) {
                  final course = d.data() as Map<String, dynamic>;
                  return _buildCourseCard(context, course, d.id);
                }).toList(),

              const SizedBox(height: 12),

              if (isPremium)
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AskQueryPage(),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Ask Queries",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              if (isPremium) const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentQueriesPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    alignment: Alignment.center,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "View Queries",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course, String courseId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            if (course['imageUrl'] != null && course['imageUrl'].toString().isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(course['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            SizedBox(height: 12),

            // Course Title
            Text(
              course['title'] ?? "No Title",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8),

            // Course Description
            Text(
              course['description'] ?? "No Description",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 16),

            // View Content Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseContentPage(
                        courseId: courseId,
                        courseTitle: course['title'] ?? "Course",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("View Content", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(height: 8),

            // Premium Content Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: isPremium
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseContentPage(
                              courseId: courseId,
                              courseTitle: course['title'] ?? "Course",
                              isPremium: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("View Premium Content", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PaymentPage(amount: 1)),
                        );
                        if (result == true) {
                          final paymentDoc = {
                            'from': widget.studentId,
                            'to': "server",
                            'amount': 1,
                            'timestamp': Timestamp.now(),
                            'transId': DateTime.now().millisecondsSinceEpoch.toString(),
                          };
                          await FirebaseFirestore.instance.collection('payments').add(paymentDoc);
                          await _updatePremiumStatus();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Add Premium (₹1)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
            ),

          ],
        ),
      ),
    );
  }
}
