import 'package:delidash/page/choseregister.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/page/riderpage/work_rider.dart';
import 'package:delidash/page/homepage.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ✅ ฟังก์ชัน login
  // ✅ ฟังก์ชัน login
  void loginUser() async {
    try {
      var db = FirebaseFirestore.instance;

      // 🔎 หา user ตาม email
      final snapshot = await db
          .collection("users")
          .where("email", isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("ไม่พบผู้ใช้งาน ❌")));
        return;
      }

      final doc = snapshot.docs.first; // ✅ ดึง document
      final userData = doc.data();
      final userId = doc.id; // ✅ เก็บ id ไว้ส่งไปหน้า Homepage

      // ✅ ตรวจสอบรหัสผ่าน
      if (userData["password"] == passwordController.text.trim()) {
        Navigator.popUntil(context, (route) => route.isFirst);

        // 👉 ถ้ามี address ให้ไป Homepage
        if (userData["address"] != null &&
            userData["address"].toString().isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Homepage(userId: userId), // ✅ ส่ง userId
            ),
          );
        } else {
          // 👉 ถ้าไม่มี address ไปหน้า WorkRider
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WorkRiderPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("รหัสผ่านไม่ถูกต้อง ❌")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Column(
                  children: [
                    Image.asset('assets/image/logo.png', height: 140),
                    Text(
                      'DELIDASH',
                      style: GoogleFonts.rubikGlitch(
                        textStyle: const TextStyle(
                          fontSize: 28,
                          color: Color(0xFF65176C),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  'เข้าสู่ระบบ',
                  style: GoogleFonts.notoSansThai(
                    textStyle: const TextStyle(
                      fontSize: 48,
                      color: Color(0xFF65176C),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Email TextField
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
                              color: Color(0xFF65176C),
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "ป้อนอีเมล",
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 173, 173, 173),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFCAC4D0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Password TextField
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
                              color: Color(0xFF65176C),
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "ป้อนรหัสผ่าน",
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 173, 173, 173),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFCAC4D0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Login Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF65176C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 3,
                      ),
                      child: Text(
                        "เข้าสู่ระบบ",
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

                // Register Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 3,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
