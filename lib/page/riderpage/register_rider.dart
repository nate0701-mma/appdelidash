import 'package:flutter/material.dart';
import 'package:delidash/page/riderpage/work_rider.dart';
import 'package:delidash/page/riderpage/image_picker.dart'; // import หน้า image_picker

class RegisterRiderPage extends StatefulWidget {
  const RegisterRiderPage({super.key});

  @override
  State<RegisterRiderPage> createState() => _RegisterRiderPageState();
}

class _RegisterRiderPageState extends State<RegisterRiderPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController vehiclePlateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 108, 10, 150),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // กลับหน้าก่อนหน้า
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.purple[300],
                child: const Icon(
                  Icons.cloud_upload,
                  size: 50,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "สมัครไรเดอร์",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField("ชื่อ", "กรอกชื่อ", nameController),
              _buildTextField(
                "เบอร์โทร",
                "กรอกเบอร์โทร",
                phoneController,
                keyboard: TextInputType.phone,
              ),
              _buildTextField(
                "รหัสผ่าน",
                "กรอกรหัสผ่าน",
                passwordController,
                obscure: true,
              ),
              _buildTextField(
                "ยืนยันรหัสผ่าน",
                "กรอกยืนยันรหัสผ่าน",
                confirmPasswordController,
                obscure: true,
              ),
              _buildTextField(
                "ทะเบียนรถ",
                "กรอกทะเบียนรถ",
                vehiclePlateController,
              ),
              const SizedBox(height: 20),

              // ปุ่มอัปโหลดรูปยานพาหนะ
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // ไปหน้า image_picker.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadVehiclePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text("อัปโหลดรูปยานพาหนะ"),
              ),
              const SizedBox(height: 15),

              // ปุ่มสมัครไรเดอร์
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                  foregroundColor: const Color.fromARGB(255, 248, 247, 247),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // ไปหน้า WorkRiderPage และลบหน้าก่อนหน้าออก
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkRiderPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "สมัครไรเดอร์",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
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
