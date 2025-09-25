import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
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
                        obscureText: true,
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
                      onPressed: () {},
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
                            color: Color.fromARGB(255, 255, 255, 255),
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
