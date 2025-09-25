import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delidash/page/riderpage/work_rider.dart';
import 'package:delidash/page/riderpage/image_picker.dart';

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

  bool _isVehicleUploaded = false; // ✅ เก็บสถานะอัปโหลดยานพาหนะ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Upload Profile
                GestureDetector(
                  onTap: () {
                    // TODO: ทำให้กดอัปโหลดรูปโปรไฟล์ได้เหมือน Registeruser
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(
                      Icons.cloud_upload,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "สมัครไรเดอร์",
                  style: GoogleFonts.notoSansThai(
                    textStyle: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ช่องกรอกข้อมูล
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

                // ปุ่มอัปโหลดรูปยานพาหนะ
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
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UploadVehiclePage(),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            _isVehicleUploaded = true;
                          });
                        }
                      },
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

                // ปุ่มสมัครไรเดอร์
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
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkRiderPage(),
                          ),
                          (route) => false,
                        );
                      },
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
}
