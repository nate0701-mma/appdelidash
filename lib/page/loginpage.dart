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

  void loginUser() async {
    try {
      var db = FirebaseFirestore.instance;

      // 🔎 ตรวจสอบ collection users
      final userSnapshot = await db
          .collection("users")
          .where("email", isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final doc = userSnapshot.docs.first;
        final data = doc.data();
        final userId = doc.id;

        if (data["password"] == passwordController.text.trim()) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage(userId: userId)),
          );
          return;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("รหัสผ่านไม่ถูกต้อง ❌")));
          return;
        }
      }

      // 🔎 ตรวจสอบ collection riders
      final riderSnapshot = await db
          .collection("riders")
          .where("email", isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (riderSnapshot.docs.isNotEmpty) {
        final doc = riderSnapshot.docs.first;
        final data = doc.data();
        final riderId = doc.id;

        if (data["password"] == passwordController.text.trim()) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WorkRiderPage(riderId: riderId),
            ),
          );
          return;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("รหัสผ่านไม่ถูกต้อง ❌")));
          return;
        }
      }

      // ❌ ไม่พบผู้ใช้งาน
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ไม่พบผู้ใช้งาน ❌")));
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
                const SizedBox(height: 10),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'อีเมล',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          color: Color(0xFF65176C),
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "ป้อนอีเมล",
                          labelStyle: const TextStyle(color: Color(0xFFADADAD)),
                          filled: true,
                          fillColor: const Color(0xFFCAC4D0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'รหัสผ่าน',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          color: Color(0xFF65176C),
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "ป้อนรหัสผ่าน",
                          labelStyle: const TextStyle(color: Color(0xFFADADAD)),
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
                      ),
                      child: Text(
                        "เข้าสู่ระบบ",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                      ),
                      child: Text(
                        "สมัครสมาชิก",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 18,
                          color: Colors.white,
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
