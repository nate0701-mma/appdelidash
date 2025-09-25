import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/supabase_config.dart';
import 'package:delidash/page/loginpage.dart';
import 'package:delidash/page/choseregister.dart';
import 'package:delidash/page/riderpage/image_picker.dart'; // หน้า UploadVehiclePage

class RegisterRiderPage extends StatefulWidget {
  const RegisterRiderPage({super.key});

  @override
  State<RegisterRiderPage> createState() => _RegisterRiderPageState();
}

class _RegisterRiderPageState extends State<RegisterRiderPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController vehiclePlateController = TextEditingController();

  bool _isVehicleUploaded = false;
  File? _vehicleImage;

  Future<void> _pickVehicleImage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UploadVehiclePage()),
    );

    if (result != null && result is File) {
      setState(() {
        _vehicleImage = result;
        _isVehicleUploaded = true;
      });
      print("เลือกไฟล์รูปเรียบร้อย: $_vehicleImage");
    } else {
      print("ยังไม่ได้เลือกไฟล์รูป");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      appBar: AppBar(
        backgroundColor: Colors.purple[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Choseregister()),
            );
          },
        ),
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickVehicleImage,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: Icon(
                      _isVehicleUploaded
                          ? Icons.check_circle
                          : Icons.cloud_upload,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                        style: GoogleFonts.notoSansThai(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
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
      ),
    );
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

  void _registerRider() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        vehiclePlateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบทุกช่อง")),
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
      String? vehicleImageUrl;

      if (_vehicleImage != null) {
        final bytes = await _vehicleImage!.readAsBytes();
        final fileName = "vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg";

        final response = await SupabaseConfig.client.storage
            .from("rider_vehicles")
            .uploadBinary(fileName, bytes);

        print("Upload response: $response");

        vehicleImageUrl = SupabaseConfig.client.storage
            .from("rider_vehicles")
            .getPublicUrl(fileName);
        print("URL รูป: $vehicleImageUrl");
      }

      final data = {
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "vehiclePlate": vehiclePlateController.text.trim(),
        "vehicleImage": vehicleImageUrl,
        "createdAt": DateTime.now(),
      };

      print("ข้อมูลที่จะส่งไป Firestore: $data");

      await FirebaseFirestore.instance.collection("riders").add(data);

      print("สมัครไรเดอร์เรียบร้อยแล้ว");

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
                  MaterialPageRoute(builder: (context) => const Loginpage()),
                );
              },
              child: const Text("ตกลง"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }
}
