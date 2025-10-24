import 'package:flutter/material.dart';
import '../page/address.dart';
import '../page/edit_profile.dart'; // ✅ import หน้าสำหรับแก้ไขโปรไฟล์

class ProfileUserPage extends StatelessWidget {
  const ProfileUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('โปรไฟล์ผู้ใช้'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 รูปโปรไฟล์และข้อมูลผู้ใช้
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ชื่อ: โอกาโน่ ใจดีครับ',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'เบอร์โทร: 0991234567',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ที่อยู่: ห้องพักลานฟิน้อง',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 ปุ่ม "แก้ไขโปรไฟล์"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'แก้ไขโปรไฟล์',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: () {
                  // ✅ ไปหน้า EditProfilePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 ปุ่ม "ที่อยู่"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // ✅ ไปหน้า AddressPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressPage(),
                    ),
                  );
                },
                child: const Text('ที่อยู่', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 ปุ่ม "ออกจากระบบ"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // TODO: เพิ่ม action ออกจากระบบภายหลัง
                },
                child: const Text(
                  'ออกจากระบบ',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.purple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.purple[100],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''),
        ],
      ),
    );
  }
}
