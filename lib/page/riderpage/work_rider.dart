import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../riderpage/profile_rider.dart';
import '../riderpage/orderdetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkRiderPage extends StatefulWidget {
  final String riderId;
  const WorkRiderPage({super.key, required this.riderId});

  @override
  State<WorkRiderPage> createState() => _WorkRiderPageState();
}

class _WorkRiderPageState extends State<WorkRiderPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? riderData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // 🔹 ดึงข้อมูลไรเดอร์จาก Firestore
  void fetchUserData() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("riders")
          .doc(widget.riderId)
          .get();

      if (doc.exists) {
        setState(() {
          riderData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching rider data: $e");
    }
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildWorkPage(),
          ProfileRiderPage(riderId: widget.riderId),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedIndex == 0
                    ? const Color(0xFF6B4C8D)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Colors.white : Colors.grey,
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedIndex == 1
                    ? const Color(0xFF6B4C8D)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.more_horiz,
                color: _selectedIndex == 1 ? Colors.white : Colors.grey,
              ),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // 🔹 หน้าแสดงออร์เดอร์ทั้งหมดจาก Firestore
  Widget _buildWorkPage() {
    return Container(
      color: const Color(0xFFF0EAF7),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Rider Info
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Container(
                width: double.infinity,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: riderData?["profileImage"] != null
                          ? NetworkImage(riderData!["profileImage"])
                          : null,
                      child: riderData?["profileImage"] == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Text(
                          "ไรเดอร์ : ",
                          style: GoogleFonts.notoSansThai(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          riderData?["name"] ?? "ไม่มีชื่อ",
                          style: GoogleFonts.notoSansThai(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // หัวข้อ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'สินค้าที่ต้องส่ง',
                style: GoogleFonts.notoSansThai(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ ดึงจาก Firestore (orders)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where(
                      'status',
                      isEqualTo: 'รอจัดส่ง',
                    ) // เฉพาะที่ยังไม่ถูกไรเดอร์รับ
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("ยังไม่มีงานให้รับในขณะนี้"),
                    );
                  }

                  final orders = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order =
                          orders[index].data() as Map<String, dynamic>;
                      final productName =
                          order['productName'] ?? 'ไม่ระบุสินค้า';
                      final productDetail = order['productDetail'] ?? '';
                      final receiver = order['receiverName'] ?? '';
                      final receiverAddress = order['receiverAddress'] ?? '';
                      final imageUrl = order['productImage'];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[300],
                                  image: imageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: imageUrl == null
                                    ? const Icon(
                                        Icons.inventory,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: GoogleFonts.notoSansThai(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'ไปยัง: $receiverAddress',
                                      style: GoogleFonts.notoSansThai(
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6B4C8D,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        minimumSize: const Size(100, 40),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OrderDetailPage(
                                              order: {
                                                ...order,
                                                'orderId': orders[index].id,
                                                'riderId': widget
                                                    .riderId, // ✅ ส่งค่าไอดีไรเดอร์มาด้วย
                                              },
                                            ),
                                          ),
                                        );
                                      },

                                      child: Text(
                                        'รับงาน',
                                        style: GoogleFonts.notoSansThai(
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
