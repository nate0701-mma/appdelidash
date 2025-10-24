import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ShowwaitriderPage extends StatefulWidget {
  final String orderId;
  const ShowwaitriderPage({super.key, required this.orderId});

  @override
  State<ShowwaitriderPage> createState() => _ShowwaitriderPageState();
}

class _ShowwaitriderPageState extends State<ShowwaitriderPage> {
  Map<String, dynamic>? order;
  final String thunderforestApiKey = "b21c118534bb44cebc91a85e81999b28";

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (orderDoc.exists) {
        setState(() => order = orderDoc.data());
      }
    } catch (e) {
      debugPrint("🔥 Error loading order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pickupImage = order?['pickupImage']?.toString() ?? '';
    final deliveredImage = order?['deliveredImage']?.toString() ?? '';
    final hasPickupImage = pickupImage.trim().isNotEmpty;
    final hasDeliveredImage = deliveredImage.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.purple[800],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'รายละเอียดการจัดส่ง',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStatusBar(),
            const SizedBox(height: 20),
            _buildOrderInfo(),
            const SizedBox(height: 20),
            if (order?['riderId'] != null)
              _buildRiderInfoStream(order!['riderId']),
            const SizedBox(height: 20),
            _buildMapWithRealtimeRider(),
            const SizedBox(height: 30),
            if (hasPickupImage || hasDeliveredImage)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (hasPickupImage)
                    _buildStatusBox('ไรเดอร์รับของแล้ว', pickupImage),
                  if (hasDeliveredImage)
                    _buildStatusBox('ส่งเสร็จสิ้น', deliveredImage),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "ยังไม่มีรูปอัปโหลด",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.assignment, color: Colors.black),
          Icon(
            Icons.check_circle,
            color:
                order!['status'] == "ไรเดอร์รับของแล้ว" ||
                    order!['status'] == "จัดส่งสำเร็จ"
                ? Colors.green
                : Colors.black,
            size: 28,
          ),
          const Icon(Icons.motorcycle, color: Colors.black),
          Icon(
            Icons.home,
            color: order!['status'] == "จัดส่งสำเร็จ"
                ? Colors.green
                : Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📦 สินค้า: ${order?['productName'] ?? '-'}",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            "รายละเอียด: ${order?['productDetail'] ?? '-'}",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "ผู้ส่ง: ${order?['senderAddress'] ?? '-'}",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "ผู้รับ: ${order?['receiverName'] ?? '-'}",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "ที่อยู่ผู้รับ: ${order?['receiverAddress'] ?? '-'}",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "สถานะ: ${order?['status'] ?? '-'}",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ✅ ดึงข้อมูลไรเดอร์แบบ realtime
  Widget _buildRiderInfoStream(String riderId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('riders')
          .doc(riderId)
          .snapshots(includeMetadataChanges: true), // ✅ ให้ยิงทุกครั้ง
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            "ไม่สามารถโหลดข้อมูลไรเดอร์ได้",
            style: TextStyle(color: Colors.white),
          );
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final rider = snapshot.data!.data() as Map<String, dynamic>?;
        if (rider == null) return const SizedBox();

        return Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.purple, size: 35),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ไรเดอร์: ${rider['name'] ?? 'ไม่ระบุ'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'เบอร์โทร: ${rider['phone'] ?? '-'}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'หมายเลขรถ: ${rider['plate'] ?? '-'}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ✅ แผนที่อัปเดตตำแหน่งไรเดอร์เรียลไทม์
  // ✅ แผนที่อัปเดตตำแหน่งไรเดอร์เรียลไทม์
  Widget _buildMapWithRealtimeRider() {
    final senderLat = double.tryParse(order?['senderLat']?.toString() ?? '');
    final senderLng = double.tryParse(order?['senderLng']?.toString() ?? '');
    final receiverLat = double.tryParse(
      order?['receiverLat']?.toString() ?? '',
    );
    final receiverLng = double.tryParse(
      order?['receiverLng']?.toString() ?? '',
    );
    final receiverName = order?['receiverName'] ?? 'ผู้รับ';
    final riderId = order?['riderId'];

    if (senderLat == null || senderLng == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("ไม่มีข้อมูลตำแหน่งผู้ส่ง")),
      );
    }

    final senderLatLng = LatLng(senderLat, senderLng);
    LatLng? receiverLatLng;
    if (receiverLat != null && receiverLng != null) {
      receiverLatLng = LatLng(receiverLat, receiverLng);
    }

    if (riderId == null) {
      return _buildStaticMap(senderLatLng, receiverLatLng, receiverName, null);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('riders')
          .doc(riderId)
          .snapshots(includeMetadataChanges: true),
      builder: (context, snapshot) {
        LatLng? riderLatLng;
        if (snapshot.hasData && snapshot.data!.exists) {
          final riderData = snapshot.data!.data() as Map<String, dynamic>?;
          if (riderData?['location'] != null) {
            final loc = Map<String, dynamic>.from(riderData!['location']);
            riderLatLng = LatLng(
              double.tryParse(loc['lat'].toString()) ?? 0,
              double.tryParse(loc['lng'].toString()) ?? 0,
            );
          }
        }

        // ✅ เพิ่ม ValueKey เพื่อ force rebuild ทุกครั้งที่ตำแหน่งเปลี่ยน
        return _buildStaticMap(
          senderLatLng,
          receiverLatLng,
          receiverName,
          riderLatLng,
          key: ValueKey(riderLatLng?.toString() ?? 'no_rider'),
        );
      },
    );
  }

  // ✅ ปรับฟังก์ชัน _buildStaticMap ให้รับ key ได้
  Widget _buildStaticMap(
    LatLng senderLatLng,
    LatLng? receiverLatLng,
    String receiverName,
    LatLng? riderLatLng, {
    Key? key,
  }) {
    final initialCenter = riderLatLng ?? receiverLatLng ?? senderLatLng;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 300,
        child: FlutterMap(
          key: key, // ✅ ใช้ key ที่เพิ่มเข้ามา
          options: MapOptions(initialCenter: initialCenter, initialZoom: 14),
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
                  width: 100,
                  height: 80,
                  child: Column(
                    children: const [
                      Icon(Icons.store, color: Colors.blue, size: 30),
                      Text("ผู้ส่ง", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                if (receiverLatLng != null)
                  Marker(
                    point: receiverLatLng,
                    width: 120,
                    height: 80,
                    child: Column(
                      children: [
                        const Icon(Icons.home, color: Colors.green, size: 30),
                        Text(
                          receiverName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                if (riderLatLng != null)
                  Marker(
                    point: riderLatLng,
                    width: 100,
                    height: 80,
                    child: Column(
                      children: const [
                        Icon(Icons.motorcycle, color: Colors.red, size: 30),
                        Text("ไรเดอร์", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBox(String label, String imageUrl) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
