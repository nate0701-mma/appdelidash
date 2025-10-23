import 'package:flutter/material.dart';

class ShowwaitriderPage extends StatelessWidget {
  const ShowwaitriderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text('', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // แถบสถานะ
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

            // โปรไฟล์ไรเดอร์
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

            const SizedBox(height: 20),

            // ข้อความสถานะ
            const Text(
              'รอไรเดอร์เข้ารับงาน',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 12),

            // กล่องแผนที่ (จำลอง)
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

            // ช่อง “ไรเดอร์รับของแล้ว” และ “ส่งเสร็จสิ้น”
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
