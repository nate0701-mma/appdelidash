import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/page/choseregister.dart';
import 'package:delidash/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:delidash/page/AddAddessPage.dart';
import 'package:delidash/page/LoginPage.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 15, 2, 15),
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
                          ? const Icon(
                              Icons.upload,
                              size: 60,
                              color: Colors.white,
                            )
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

                  const SizedBox(height: 10),

                  // ================== ชื่อ ==================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'ชื่อ',
                            style: GoogleFonts.notoSansThai(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "ป้อนชื่อ",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================== เบอร์โทร ==================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'เบอร์โทร',
                            style: GoogleFonts.notoSansThai(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            hintText: "ป้อนเบอร์โทร",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================== อีเมล ==================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'อีเมล',
                            style: GoogleFonts.notoSansThai(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: "ป้อนอีเมล",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================== รหัสผ่าน ==================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'รหัสผ่าน',
                            style: GoogleFonts.notoSansThai(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "ป้อนรหัสผ่าน",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================== ยืนยันรหัสผ่าน ==================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'ยืนยันรหัสผ่าน',
                            style: GoogleFonts.notoSansThai(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "ป้อนรหัสผ่านอีกครั้ง",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================== ที่อยู่ + ปุ่มเพิ่ม ==================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'ที่อยู่',
                            style: GoogleFonts.notoSansThai(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
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
                                    builder: (context) =>
                                        const AddAddressPage(),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    addressController.text =
                                        "${result['placeName']} (Lat: ${result['lat']}, Lng: ${result['lng']})";
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

                  // ================== ปุ่มสมัครสมาชิก ==================
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
                        child: Text(
                          "สมัครสมาชิก",
                          style: GoogleFonts.notoSansThai(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      // กดแล้วไปหน้า RegisterRiderPage
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
                      "สมัครสมาชิก",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void registeruser() async {
    try {
      var db = FirebaseFirestore.instance;

      String? imageUrl;

      // ✅ Upload ไป Supabase Storage
      if (_profileImage != null) {
        final fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

        await SupabaseConfig.client.storage
            .from("user_profiles") // 👈 bucket name
            .upload(fileName, _profileImage!);

        imageUrl = SupabaseConfig.client.storage
            .from("user_profiles")
            .getPublicUrl(fileName);
      }

      final data = {
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "address": addressController.text.trim(),
        "profileImage": imageUrl,
        "createdAt": DateTime.now(),
      };

      await db.collection("users").add(data);

      // ✅ แสดง Dialog ว่าสมัครสำเร็จ
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
}
