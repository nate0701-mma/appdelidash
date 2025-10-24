import 'package:delidash/page/ReceiverShipmentMapPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/page/showwaitrider.dart';
import 'package:delidash/page/shipment_map_page.dart';

class ReceiverOrderPage extends StatelessWidget {
  final String userId;
  const ReceiverOrderPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "ของที่ฉันต้องรับทั้งหมด",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            tooltip: "ดูพิกัดทั้งหมด",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReceiverShipmentMapPage(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('receiverId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ยังไม่มีของที่ต้องรับ"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final imageUrl = order['productImage'];
              final productName = order['productName'] ?? 'ไม่มีชื่อสินค้า';
              final productDetail = order['productDetail'] ?? 'ไม่มีรายละเอียด';
              final status = order['status'] ?? 'ไม่ทราบสถานะ';
              final sender = order['senderName'] ?? '-';
              final senderPhone = order['senderPhone'] ?? '-';
              final receiverAddress = order['receiverAddress'] ?? '-';

              return Card(
                color: Colors.green[600],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ShowwaitriderPage(orderId: orders[index].id),
                      ),
                    );
                  },
                  leading: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.inventory,
                          color: Colors.white,
                          size: 40,
                        ),
                  title: Text(
                    productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "รายละเอียด: $productDetail\n"
                    "👤 ผู้ส่ง: $sender\n"
                    "📞 เบอร์โทร: $senderPhone\n"
                    "🏠 ที่อยู่จัดส่ง: $receiverAddress\n"
                    "สถานะ: $status",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
