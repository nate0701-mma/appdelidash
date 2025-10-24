import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:async/async.dart'; // ✅ ใช้รวม Stream

class ShipmentMapPage extends StatefulWidget {
  final String userId;
  const ShipmentMapPage({super.key, required this.userId});

  @override
  State<ShipmentMapPage> createState() => _ShipmentMapPageState();
}

class _ShipmentMapPageState extends State<ShipmentMapPage> {
  LatLng? currentPosition;
  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเปิด GPS ก่อนใช้งานแผนที่')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() => currentPosition = LatLng(pos.latitude, pos.longitude));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(currentPosition!, 15);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4E066D),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          "แผนที่แสดงพิกัดทั้งหมดของฉัน",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _buildMap(),
    );
  }

  Widget _buildMap() {
    final orderStream = FirebaseFirestore.instance
        .collection('orders')
        .where('senderId', isEqualTo: widget.userId)
        .snapshots();

    final addressStream = FirebaseFirestore.instance
        .collection('addresses')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();

    return StreamBuilder<List<QuerySnapshot>>(
      stream: StreamZip([orderStream, addressStream]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final orders = snapshot.data![0].docs;
        final addresses = snapshot.data![1].docs;
        List<Marker> markers = [];
        List<Polyline> polylines = [];

        // ✅ รวม Stream ของไรเดอร์ทุกคนแบบ Real-time
        final List<Stream<DocumentSnapshot>> riderStreams = orders.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final riderId = data['riderId'];
          if (riderId != null && riderId.toString().isNotEmpty) {
            return FirebaseFirestore.instance
                .collection('riders')
                .doc(riderId)
                .snapshots();
          }
          // 🔧 ต้อง cast ให้ชนิดตรงกับ Stream<DocumentSnapshot>
          return Stream<DocumentSnapshot>.empty();
        }).toList();

        // ✅ รวม Stream ทุกไรเดอร์แบบเรียลไทม์
        return StreamBuilder<List<DocumentSnapshot>>(
          stream: StreamZip<DocumentSnapshot>(riderStreams),
          builder: (context, riderSnapshot) {
            for (var orderDoc in orders) {
              final data = orderDoc.data() as Map<String, dynamic>;
              final sender =
                  (data['senderLat'] != null && data['senderLng'] != null)
                  ? LatLng(data['senderLat'], data['senderLng'])
                  : null;
              final receiver =
                  (data['receiverLat'] != null && data['receiverLng'] != null)
                  ? LatLng(data['receiverLat'], data['receiverLng'])
                  : null;

              // 🟢 ผู้ส่ง
              if (sender != null) {
                markers.add(
                  Marker(
                    point: sender,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.store,
                      color: Colors.greenAccent,
                      size: 40,
                    ),
                  ),
                );
              }

              // 🔴 ผู้รับ
              if (receiver != null) {
                markers.add(
                  Marker(
                    point: receiver,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                );
              }
            }

            // 🟠 เพิ่ม Marker ของไรเดอร์ทุกคน
            if (riderSnapshot.hasData) {
              for (var riderDoc in riderSnapshot.data!) {
                if (!riderDoc.exists) continue;
                final riderData = riderDoc.data() as Map<String, dynamic>?;
                if (riderData == null) continue;

                LatLng? riderPos;
                if (riderData['location'] != null) {
                  final loc = Map<String, dynamic>.from(
                    riderData['location'] as Map,
                  );
                  riderPos = LatLng(
                    double.tryParse(loc['lat'].toString()) ?? 0,
                    double.tryParse(loc['lng'].toString()) ?? 0,
                  );
                } else if (riderData['riderLat'] != null &&
                    riderData['riderLng'] != null) {
                  riderPos = LatLng(
                    riderData['riderLat'],
                    riderData['riderLng'],
                  );
                }

                if (riderPos != null) {
                  markers.add(
                    Marker(
                      point: riderPos,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.orange,
                        size: 45,
                      ),
                    ),
                  );
                }
              }
            }

            // ✅ เส้นทาง sender → receiver (ไม่มีการ return กลางลูปอีกต่อไป)
            for (var orderDoc in orders) {
              final data = orderDoc.data() as Map<String, dynamic>;
              final sender =
                  (data['senderLat'] != null && data['senderLng'] != null)
                  ? LatLng(data['senderLat'], data['senderLng'])
                  : null;
              final receiver =
                  (data['receiverLat'] != null && data['receiverLng'] != null)
                  ? LatLng(data['receiverLat'], data['receiverLng'])
                  : null;
              if (sender != null && receiver != null) {
                polylines.add(
                  Polyline(
                    points: [sender, receiver],
                    strokeWidth: 3,
                    color: Colors.orangeAccent,
                  ),
                );
              }
            }

            // ✅ คืนแผนที่พร้อมทุกจุด
            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentPosition!,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=b21c118534bb44cebc91a85e81999b28",
                  userAgentPackageName: 'com.example.app',
                ),
                if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            );
          },
        );
      },
    );
  }
}
