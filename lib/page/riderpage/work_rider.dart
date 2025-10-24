import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_rider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkRiderPage extends StatefulWidget {
  final String riderId; // รับ userId จากหน้า Login
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

  // ✅ ดึงข้อมูลผู้ใช้จาก Firestore
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
      debugPrint("Error fetching user data: $e");
    }
  }

  final List<Map<String, String>> orders = [
    {
      'order': '#0056',
      'product': 'IPHONE 17',
      'detail': 'เสริมไทย — ฑิฆัมพร2',
      'image': 'assets/iphone17.png',
    },
    {
      'order': '#0057',
      'product': 'IPHONE 16',
      'detail': 'เสริมไทย — คณะIT มมส.ใหม่',
      'image': 'assets/iphone16.png',
    },
    {
      'order': '#0058',
      'product': 'IPHONE 15',
      'detail': 'เสริมไทย — หอพัก the best',
      'image': 'assets/iphone15.png',
    },
  ];

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

      // ✅ BottomNavigationBar
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

  // ------------------------
  // หน้า Work (ออร์เดอร์)
  // ------------------------
  Widget _buildWorkPage() {
    return Container(
      color: const Color(0xFFF0EAF7),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  borderRadius: BorderRadius.circular(0),
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
                      radius: 35,
                      backgroundImage: riderData?["profileImage"] != null
                          ? NetworkImage(riderData!["profileImage"])
                          : null,
                      child: riderData?["profileImage"] == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Text(
                          "ไรเดอร์ :",
                          style: GoogleFonts.notoSansThai(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          riderData?["name"] ?? "ไม่มีชื่อ",
                          style: GoogleFonts.notoSansThai(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ส่วนหัวรายการ
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

            // รายการออร์เดอร์
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
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
                              image: DecorationImage(
                                image: AssetImage(order['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ${order['order']}',
                                  style: GoogleFonts.notoSansThai(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  order['product']!,
                                  style: GoogleFonts.notoSansThai(
                                    textStyle: const TextStyle(fontSize: 14),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order['detail']!,
                                  style: GoogleFonts.notoSansThai(
                                    textStyle: const TextStyle(fontSize: 12),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B4C8D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: const Size(100, 40),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: () {
                                    // logic รับงาน
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
