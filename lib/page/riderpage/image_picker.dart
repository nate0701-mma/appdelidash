import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:delidash/supabase_config.dart';

class UploadVehiclePage extends StatefulWidget {
  const UploadVehiclePage({Key? key}) : super(key: key);

  @override
  State<UploadVehiclePage> createState() => _UploadVehiclePageState();
}

class _UploadVehiclePageState extends State<UploadVehiclePage> {
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadToSupabase() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final bytes = await _image!.readAsBytes();
      final fileName = "vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // อัปโหลดไป Supabase bucket "rider_vehicles"
      await SupabaseConfig.client.storage
          .from("rider_vehicles")
          .uploadBinary(fileName, bytes);

      // ดึง public URL
      final publicUrl = SupabaseConfig.client.storage
          .from("rider_vehicles")
          .getPublicUrl(fileName);

      // ส่งกลับ URL
      Navigator.pop(context, publicUrl);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาดในการอัปโหลด: $e")));
    }
  }

  void _finish() {
    if (_image != null) {
      _uploadToSupabase();
    } else {
      Navigator.pop(context, null); // ส่ง null ถ้ายังไม่เลือกไฟล์
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6DBF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _finish,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'อัปโหลดรูปยานพาหนะ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : const Icon(
                        Icons.cloud_upload,
                        size: 50,
                        color: Colors.black54,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _finish,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUploading
                    ? Colors.grey
                    : Colors.purple[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'เสร็จสิ้น',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
