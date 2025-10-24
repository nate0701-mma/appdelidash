import 'package:flutter/material.dart';
import '../page/address.dart';
import '../page/edit_profile.dart';
import '../page/fritspage.dart';
import '../page/homepage.dart';

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({super.key});

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  int _selectedIndex = 2; // ปุ่ม More คือหน้าโปรไฟล์

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // ไปหน้า Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Homepage(userId: ''),
          ), // ส่งค่า dummy
        );
        break;
      case 1:
        // Add
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ฟีเจอร์เพิ่มข้อมูลยังไม่เปิดใช้งาน"),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 2:
        // Already on Profile, ไม่มี action
        break;
    }
  }

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
            // รูปโปรไฟล์และข้อมูลผู้ใช้
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

            // ปุ่มแก้ไขโปรไฟล์
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

            // ปุ่มที่อยู่
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

            // ปุ่มออกจากระบบ
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
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('ออกจากระบบ'),
                      content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ยกเลิก'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Fritspage(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'ออกจากระบบ',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
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

      // Bottom Bar แบบ navigation
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD1A3FF), Color(0xFF5E17EB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => _onItemTapped(0),
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Colors.white : Colors.grey[400],
                size: 28,
              ),
            ),
            IconButton(
              onPressed: () => _onItemTapped(1),
              icon: Icon(
                Icons.add,
                color: _selectedIndex == 1 ? Colors.white : Colors.grey[400],
                size: 30,
              ),
            ),
            IconButton(
              onPressed: () => _onItemTapped(2),
              icon: Icon(
                Icons.more_horiz,
                color: _selectedIndex == 2 ? Colors.white : Colors.grey[400],
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
