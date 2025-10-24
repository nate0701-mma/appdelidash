import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/page/addorder.dart';
import 'package:flutter/material.dart';
import '../page/address.dart';
import '../page/edit_profile.dart';
import '../page/fritspage.dart';
import '../page/homepage.dart';

class ProfileUserPage extends StatefulWidget {
  final String userId; // รับ userId จากหน้า Login
  const ProfileUserPage({super.key, required this.userId});

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  int _selectedIndex = 2;

  // ✅ ตัวแปรเก็บข้อมูลผู้ใช้
  String userName = "";
  String userPhone = "";
  String profileImageUrl = "";
  String addressText = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// ✅ โหลดข้อมูลจาก Firestore
  Future<void> _loadUserData() async {
    try {
      // ดึงข้อมูล user จาก collection "users"
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        userName = data['name'] ?? '';
        userPhone = data['phone'] ?? '';
        profileImageUrl = data['profileImage'] ?? '';
      }

      // ดึงที่อยู่ล่าสุดจาก collection "addresses"
      QuerySnapshot addressSnap = await FirebaseFirestore.instance
          .collection('addresses')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (addressSnap.docs.isNotEmpty) {
        var addr = addressSnap.docs.first.data() as Map<String, dynamic>;
        addressText = addr['address'] ?? '';
      } else {
        addressText = "ยังไม่มีที่อยู่";
      }
    } catch (e) {
      debugPrint("โหลดข้อมูลผิดพลาด: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }

    setState(() => isLoading = false);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(userId: widget.userId),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddOrderPage(userId: widget.userId),
          ),
        );
        break;
      case 2:
        // stay on profile
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ชื่อ: $userName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'เบอร์โทร: $userPhone',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ที่อยู่: $addressText',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
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
                            builder: (context) =>
                                EditProfilePage(userId: widget.userId),
                          ),
                        ).then((_) => _loadUserData()); // โหลดใหม่หลังแก้
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
                            builder: (context) =>
                                AddressPage(userId: widget.userId),
                          ),
                        );
                      },
                      child: const Text(
                        'ที่อยู่',
                        style: TextStyle(fontSize: 16),
                      ),
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

      // 🔽 Bottom Navigation
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
