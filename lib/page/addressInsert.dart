import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InsertAddressPage extends StatefulWidget {
  final String userId;
  const InsertAddressPage({super.key, required this.userId});

  @override
  State<InsertAddressPage> createState() => _InsertAddressPageState();
}

class _InsertAddressPageState extends State<InsertAddressPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  Future<void> _addAddress() async {
    final addressText = _addressController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (addressText.isEmpty || lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('addresses').add({
        'userId': widget.userId,
        'address': addressText,
        'lat': lat,
        'lng': lng,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _addressController.clear();
      _latController.clear();
      _lngController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("เพิ่มที่อยู่สำเร็จ ✅")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF752296),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'เลือกที่อยู่ผู้ส่ง',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ เพิ่มที่อยู่ใหม่
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: "เพิ่มที่อยู่ใหม่",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _latController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "ละติจูด (Latitude)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lngController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "ลองจิจูด (Longitude)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addAddress,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text("บันทึกที่อยู่ใหม่"),
            ),
            const SizedBox(height: 16),

            // ✅ แสดงรายการที่อยู่จริง
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('addresses')
                    .where('userId', isEqualTo: widget.userId)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final addresses = snapshot.data!.docs;
                  if (addresses.isEmpty) {
                    return const Center(
                      child: Text(
                        "ยังไม่มีที่อยู่",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final data =
                          addresses[index].data() as Map<String, dynamic>;
                      final address = data['address'] ?? "ไม่มีข้อมูล";
                      final lat = data['lat'] ?? 0.0;
                      final lng = data['lng'] ?? 0.0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, {
                            "address": address,
                            "lat": lat,
                            "lng": lng,
                          }); // ✅ ส่งค่ากลับ
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Lat: $lat, Lng: $lng",
                                style: const TextStyle(color: Colors.grey),
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
