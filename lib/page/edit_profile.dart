import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ✅ import image picker

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController(
    text: "โคคาไร โคคิมิจิ",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "0991234567",
  );
  final TextEditingController emailController = TextEditingController(
    text: "user@gmail.com",
  );
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  File? _profileImage; // ✅ ตัวแปรเก็บรูปโปรไฟล์ที่เลือก
  final ImagePicker _picker = ImagePicker();

  // 🔹 ฟังก์ชันเลือกรูปโปรไฟล์
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBD9F7), // สีม่วงอ่อนพื้นหลัง
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔹 รูปโปรไฟล์
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage, // ✅ กดเพื่อเลือกภาพ
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[700],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "แตะเพื่อแก้ไขรูปโปรไฟล์",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 ช่องกรอกข้อมูล
            _buildLabel("ชื่อ"),
            _buildTextField(nameController),

            _buildLabel("เบอร์โทร"),
            _buildTextField(phoneController, keyboard: TextInputType.phone),

            _buildLabel("อีเมล"),
            _buildTextField(
              emailController,
              keyboard: TextInputType.emailAddress,
            ),

            _buildLabel("รหัสผ่าน"),
            _buildTextField(passwordController, obscure: true),

            _buildLabel("ยืนยันรหัสผ่าน"),
            _buildTextField(confirmPasswordController, obscure: true),

            const SizedBox(height: 30),

            // 🔹 ปุ่มยืนยัน
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("แก้ไขโปรไฟล์เรียบร้อย")),
                  );
                },
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
