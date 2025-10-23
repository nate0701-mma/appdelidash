import 'package:flutter/material.dart';
import '../page/addressInsert.dart'; // ✅ import หน้าเลือกที่อยู่

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({Key? key}) : super(key: key);

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  String recipientName = "ชื่อ ใส่ได้นี่ โลคัส"; // ตัวอย่างชื่อผู้รับ
  String recipientInfo = "อยู่ที่: ตัวอย่างที่อยู่"; // ตัวอย่างที่อยู่

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 78, 6, 109),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('ส่งสินค้า', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // กลับหน้าก่อนหน้า
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ ปุ่มเลือกที่อยู่รับสินค้า
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 232, 225, 233),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // ✅ ไปหน้า InsertAddressPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsertAddressPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'เลือกที่อยู่รับสินค้า',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ช่องค้นหาผู้รับ
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 245, 219, 250),
                      hintText: 'ค้นหาผู้รับ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: ฟังก์ชันค้นหาผู้รับ
                  },
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // แสดงชื่อผู้รับ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(width: 8),
                      Text('ผู้รับ', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$recipientName\n$recipientInfo',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ช่องภาพสินค้า
            Container(
              height: 200,
              color: Colors.purple[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, size: 50, color: Colors.white),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: ฟังก์ชันถ่ายภาพ
                      },
                      child: const Text('ถ่ายภาพ'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ช่องรายละเอียดสินค้า
            TextField(
              controller: _detailController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.purple[300],
                hintText: 'รายละเอียดสินค้า',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ปุ่มส่งสินค้า
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[900],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // TODO: ฟังก์ชันส่งสินค้า
                },
                child: const Text('ส่งสินค้า'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
