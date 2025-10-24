import 'package:delidash/page/riderpage/deliverystatuspage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String thunderforestApiKey = "b21c118534bb44cebc91a85e81999b28";

  const OrderDetailPage({super.key, required this.order});

  // ✅ ฟังก์ชันอัปเดต Firestore แล้วไปหน้า DeliveryStatusPage
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
      ).showSnackBar(const SnackBar(content: Text("✅ รับงานเรียบร้อย")));

      final senderLatLng = LatLng(
        order['senderLat'] ?? 0.0,
        order['senderLng'] ?? 0.0,
      );
      final receiverLatLng = LatLng(
        order['receiverLat'] ?? 0.0,
        order['receiverLng'] ?? 0.0,
      );

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
    final productImage = order['productImage'];
    final senderLat = double.tryParse(order['senderLat']?.toString() ?? '');
    final senderLng = double.tryParse(order['senderLng']?.toString() ?? '');
    final receiverLat = double.tryParse(order['receiverLat']?.toString() ?? '');
    final receiverLng = double.tryParse(order['receiverLng']?.toString() ?? '');

    final senderLatLng = (senderLat != null && senderLng != null)
        ? LatLng(senderLat, senderLng)
        : null;
    final receiverLatLng = (receiverLat != null && receiverLng != null)
        ? LatLng(receiverLat, receiverLng)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            // 🔸 แสดงภาพสินค้า (จาก Firestore)
            if (productImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  productImage,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.image_not_supported, size: 60),
              ),
            const SizedBox(height: 16),

            // 🔸 รายละเอียดสินค้า
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.inventory, color: Colors.purple, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'สินค้า: ${order['productName'] ?? '-'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('รายละเอียด: ${order['productDetail'] ?? '-'}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔸 แผนที่จริง (Thunderforest)
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: senderLatLng == null
                  ? const Center(child: Text("ไม่มีข้อมูลพิกัดผู้ส่ง"))
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: receiverLatLng ?? senderLatLng,
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.thunderforest.com/neighbourhood/{z}/{x}/{y}.png?apikey=$thunderforestApiKey",
                          userAgentPackageName: 'com.example.deliveryapp',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: senderLatLng,
                              width: 80,
                              height: 80,
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.store,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  Text(
                                    "ผู้ส่ง",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (receiverLatLng != null)
                              Marker(
                                point: receiverLatLng,
                                width: 80,
                                height: 80,
                                child: Column(
                                  children: const [
                                    Icon(
                                      Icons.home,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                    Text(
                                      "ผู้รับ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // 🔸 ข้อมูลผู้ส่ง & ผู้รับ
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.store, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("จุดรับ: ${order['senderAddress'] ?? '-'}"),
                              Text("ชื่อผู้ส่ง: ${order['senderName'] ?? '-'}"),
                              Text("เบอร์โทร: ${order['senderPhone'] ?? '-'}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.home, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "จุดส่ง: ${order['receiverAddress'] ?? '-'}",
                              ),
                              Text(
                                "ชื่อผู้รับ: ${order['receiverName'] ?? '-'}",
                              ),
                              Text(
                                "เบอร์โทร: ${order['receiverPhone'] ?? '-'}",
                              ),
                            ],
                          ),
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
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'รับงาน',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
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
