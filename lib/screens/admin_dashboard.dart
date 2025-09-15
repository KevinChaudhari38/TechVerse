import 'package:flutter/material.dart';
import 'add_inbuilt_course.dart';
import 'manage_courses.dart';
import 'add_pdf.dart';
import 'user_list_screen.dart';
import 'add_video.dart';
import 'view_payments.dart';

class AdminDashboard extends StatelessWidget {
  final String teacherId;
  const AdminDashboard({super.key,required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Welcome section
            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Manage courses, users, and system settings",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            _buildActionButton(
              context: context,
              icon: Icons.add_circle,
              title: "Add Inbuilt Course",
              subtitle: "Create new courses with content",
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddInbuiltCourse()));
              },
            ),
            
            SizedBox(height: 12),
            
            _buildActionButton(
              context: context,
              icon: Icons.manage_accounts,
              title: "Manage Courses",
              subtitle: "Edit or delete existing courses",
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ManageCourses()));
              },
            ),
            
            SizedBox(height: 12),
            
            _buildActionButton(
              context: context,
              icon: Icons.picture_as_pdf,
              title: "Add PDF",
              subtitle: "Upload PDF documents to courses",
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddPdf(teacherId: teacherId))
                );
              },
            ),
            
            SizedBox(height: 12),
            
            _buildActionButton(
              context: context,
              icon: Icons.video_library,
              title: "Add Video",
              subtitle: "Upload video content to courses",
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AddVideo(teacherId: teacherId))
                );
              },
            ),
            
            SizedBox(height: 12),
            
            _buildActionButton(
              context: context,
              icon: Icons.school,
              title: "View Students",
              subtitle: "Manage student accounts",
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => UserListScreen(role: "Student", adminId: teacherId)),
                );
              },
            ),
            
            SizedBox(height: 12),
            
            _buildActionButton(
              context: context,
              icon: Icons.person,
              title: "View Teachers",
              subtitle: "Manage teacher accounts",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserListScreen(role: "Teacher", adminId: teacherId)),
                );
              },
            ),
            
            SizedBox(height: 12),
            
            _buildActionButton(
              context: context,
              icon: Icons.payment,
              title: "View Payment History",
              subtitle: "Monitor all payment transactions",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewPaymentsPage()),
                );
              },
            ),
          ],
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
                        color: Colors.white,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      )),
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
