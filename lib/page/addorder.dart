import 'package:flutter/material.dart';

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
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // กล่องเลือกสินค้า
            Container(
              height: 120,
              color: const Color.fromARGB(255, 232, 225, 233),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: เพิ่มฟังก์ชันเลือกสินค้า
                  },
                  child: const Text(
                    'เลือกที่รับสินค้า',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // เบอร์ผู้รับ
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.purple[300],
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
                    // TODO: ค้นหาผู้รับ
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
                hintText: 'รายละเอียด',
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
