import 'package:flutter/material.dart';
import 'productdetailpage.dart';

class DeliveryStatusPage extends StatefulWidget {
  const DeliveryStatusPage({super.key});

  @override
  State<DeliveryStatusPage> createState() => _DeliveryStatusPageState();
}

class _DeliveryStatusPageState extends State<DeliveryStatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3e9fa),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'สถานะการจัดส่งสินค้า',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // แถบสถานะ (ไอคอน 4 อัน)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.event_note, color: Colors.black54),
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  Icon(Icons.local_shipping, color: Colors.black54),
                  Icon(Icons.home, color: Colors.black54),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // แผนที่จำลอง
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/map_placeholder.png', // แทนรูปแผนที่
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // ปุ่มอัปโหลดภาพ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoSection('ภาพขณะรับสินค้า'),
                _buildPhotoSection('ภาพขณะส่งเสร็จสิ้น'),
              ],
            ),

            const SizedBox(height: 20),

            // กล่องข้อมูลผู้ส่ง-ผู้รับ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 ผู้ส่งสินค้า',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('ชื่อผู้ส่ง: Nate'),
                  Text('เบอร์โทร: 0869999999'),
                  SizedBox(height: 12),
                  Text(
                    '🛒 ผู้รับสินค้า',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('ชื่อผู้รับ: Tangkwa'),
                  Text('เบอร์โทร: 0645555555'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ปุ่มข้อมูลสินค้า
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductDetailPage()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Text('ข้อมูลสินค้า'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.camera_alt, size: 32, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(label),
        const SizedBox(height: 4),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffe5d0f7),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {},
          child: const Text('ส่ง'),
        ),
      ],
    );
  }
}
