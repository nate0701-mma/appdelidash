import 'dart:io';
import 'package:delidash/page/riderpage/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/supabase_config.dart';
import 'package:delidash/page/loginpage.dart';
import 'package:image_picker/image_picker.dart';

class RegisterRiderPage extends StatefulWidget {
  const RegisterRiderPage({super.key});

  @override
  State<RegisterRiderPage> createState() => _RegisterRiderPageState();
}

class _RegisterRiderPageState extends State<RegisterRiderPage> {
  File? _profileImage;
  String? _vehicleImageUrl;
  bool _isVehicleUploaded = false;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController vehiclePlateController = TextEditingController();

  // เลือกรูปโปรไฟล์
  Future<void> _pickProfileImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  // ไปหน้า UploadVehiclePage เพื่อเลือกรูปยานพาหนะ
  Future<void> _pickVehicleImage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadVehiclePage()),
    );

    if (result != null && result is String) {
      setState(() {
        _vehicleImageUrl = result;
        _isVehicleUploaded = true;
      });
    }
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5),
            child: Text(
              label,
              style: GoogleFonts.notoSansThai(
                textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
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

  // ฟังก์ชันสมัครไรเดอร์ (เวอร์ชันตรวจสอบว่าต้องมี user ก่อน)
  void _registerRider() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        vehiclePlateController.text.isEmpty ||
        !_isVehicleUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกข้อมูลให้ครบทุกช่องและอัปโหลดรูปยานพาหนะ"),
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")));
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // ✅ ตรวจสอบว่ามี user ที่ใช้เบอร์นี้อยู่หรือยัง
      final existingUser = await firestore
          .collection('users')
          .where('phone', isEqualTo: phoneController.text.trim())
          .get();

      if (existingUser.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ต้องสมัครเป็นผู้ใช้ระบบ (User) ก่อน")),
        );
        return;
      }

      // ✅ ตรวจสอบว่ามี rider เบอร์นี้อยู่แล้วไหม
      final existingRider = await firestore
          .collection('riders')
          .where('phone', isEqualTo: phoneController.text.trim())
          .get();

      if (existingRider.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เบอร์นี้สมัครเป็นไรเดอร์แล้ว")),
        );
        return;
      }

      String? profileImageUrl;

      // ✅ Upload รูปโปรไฟล์ไป Supabase
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        final fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

        await SupabaseConfig.client.storage
            .from("rider_profiles")
            .uploadBinary(fileName, bytes);

        profileImageUrl = SupabaseConfig.client.storage
            .from("rider_profiles")
            .getPublicUrl(fileName);
      }

      // ✅ เก็บข้อมูล Rider ลง Firestore
      final data = {
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "vehiclePlate": vehiclePlateController.text.trim(),
        "profileImage": profileImageUrl,
        "vehicleImage": _vehicleImageUrl,
        "createdAt": DateTime.now(),
      };

      await firestore.collection("riders").add(data);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("สำเร็จ"),
          content: const Text("สมัครไรเดอร์สำเร็จ!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Loginpage()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      appBar: AppBar(
        backgroundColor: Colors.purple[800],
        elevation: 0,
        title: Text(
          "สมัครไรเดอร์",
          style: GoogleFonts.notoSansThai(
            textStyle: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ---------------- รูปโปรไฟล์ ----------------
              GestureDetector(
                onTap: _pickProfileImage,
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
              const SizedBox(height: 15),

              _buildTextField("ชื่อ", "กรอกชื่อ", nameController),
              const SizedBox(height: 15),
              _buildTextField(
                "เบอร์โทร",
                "กรอกเบอร์โทร",
                phoneController,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "อีเมล",
                "กรอกอีเมล",
                emailController,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "รหัสผ่าน",
                "กรอกรหัสผ่าน",
                passwordController,
                obscure: true,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "ยืนยันรหัสผ่าน",
                "กรอกยืนยันรหัสผ่าน",
                confirmPasswordController,
                obscure: true,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "ทะเบียนรถ",
                "กรอกทะเบียนรถ",
                vehiclePlateController,
              ),
              const SizedBox(height: 15),

              // ---------------- ปุ่มอัปโหลดยานพาหนะ ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _pickVehicleImage,
                    icon: Icon(
                      _isVehicleUploaded
                          ? Icons.check_circle
                          : Icons.cloud_upload,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isVehicleUploaded
                          ? "อัปโหลดเรียบร้อย"
                          : "อัปโหลดรูปยานพาหนะ",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- ปุ่มสมัคร ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _registerRider,
                    child: Text(
                      "สมัครไรเดอร์",
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
