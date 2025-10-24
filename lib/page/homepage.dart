import 'package:delidash/page/addorder.dart';
import 'package:delidash/page/receiver_order_page.dart';
import 'package:delidash/page/shipment_map_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../page/profileuser.dart';
import '../page/showwaitrider.dart';

class Homepage extends StatefulWidget {
  final String userId;
  const Homepage({super.key, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int _selectedIndex = 0;

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

      // ✅ แถบล่าง
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
              onPressed: () => setState(() => _selectedIndex = 0),
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Colors.white : Colors.grey[400],
                size: 28,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => _selectedIndex = 1);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddOrderPage(userId: widget.userId),
                  ),
                );
              },
              icon: Icon(
                Icons.add,
                color: _selectedIndex == 1 ? Colors.white : Colors.grey[400],
                size: 30,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileUserPage(userId: widget.userId),
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

  // ✅ หน้า Home แสดงข้อมูล order ของผู้ใช้คนนั้นเท่านั้น
  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 ส่วนหัวผู้ใช้
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
                    userData?["phone"] ?? "ไม่มีเบอร์โทร",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text(
              "ดูแผนที่การจัดส่งทั้งหมด",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShipmentMapPage(userId: widget.userId),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            icon: const Icon(Icons.inventory_2, color: Colors.white),
            label: const Text(
              "ดูของที่ต้องรับทั้งหมด",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReceiverOrderPage(userId: widget.userId),
                ),
              );
            },
          ),
        ),

        const Divider(),

        // 🔹 หัวข้อ Orders
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "รายการส่งสินค้าของฉัน",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // ✅ StreamBuilder ดึง order ของผู้ใช้คนนั้นจาก Firestore
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('senderId', isEqualTo: widget.userId) // ✅ เฉพาะของตัวเอง
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("ยังไม่มีรายการส่งสินค้า"));
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order =
                      orders[index].data() as Map<String, dynamic>? ?? {};
                  final productName = order['productName'] ?? 'ไม่มีชื่อสินค้า';
                  final productDetail =
                      order['productDetail'] ?? 'ไม่มีรายละเอียด';
                  final status = order['status'] ?? 'ไม่ทราบสถานะ';
                  final receiver = order['receiverName'] ?? '-';
                  final receiverAddress = order['receiverAddress'] ?? '-';
                  final imageUrl = order['productImage'];

                  return Card(
                    color: Colors.purple,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowwaitriderPage(
                              orderId: orders[index].id, // ✅ ใช้ doc.id
                            ),
                          ),
                        );
                      },
                      leading: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.inventory, color: Colors.white),
                      title: Text(
                        productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "👤 $receiver\n📍 $receiverAddress\n📝 $productDetail\nสถานะ: $status",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
