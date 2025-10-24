import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../page/profileuser.dart'; // ✅ import หน้าโปรไฟล์ผู้ใช้

class Homepage extends StatefulWidget {
  final String userId; // รับ userId จากหน้า Login
  const Homepage({super.key, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> orders = [
    {"id": 1001, "date": "24/10/2025", "status": "pending"},
    {"id": 1002, "date": "23/10/2025", "status": "completed"},
    {"id": 1003, "date": "22/10/2025", "status": "in progress"},
    {"id": 1004, "date": "21/10/2025", "status": "cancelled"},
    {"id": 1005, "date": "20/10/2025", "status": "pending"},
    {"id": 1006, "date": "19/10/2025", "status": "completed"},
    {"id": 1007, "date": "18/10/2025", "status": "pending"},
    {"id": 1008, "date": "17/10/2025", "status": "completed"},
    {"id": 1009, "date": "16/10/2025", "status": "in progress"},
    {"id": 1010, "date": "15/10/2025", "status": "pending"},
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // ✅ ดึงข้อมูลผู้ใช้จาก Firestore
  void fetchUserData() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildHomeContent()),

      // ✅ แท็บล่าง (Bottom Navigation Bar)
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
            // 🔹 ปุ่ม Home
            IconButton(
              onPressed: () {
                setState(() => _selectedIndex = 0);
              },
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Colors.white : Colors.grey[400],
                size: 28,
              ),
            ),

            // 🔹 ปุ่ม Add
            IconButton(
              onPressed: () {
                setState(() => _selectedIndex = 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("ฟีเจอร์เพิ่มข้อมูลยังไม่เปิดใช้งาน"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: Icon(
                Icons.add,
                color: _selectedIndex == 1 ? Colors.white : Colors.grey[400],
                size: 30,
              ),
            ),

            // 🔹 ปุ่ม More → ไปหน้าโปรไฟล์ผู้ใช้
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileUserPage(),
                  ),
                );
              },
              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ หน้า Home หลัก
  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: รูป + ชื่อ + ที่อยู่
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: userData?["profileImage"] != null
                    ? NetworkImage(userData!["profileImage"])
                    : null,
                child: userData?["profileImage"] == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData?["name"] ?? "ไม่มีชื่อ",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userData?["address"] ?? "ไม่มีที่อยู่",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(),

        // Section Orders
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Orders", style: Theme.of(context).textTheme.titleLarge),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: Colors.purple,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.white),
                  title: Text(
                    "Order #${order['id']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "date: ${order['date']}\nstatus: ${order['status']}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "ดูรายละเอียดของ Order #${order['id']}",
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text("Detail"),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
