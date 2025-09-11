import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'video_player_page.dart';
import 'payment_page.dart';

class CourseContentPage extends StatelessWidget{
  final String courseId;
  final String courseTitle;
  final bool isPremium;

  const CourseContentPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.isPremium=false,
  });
  void _openPdf(String pdfUrl) async {
    final Uri uri = Uri.parse("https://docs.google.com/viewer?url=$pdfUrl");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openVideo(BuildContext context,String videoUrl) async{
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context)=>VideoPlayerPage(url:videoUrl),
      ),
    );
  }
  @override
  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(title: Text(courseTitle)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').doc(courseId).snapshots(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child:CircularProgressIndicator());
          }
          if(!snapshot.hasData || !snapshot.data!.exists){
            return const Center(child: Text("No Content Available"));
          }
          final course=snapshot.data!.data() as Map<String,dynamic>;

          final pdfs=<Map<String,dynamic>>[];

          if (course['pdfUrls'] != null && course['pdfUrls'] is List) {
            final pdfList = course['pdfUrls'] as List<dynamic>;
            for (var pdf in pdfList) {
              if (pdf is Map<String, dynamic>) {
                pdfs.add({
                  'name': pdf['name'] ?? 'PDF',
                  'url': pdf['url'] ?? '',
                });
              }
            }
          }
          final videos=<Map<String,dynamic>>[];
          if(course['videoUrls']!=null && course['videoUrls'] is List){
            final videoList=course['videoUrls'] as List<dynamic>;
            for(var video in videoList){
              videos.add({
                'name':video['name']??'Video',
                'url':video['url']??'',
              });
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!isPremium && pdfs.isNotEmpty)...[
                  Text("PDFs", style: TextStyle(fontSize: isTablet ? 20 : 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  ...pdfs.map((pdf)=>Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: isTablet ? 28 : 24),
                      title: Text(pdf['name'], style: TextStyle(fontSize: isTablet ? 16 : 14)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: ()=>_openPdf(pdf['url']),
                    ),
                  )),
                  SizedBox(height: 24),
                ],
                if(videos.isNotEmpty)...[
                  if(isPremium)...[
                    Text("Videos:", style: TextStyle(fontSize: isTablet ? 20 : 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    ...videos.map((video)=>Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.video_library, color: Colors.blue, size: isTablet ? 28 : 24),
                        title: Text(video['name'], style: TextStyle(fontSize: isTablet ? 16 : 14)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: ()=>_openVideo(context,video['url']),
                      ),
                    )),
                  ]
                  else...[
                    Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.lock, size: isTablet ? 48 : 40, color: Colors.amber[700]),
                          SizedBox(height: 16),
                          Text("Premium Content", style: TextStyle(fontSize: isTablet ? 20 : 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text("Videos are available only for premium users. Upgrade to access premium video content.",
                            style: TextStyle(fontSize: isTablet ? 16 : 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (){
                                Navigator.push(context,MaterialPageRoute(builder:(_)=>PaymentPage(amount:1)));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                              child: Text("Upgrade to Premium", style: TextStyle(fontSize: isTablet ? 16 : 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}