import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/page/Fritspage.dart';
import 'package:delidash/page/riderpage/editprofilerider.dart';

class ProfileRiderPage extends StatefulWidget {
  final String riderId; // รับค่า riderId จากหน้า WorkRiderPage
  const ProfileRiderPage({super.key, required this.riderId});

  @override
  State<ProfileRiderPage> createState() => _ProfileRiderPageState();
}

class _ProfileRiderPageState extends State<ProfileRiderPage> {
  Map<String, dynamic>? riderData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiderData();
  }

  // ✅ ดึงข้อมูลจาก Firestore
  Future<void> fetchRiderData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('riders')
          .doc(widget.riderId)
          .get();

      if (doc.exists) {
        setState(() {
          riderData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching rider data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE6E0F0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6E0F0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFE6E0F0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --------------------
              // ส่วนหัวโปรไฟล์
              // --------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFDABEFF),
                      backgroundImage: riderData?['profileImage'] != null
                          ? NetworkImage(riderData!['profileImage'])
                          : null,
                      child: riderData?['profileImage'] == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชื่อ: ${riderData?['name'] ?? 'ไม่ระบุ'}',
                          style: GoogleFonts.notoSansThai(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'เบอร์โทร: ${riderData?['phone'] ?? '-'}',
                          style: GoogleFonts.notoSansThai(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ทะเบียนรถ: ${riderData?['vehiclePlate'] ?? '-'}',
                          style: GoogleFonts.notoSansThai(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --------------------
              // ส่วนยานพาหนะ
              // --------------------
              Column(
                children: [
                  const Text(
                    'ยานพาหนะ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: riderData?['vehicleImage'] != null
                        ? Image.network(
                            riderData!['vehicleImage'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/car.png',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --------------------
              // ปุ่มแก้ไขโปรไฟล์
              // --------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE9FFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileRiderPage(),
                        ),
                      );
                    },
                    child: Text(
                      'แก้ไขโปรไฟล์',
                      style: GoogleFonts.notoSansThai(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --------------------
              // ปุ่มออกจากระบบ
              // --------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Fritspage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'ออกจากระบบ',
                      style: GoogleFonts.notoSansThai(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
