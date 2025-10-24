import 'dart:async';
import 'dart:io';
import 'package:delidash/page/riderpage/work_rider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:delidash/supabase_config.dart';

class DeliveryStatusPage extends StatefulWidget {
  final String orderId;
  final String riderId;
  final LatLng senderLatLng;
  final LatLng receiverLatLng;

  const DeliveryStatusPage({
    super.key,
    required this.orderId,
    required this.riderId,
    required this.senderLatLng,
    required this.receiverLatLng,
  });

  @override
  State<DeliveryStatusPage> createState() => _DeliveryStatusPageState();
}

class _DeliveryStatusPageState extends State<DeliveryStatusPage> {
  final ImagePicker _picker = ImagePicker();
  LatLng? riderPosition;
  StreamSubscription<Position>? _positionStream;
  String thunderforestApiKey = "b21c118534bb44cebc91a85e81999b28";

  // รูปภาพที่อัปโหลดแล้ว
  String? pickupImageUrl;
  String? deliveredImageUrl;

  @override
  void initState() {
    super.initState();
    _startRiderLocationUpdates();
    listenToRiderRealtime();
    _loadExistingImages(); // โหลดภาพที่เคยอัปโหลด
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // ✅ โหลดภาพที่มีอยู่ใน Firestore
  Future<void> _loadExistingImages() async {
    final doc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        pickupImageUrl = data?['pickupImage'];
        deliveredImageUrl = data?['deliveredImage'];
      });
    }
  }

  // ✅ อัปเดตตำแหน่งไรเดอร์เรียลไทม์
  Future<void> _startRiderLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position pos) async {
          setState(() {
            riderPosition = LatLng(pos.latitude, pos.longitude);
          });

          await FirebaseFirestore.instance
              .collection('riders')
              .doc(widget.riderId)
              .update({
                'location': {'lat': pos.latitude, 'lng': pos.longitude},
                'updatedAt': FieldValue.serverTimestamp(),
              });
        });
  }

  // ✅ ฟังตำแหน่งไรเดอร์จาก Firestore
  void listenToRiderRealtime() {
    FirebaseFirestore.instance
        .collection('riders')
        .doc(widget.riderId)
        .snapshots()
        .listen((doc) {
          if (doc.exists) {
            final data = doc.data();
            if (data?['location'] != null) {
              setState(() {
                riderPosition = LatLng(
                  data!['location']['lat'],
                  data['location']['lng'],
                );
              });
            }
          }
        });
  }

  // ✅ อัปโหลดรูปและอัปเดตสถานะใน Firestore
  Future<void> uploadPhotoAndUpdateStatus(String type) async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;

      final file = File(picked.path);
      final fileName =
          "${widget.orderId}_${type}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // 🔹 อัปโหลดรูปไป Supabase
      await SupabaseConfig.client.storage
          .from("delivery_photos")
          .upload(fileName, file);

      final imageUrl = SupabaseConfig.client.storage
          .from("delivery_photos")
          .getPublicUrl(fileName);

      // 🔹 กำหนดสถานะใหม่
      String newStatus = type == "pickup"
          ? "ไรเดอร์รับของแล้ว"
          : "จัดส่งสำเร็จ";

      // 🔹 อัปเดตใน orders (สถานะล่าสุด + รูป)
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
            'status': newStatus,
            '${type}Image': imageUrl, // pickupImage / deliveredImage
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // 🔹 เก็บประวัติใน order_updates (timeline)
      await FirebaseFirestore.instance.collection('order_updates').add({
        'orderId': widget.orderId,
        'riderId': widget.riderId,
        'status': newStatus,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 🔹 อัปเดต UI ให้เห็นรูป
      setState(() {
        if (type == "pickup") {
          pickupImageUrl = imageUrl;
        } else {
          deliveredImageUrl = imageUrl;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ อัปโหลดรูปและอัปเดตสถานะ: $newStatus")),
      );

      // 🔹 ถ้าส่งของเสร็จ กลับไปหน้า WorkRiderPage
      if (type == "delivered" && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => WorkRiderPage(riderId: widget.riderId),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  // ✅ UI แผนที่
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // ❌ ห้ามออกก่อนส่งของเสร็จ
        if (deliveredImageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⚠️ กรุณาส่งของให้เสร็จก่อนออกจากหน้านี้"),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff3e9fa),
        appBar: AppBar(
          automaticallyImplyLeading: false, // ❌ ปิดปุ่มย้อนกลับ
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'สถานะการจัดส่งสินค้า',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔹 แผนที่ Thunderforest
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: widget.senderLatLng,
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
                          point: widget.senderLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.store, color: Colors.blue),
                        ),
                        Marker(
                          point: widget.receiverLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.home, color: Colors.green),
                        ),
                        if (riderPosition != null)
                          Marker(
                            point: riderPosition!,
                            width: 45,
                            height: 45,
                            child: const Icon(
                              Icons.motorcycle,
                              color: Colors.red,
                              size: 35,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 ส่วนอัปโหลดรูป
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoSection('ภาพขณะรับของ', 'pickup'),
                  _buildPhotoSection('ภาพขณะส่งเสร็จสิ้น', 'delivered'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ สร้างส่วน UI สำหรับอัปโหลดรูป + แสดงภาพ
  Widget _buildPhotoSection(String label, String type) {
    final imageUrl = (type == "pickup") ? pickupImageUrl : deliveredImageUrl;

    return Column(
      children: [
        if (imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 32,
              color: Colors.black54,
            ),
          ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffe5d0f7),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => uploadPhotoAndUpdateStatus(type),
          child: Text(imageUrl == null ? 'ส่ง' : 'เปลี่ยนรูป'),
        ),
      ],
    );
  }
}
