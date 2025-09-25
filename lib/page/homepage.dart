import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget {
  final String userId; // รับ userId จากหน้า Login
  const Homepage({super.key, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header: รูป + ชื่อ + ที่อยู่
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // รูปจาก Supabase (เก็บเป็น Public URL)
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
                  // ชื่อ + ที่อยู่
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
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // ✅ Section Orders (mock ไว้ก่อน)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Order",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // mock orders
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.purple,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.white),
                      title: Text(
                        "Order #${46546 + index}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        "date: 24/1/2002\nstatus: pending",
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        child: const Text("Detail"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
