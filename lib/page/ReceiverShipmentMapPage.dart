import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:async/async.dart';

class ReceiverShipmentMapPage extends StatefulWidget {
  final String userId;
  const ReceiverShipmentMapPage({super.key, required this.userId});

  @override
  State<ReceiverShipmentMapPage> createState() =>
      _ReceiverShipmentMapPageState();
}

class _ReceiverShipmentMapPageState extends State<ReceiverShipmentMapPage> {
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
      mapController.move(currentPosition!, 14);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "แผนที่ของที่ฉันต้องรับ",
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
    // ✅ ดึง order ที่ฉันเป็นผู้รับ
    final orderStream = FirebaseFirestore.instance
        .collection('orders')
        .where('receiverId', isEqualTo: widget.userId)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: orderStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final orders = snapshot.data!.docs;
        if (orders.isEmpty) {
          return const Center(
            child: Text(
              "ยังไม่มีสินค้าที่ต้องรับ",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        // 🟢 รวม stream ของไรเดอร์ทุกคน (เพื่อให้ realtime)
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

        return StreamBuilder<List<DocumentSnapshot>>(
          stream: riderStreams.isNotEmpty
              ? StreamZip(riderStreams)
              : const Stream.empty(),
          builder: (context, riderSnapshot) {
            List<Marker> markers = [];
            List<Polyline> polylines = [];

            // 📍 พิกัดปัจจุบัน
            markers.add(
              Marker(
                point: currentPosition!,
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.lightBlueAccent,
                  size: 40,
                ),
              ),
            );

            // 🟢 วนแสดงทุก order
            for (int i = 0; i < orders.length; i++) {
              final data = orders[i].data() as Map<String, dynamic>;
              final productName = data['productName'] ?? 'ไม่ระบุสินค้า';
              final sender =
                  (data['senderLat'] != null && data['senderLng'] != null)
                  ? LatLng(data['senderLat'], data['senderLng'])
                  : null;
              final receiver =
                  (data['receiverLat'] != null && data['receiverLng'] != null)
                  ? LatLng(data['receiverLat'], data['receiverLng'])
                  : null;

              // 🏠 บ้านผู้ส่ง
              if (sender != null) {
                markers.add(
                  Marker(
                    point: sender,
                    width: 60,
                    height: 60,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.store,
                          color: Colors.purpleAccent,
                          size: 40,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            "ผู้ส่ง",
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 🎯 จุดของฉัน (ผู้รับ)
              if (receiver != null) {
                markers.add(
                  Marker(
                    point: receiver,
                    width: 90,
                    height: 80,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 🛵 แสดงพิกัดไรเดอร์แบบ realtime
              if (riderSnapshot.hasData &&
                  riderSnapshot.data!.length > i &&
                  riderSnapshot.data![i].exists) {
                final riderData =
                    riderSnapshot.data![i].data() as Map<String, dynamic>?;
                LatLng? riderPos;

                if (riderData != null) {
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

                  // 🔶 เส้นทาง sender → rider → receiver
                  if (sender != null && receiver != null) {
                    polylines.add(
                      Polyline(
                        points: [sender, riderPos, receiver],
                        strokeWidth: 4,
                        color: Colors.orangeAccent,
                      ),
                    );
                  }
                }
              }
            }

            // ✅ แสดงแผนที่ทั้งหมด
            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentPosition!,
                initialZoom: 13,
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
