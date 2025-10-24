import 'package:delidash/page/riderpage/deliverystatuspage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart'; // ✅ ใช้สำหรับ LatLng
// ✅ import หน้าสเตตัส

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailPage({super.key, required this.order});

  // 🔹 ฟังก์ชันอัปเดต Firestore แล้วไปหน้า DeliveryStatusPage
  Future<void> acceptOrder(BuildContext context) async {
    try {
      final orderId = order['orderId'];
      final riderId = order['riderId'];
      if (orderId == null || riderId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ไม่พบข้อมูลออเดอร์หรือไรเดอร์")),
        );
        return;
      }

      // ✅ อัปเดตสถานะใน Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
            'status': 'ไรเดอร์รับงานแล้ว',
            'riderId': riderId,
            'acceptedAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("รับงานเรียบร้อย")));

      // ✅ ดึงค่าพิกัดจาก order (ต้องมีใน Firestore)
      final senderLatLng = LatLng(
        order['senderLat'] ?? 0.0,
        order['senderLng'] ?? 0.0,
      );
      final receiverLatLng = LatLng(
        order['receiverLat'] ?? 0.0,
        order['receiverLng'] ?? 0.0,
      );

      // ✅ ไปหน้า DeliveryStatusPage พร้อมส่งค่าพิกัด
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DeliveryStatusPage(
            orderId: orderId,
            riderId: riderId,
            senderLatLng: senderLatLng,
            receiverLatLng: receiverLatLng,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'รายละเอียดการรับงาน',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔸 Card แสดงสินค้า
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/iphone.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order['orderId'] ?? 'ไม่ระบุ'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order['productName'] ?? 'ไม่ระบุสินค้า',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order['senderAddress'] ?? 'ไม่ระบุจุดรับ'} → ${order['receiverAddress'] ?? 'ไม่ระบุจุดส่ง'}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔸 แผนที่ตัวอย่าง
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
                image: const DecorationImage(
                  image: AssetImage('assets/map_sample.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔸 Sender & Receiver Info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.send, color: Colors.black),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['senderAddress'] ?? 'ไม่ระบุที่อยู่ผู้ส่ง',
                            ),
                            Text('ชื่อผู้ส่ง: ${order['senderName'] ?? '-'}'),
                            Text('เบอร์โทร: ${order['senderPhone'] ?? '-'}'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.shopping_cart, color: Colors.black),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['receiverAddress'] ??
                                  'ไม่ระบุที่อยู่ผู้รับ',
                            ),
                            Text('ชื่อผู้รับ: ${order['receiverName'] ?? '-'}'),
                            Text('เบอร์โทร: ${order['receiverPhone'] ?? '-'}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔸 ปุ่ม “รับงาน” และ “ยกเลิก”
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => acceptOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 246, 246, 247),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('รับงาน'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 202, 26, 2),
                      ),
                    ),
                    child: const Text('ยกเลิก'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
