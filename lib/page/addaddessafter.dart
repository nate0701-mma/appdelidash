import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // ✅ ใช้สำหรับ GPS
import 'address.dart'; // ✅ หน้าแสดงที่อยู่ทั้งหมด

class AddAddressAfter extends StatefulWidget {
  final String userId;

  const AddAddressAfter({super.key, required this.userId});

  @override
  State<AddAddressAfter> createState() => _AddAddressAfterState();
}

class _AddAddressAfterState extends State<AddAddressAfter> {
  final MapController _mapController = MapController();
  LatLng _selectedPoint = LatLng(16.246373, 103.251827); // จุดเริ่มต้น
  final TextEditingController placeNameController = TextEditingController();
  bool isSaving = false;
  bool isLocating = false; // ✅ แสดงสถานะตอนกำลังหาพิกัด

  // ✅ ขอสิทธิ์และดึงพิกัดปัจจุบัน
  Future<void> _getCurrentLocation() async {
    setState(() => isLocating = true);

    try {
      // ขอสิทธิ์เข้าถึงตำแหน่ง
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง GPS"),
          ),
        );
        setState(() => isLocating = false);
        return;
      }

      // ดึงตำแหน่งปัจจุบัน
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedPoint = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedPoint, 16.0);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📍 ปักหมุดตำแหน่งปัจจุบันแล้ว")),
      );
    } catch (e) {
      log("❌ เกิดข้อผิดพลาดในการดึงตำแหน่ง: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการดึงตำแหน่ง: $e")),
      );
    }

    setState(() => isLocating = false);
  }

  // ✅ ฟังก์ชันบันทึกข้อมูลที่อยู่
  Future<void> _saveAddress() async {
    final placeName = placeNameController.text.trim();

    if (placeName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาป้อนชื่อสถานที่")));
      return;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('addresses').add({
        'userId': widget.userId,
        'address': placeName,
        'lat': _selectedPoint.latitude,
        'lng': _selectedPoint.longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      log("✅ เพิ่มที่อยู่เรียบร้อยแล้ว");

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddressPage(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      log("❌ เกิดข้อผิดพลาดในการบันทึก: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึก: $e")));
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มที่อยู่ใหม่"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "ระบุพิกัดที่อยู่",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ ปุ่มใช้ GPS ปัจจุบัน
            ElevatedButton.icon(
              onPressed: isLocating ? null : _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: isLocating
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location, color: Colors.white),
              label: Text(
                isLocating ? "กำลังหาตำแหน่ง..." : "ใช้ตำแหน่งปัจจุบัน (GPS)",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ แผนที่เลือกจุด
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPoint,
                      initialZoom: 15.2,
                      onTap: (tapPos, point) {
                        log("เลือกพิกัด: $point");
                        setState(() {
                          _selectedPoint = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.thunderforest.com/neighbourhood/{z}/{x}/{y}.png?apikey=b21c118534bb44cebc91a85e81999b28',
                        userAgentPackageName: 'com.example.delidash',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.purple,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ ข้อมูลที่อยู่
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.purple[100],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: placeNameController,
                    decoration: InputDecoration(
                      hintText: "ป้อนชื่อสถานที่ เช่น บ้าน, หอพัก, ร้านค้า",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Lat: ${_selectedPoint.latitude.toStringAsFixed(6)}, "
                          "Lng: ${_selectedPoint.longitude.toStringAsFixed(6)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isSaving ? null : _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save, color: Colors.white),
                        label: Text(isSaving ? "กำลังบันทึก..." : "ยืนยัน"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text("ยกเลิก"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
