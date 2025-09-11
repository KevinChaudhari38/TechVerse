import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'video_player_page.dart';
import 'payment_page.dart';

class UserListScreen extends StatelessWidget {
  final String role;
  final String adminId;
  const UserListScreen({super.key, required this.role,required this.adminId});

  Future<void> _deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  Future<void> _payTeacher(BuildContext context,String teacherId,{int amount=1000}) async{
    int? enteredAmount;

    await showDialog(
      context:context,
      builder:(ctx){
        TextEditingController controller=TextEditingController();
        return AlertDialog(
          title: const Text("Enter Amount to pay"),
          content: TextField(
            controller:controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Amount in Rs.",
            ),
          ),
          actions:[
            TextButton(
              onPressed:(){
                Navigator.of(ctx).pop();
              },
              child:const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed:(){
                enteredAmount= int.tryParse(controller.text);
                if(enteredAmount!=null && enteredAmount! >0){
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text("Pay"),
            ),
          ],
        );
      },
    );
    if(amount==null) return;
    final result=await Navigator.push(
      context,
      MaterialPageRoute(builder:(_)=>PaymentPage(amount:enteredAmount!),)
    );
    if(result==true){
      final paymentDoc={
        'from':adminId,
        'to':teacherId,
        'amount':amount,
        'timestamp':Timestamp.now(),
        'transId': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      await FirebaseFirestore.instance.collection('payments').add(paymentDoc);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment recorded successfully")),
      );
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchUploads(String teacherId) async {
    final coursesSnapshot = await FirebaseFirestore.instance.collection('courses').get();
    List<Map<String, dynamic>> pdfs = [];
    List<Map<String, dynamic>> videos = [];

    for (var doc in coursesSnapshot.docs) {
      final data = doc.data();

      // PDFs
      if (data['pdfUrls'] != null) {
        for (var pdf in List.from(data['pdfUrls'])) {
          if (pdf['uploadedBy'] == teacherId) pdfs.add(pdf);
        }
      }

      // Videos
      if (data['videoUrls'] != null) {
        for (var video in List.from(data['videoUrls'])) {
          if (video['uploadedBy'] == teacherId) videos.add(video);
        }
      }
    }

    return {'pdfs': pdfs, 'videos': videos};
  }
  void _openPdf(String pdfUrl) async{
    final Uri uri=Uri.parse("https://docs.google.com/viewer?url=$pdfUrl");
    if(await canLaunchUrl(uri)){
      await launchUrl(uri,mode:LaunchMode.externalApplication);
    }
  }
  void _openVideo(BuildContext context,String videoUrl){
    Navigator.push(
      context,MaterialPageRoute(builder:(_)=>VideoPlayerPage(url:videoUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View $role" + "s")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: role)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No $role found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData=user.data() as Map<String,dynamic>;
              final isPremium=userData['isPremium']??false;

              return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: role == "Teacher" ? _fetchUploads(user.id) : Future.value({'pdfs': [], 'videos': []}),
                builder: (context, uploadSnapshot) {
                  if (uploadSnapshot.connectionState == ConnectionState.waiting && role=="Teacher") {
                    return const ListTile(
                      title: Text("Loading uploads..."),
                    );
                  }

                  final uploads = uploadSnapshot.data ?? {'pdfs': [], 'videos': []};
                  final pdfs = uploads['pdfs']!;
                  final videos = uploads['videos']!;

                  return ExpansionTile(
                    leading: const Icon(Icons.person),
                    title: Text(user['email'] ?? "No email"),

                    subtitle: role=="Student"
                        ? Text("Role: ${userData['role']} | Status: ${isPremium ? "Premium" : "Free"}")
                        : Text("Role: ${userData['role']}"),
                    children: role == "Teacher"
                        ? [
                      if (pdfs.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("PDFs Uploaded:", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...pdfs.map((pdf) => ListTile(
                          title: Text(pdf['name'] ?? "Unnamed PDF"),
                          onTap:()=>_openPdf(pdf['url']??""),
                        )),
                      ],
                      if (videos.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Videos Uploaded:", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...videos.map((video) => ListTile(
                          title: Text(video['name'] ?? "Unnamed Video"),
                          onTap:()=>_openVideo(context,video['url']??""),
                        )),
                      ],
                      if(role=="Teacher")...[
                        const SizedBox(height:10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.payment),
                          label: const Text("Pay Teacher"),
                          onPressed:()=> _payTeacher(context,user.id,amount:100),
                        ),
                      ],
                    ]
                        : [],
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteUser(user.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${user['email']} deleted")),
                        );
                      },
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
