import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/page/AddAddessPage.dart';
import 'package:delidash/page/choseregister.dart';
import 'package:delidash/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:delidash/page/LoginPage.dart';

class Registeruser extends StatefulWidget {
  const Registeruser({super.key});

  @override
  State<Registeruser> createState() => _RegisteruserState();
}

class _RegisteruserState extends State<Registeruser> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // ✅ ตัวแปรเก็บพิกัดที่เลือกจากหน้า AddAddressPage
  double? selectedLat;
  double? selectedLng;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // Upload Profile
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: _profileImage == null
                      ? const Icon(Icons.upload, size: 60, color: Colors.white)
                      : ClipOval(
                          child: Image.file(
                            _profileImage!,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "สมัครสมาชิก",
                style: GoogleFonts.notoSansThai(
                  textStyle: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // ======= ชื่อ =======
              _buildInput("ชื่อ", "ป้อนชื่อ", nameController),
              _buildInput("เบอร์โทร", "ป้อนเบอร์โทร", phoneController),
              _buildInput("อีเมล", "ป้อนอีเมล", emailController),
              _buildInput(
                "รหัสผ่าน",
                "ป้อนรหัสผ่าน",
                passwordController,
                obscure: true,
              ),
              _buildInput(
                "ยืนยันรหัสผ่าน",
                "ป้อนรหัสผ่านอีกครั้ง",
                confirmPasswordController,
                obscure: true,
              ),

              const SizedBox(height: 15),

              // ======= ที่อยู่ =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ที่อยู่',
                      style: GoogleFonts.notoSansThai(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: addressController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "ระบุที่อยู่",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddAddressPage(),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                selectedLat = result['lat'];
                                selectedLng = result['lng'];
                                addressController.text =
                                    "${result['placeName']} (Lat: ${selectedLat}, Lng: ${selectedLng})";
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[300],
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(18),
                          ),
                          child: const Text("เพิ่ม"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ======= ปุ่มสมัครสมาชิก =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: registeruser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      "สมัครสมาชิก",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // กลับหน้าเลือกประเภท
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Choseregister(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF65176C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "กลับหน้าเลือกสมัครสมาชิก",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันบันทึกข้อมูลลง Firestore
  void registeruser() async {
    try {
      var db = FirebaseFirestore.instance;
      String? imageUrl;

      // ✅ Upload รูปโปรไฟล์ไป Supabase
      if (_profileImage != null) {
        final fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
        await SupabaseConfig.client.storage
            .from("user_profiles")
            .upload(fileName, _profileImage!);
        imageUrl = SupabaseConfig.client.storage
            .from("user_profiles")
            .getPublicUrl(fileName);
      }

      // ✅ สร้างข้อมูลผู้ใช้
      final userData = {
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "profileImage": imageUrl,
        "createdAt": DateTime.now(),
      };

      // ✅ เพิ่ม users
      final userRef = await db.collection("users").add(userData);
      final userId = userRef.id;

      // ✅ เพิ่ม address พร้อม lat/lng
      if (addressController.text.isNotEmpty &&
          selectedLat != null &&
          selectedLng != null) {
        await db.collection("addresses").add({
          "userId": userId,
          "address": addressController.text.trim(),
          "lat": selectedLat,
          "lng": selectedLng,
          "createdAt": DateTime.now(),
        });
      }

      // ✅ แสดงข้อความสำเร็จ
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("สำเร็จ"),
          content: const Text("สมัครสมาชิกสำเร็จ!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Loginpage()),
                );
              },
              child: const Text("ตกลง"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  // ✅ helper สร้าง input field
  Widget _buildInput(
    String label,
    String hint,
    TextEditingController ctrl, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 16),
          ),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
