import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Fritspage extends StatefulWidget {
  const Fritspage({super.key});

  @override
  State<Fritspage> createState() => _FritspageState();
}

class _FritspageState extends State<Fritspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF6B09A3), // พื้นหลังม่วง
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 150), // ⭐ ระยะห่างจากขอบบน
            // โลโก้ชื่อแอป
            Text(
              "DELIDASH",
              style: GoogleFonts.rubikGlitch(
                textStyle: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),

            const Spacer(), // ⭐ ดันกล่องลงไปล่าง
            // กล่องสีขาวมีเงา
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ), // ⭐ เว้นจากขอบล่าง
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ไอคอนรถ
                  Image.asset(
                    'assets/image/logo.png',
                    height: 200, // ⭐ ปรับความสูง
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),

                  // ปุ่มเข้าสู่ระบบ
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65176C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "เข้าสู่ระบบ",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ปุ่มสมัครสมาชิก
                  ElevatedButton(
                    onPressed: () {},
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
          ],
        ),
      ),
    );
  }
}
