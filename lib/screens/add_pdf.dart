import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class AddPdf extends StatefulWidget {
  final String teacherId;
  const AddPdf({required this.teacherId,super.key});

  @override
  AddPdfState createState() => AddPdfState();
}

class AddPdfState extends State<AddPdf> {
  String? selectedSubject;
  bool _isLoading = false;

  final String cloudinaryName = 'dpntbppvp';
  final String cloudinaryUploadPreset = 'flutter_unsigned_preset';

  Future<List<String>> _fetchSubjects() async {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();
    return snapshot.docs.map((doc) => doc['title'].toString()).toList();
  }

  Future<String?> _uploadToCloudinary({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryName/raw/upload');
    var request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: 'file'));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resString = await response.stream.bytesToString();
      return jsonDecode(resString)['secure_url'];
    }
    return null;
  }

  Future<void> _uploadPdfForSubject() async {
    if (selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a subject")),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final fileName = result.files.single.name;
      final fileBytes = result.files.single.bytes;

      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to read file bytes")),
        );
        setState(() => _isLoading = false);
        return;
      }

      final fileUrl = await _uploadToCloudinary(fileBytes: fileBytes, fileName: fileName);

      if (fileUrl != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('courses')
            .where('title', isEqualTo: selectedSubject)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final docId = snapshot.docs.first.id;
          await FirebaseFirestore.instance.collection('courses').doc(docId).update({
            'pdfUrls': FieldValue.arrayUnion([
              {'name': fileName, 'url': fileUrl,'uploadedBy':widget.teacherId,"uploadedAt":Timestamp.now()}
            ]),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PDF uploaded successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Course not found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cloudinary upload failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Add PDF")),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 32 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 500 : screenWidth * 0.9,
                  ),
                  child: FutureBuilder<List<String>>(
            future: _fetchSubjects(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final subjects = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.picture_as_pdf, size: isTablet ? 64 : 48, color: Theme.of(context).primaryColor),
                        SizedBox(height: 16),
                        Text("Upload PDF Document", style: TextStyle(fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Select a course and upload your PDF file", style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    value: selectedSubject,
                    hint: const Text("Select Subject"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.school),
                    ),
                    onChanged: (value) => setState(() => selectedSubject = value),
                    items: subjects.map((subject) => DropdownMenuItem(value: subject, child: Text(subject))).toList(),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload PDF"),
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _uploadPdfForSubject,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
