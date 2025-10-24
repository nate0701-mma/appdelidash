import 'package:flutter/material.dart';

class ShowwaitriderPage extends StatelessWidget {
  final Map<String, dynamic> order; // ✅ รับข้อมูล order

  const ShowwaitriderPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'รายละเอียดการจัดส่ง',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ แถบสถานะ
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.assignment, color: Colors.black),
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  Icon(Icons.motorcycle, color: Colors.black),
                  Icon(Icons.home, color: Colors.black),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ แสดงข้อมูลสินค้า
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📦 สินค้า: ${order['productName'] ?? '-'}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "รายละเอียด: ${order['productDetail'] ?? '-'}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "ผู้รับ: ${order['receiverName'] ?? '-'}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "ที่อยู่ผู้รับ: ${order['receiverAddress'] ?? '-'}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "สถานะ: ${order['status'] ?? '-'}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ โปรไฟล์ไรเดอร์ (ตอนนี้ mock ไว้ก่อน)
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.purple, size: 35),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ไรเดอร์: โกศล โค้กเงินดี',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'เบอร์โทร: 091234567',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'หมายเลขรถ: บข9999',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/map_placeholder.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusBox('ไรเดอร์รับของแล้ว'),
                _buildStatusBox('ส่งเสร็จสิ้น'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBox(String label) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
