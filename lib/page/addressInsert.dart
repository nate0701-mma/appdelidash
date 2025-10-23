import 'package:flutter/material.dart';
import 'profileuser.dart'; // import หน้าโปรไฟล์ผู้ใช้ของคุณ

class InsertAddressPage extends StatefulWidget {
  const InsertAddressPage({super.key});

  @override
  State<InsertAddressPage> createState() => _InsertAddressPageState();
}

class _InsertAddressPageState extends State<InsertAddressPage> {
  // ตัวอย่างข้อมูลที่อยู่
  final List<String> addresses = ['ที่อยู่ที่1', 'ที่อยู่ที่2', 'ที่อยู่ที่3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'เลือกที่อยู่รับของ',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () {
            // กลับไปหน้าโปรไฟล์ผู้ใช้
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileUserPage()),
            );
          },
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 117, 34, 150),
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 232, 214, 235),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                addresses[index],
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            );
          },
        ),
      ),
    );
  }
}
