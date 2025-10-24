import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:delidash/supabase_config.dart';

class EditProfilePage extends StatefulWidget {
  final String userId; // รับ userId จากหน้า Profile
  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  String? currentProfileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ โหลดข้อมูลผู้ใช้จาก Firestore
  Future<void> _loadUserData() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data()!;
        nameController.text = data["name"] ?? "";
        phoneController.text = data["phone"] ?? "";
        emailController.text = data["email"] ?? "";
        currentProfileImage = data["profileImage"];
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("โหลดข้อมูลผิดพลาด: $e")));
    }
    setState(() => isLoading = false);
  }

  // ✅ ฟังก์ชันเลือกรูปใหม่
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // ✅ ฟังก์ชันอัปเดตโปรไฟล์
  Future<void> _updateProfile() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")));
      return;
    }

    try {
      String? imageUrl = currentProfileImage;

      // ถ้ามีรูปใหม่ → อัปโหลดไป Supabase
      if (_profileImage != null) {
        final fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
        await SupabaseConfig.client.storage
            .from("user_profiles")
            .upload(fileName, _profileImage!);
        imageUrl = SupabaseConfig.client.storage
            .from("user_profiles")
            .getPublicUrl(fileName);
      }

      // อัปเดตข้อมูลใน Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({
            "name": nameController.text.trim(),
            "phone": phoneController.text.trim(),
            "email": emailController.text.trim(),
            if (passwordController.text.isNotEmpty)
              "password": passwordController.text.trim(),
            "profileImage": imageUrl,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("อัปเดตโปรไฟล์เรียบร้อย ✅")));
      Navigator.pop(context, true); // ส่งค่ากลับไปให้ Profile reload ใหม่
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBD9F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // 🔹 รูปโปรไฟล์
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (currentProfileImage != null
                                    ? NetworkImage(currentProfileImage!)
                                    : null)
                                as ImageProvider?,
                      child:
                          _profileImage == null && currentProfileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "แตะเพื่อแก้ไขรูปโปรไฟล์",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _buildLabel("ชื่อ"),
                  _buildTextField(nameController),

                  _buildLabel("เบอร์โทร"),
                  _buildTextField(
                    phoneController,
                    keyboard: TextInputType.phone,
                  ),

                  _buildLabel("อีเมล"),
                  _buildTextField(
                    emailController,
                    keyboard: TextInputType.emailAddress,
                  ),

                  _buildLabel("รหัสผ่านใหม่ (ถ้ามี)"),
                  _buildTextField(passwordController, obscure: true),

                  _buildLabel("ยืนยันรหัสผ่าน"),
                  _buildTextField(confirmPasswordController, obscure: true),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: const Text(
                        "ยืนยันการแก้ไขโปรไฟล์",
                        style: TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 6, top: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool obscure = false,
    TextInputType? keyboard,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
