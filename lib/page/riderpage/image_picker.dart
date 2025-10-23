import 'dart:io';
import 'package:flutter/material.dart';
import 'package:delidash/supabase_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadVehiclePage extends StatefulWidget {
  const UploadVehiclePage({Key? key}) : super(key: key);

  @override
  State<UploadVehiclePage> createState() => _UploadVehiclePageState();
}

class _UploadVehiclePageState extends State<UploadVehiclePage> {
  File? _vehicleImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // เลือกรูปจาก gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _vehicleImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() => _vehicleImage = null);
  }

  Future<void> _uploadVehicle() async {
    if (_vehicleImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเลือกรูปยานพาหนะ")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final fileName = "vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // ✅ ใช้ uploadBinary แบบเดียวกับ RegisterRiderPage
      final bytes = await _vehicleImage!.readAsBytes();

      await SupabaseConfig.client.storage
          .from("rider_vehicles")
          .uploadBinary(fileName, bytes);

      // ดึง public URL
      final vehicleImageUrl = SupabaseConfig.client.storage
          .from("rider_vehicles")
          .getPublicUrl(fileName);

      // เก็บ URL ใน Firestore
      final data = {
        "vehicleImage": vehicleImageUrl,
        "createdAt": DateTime.now(),
      };
      await FirebaseFirestore.instance.collection("rider_vehicles").add(data);

      setState(() {
        _isUploading = false;
        _vehicleImage = null;
      });

      // ส่ง URL กลับไป RegisterRiderPage
      Navigator.pop(context, vehicleImageUrl);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("อัปโหลดเรียบร้อยแล้ว")));
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
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
          onPressed: () => Navigator.pop(context),
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
                child: _vehicleImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _vehicleImage!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
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
              onPressed: _isUploading ? null : _uploadVehicle,
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
                      'อัปโหลด',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
