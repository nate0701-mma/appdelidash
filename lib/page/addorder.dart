import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../supabase_config.dart';
import '../page/addressInsert.dart';

class AddOrderPage extends StatefulWidget {
  final String userId;
  const AddOrderPage({super.key, required this.userId});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController =
      TextEditingController(); // ✅ เพิ่มช่องชื่อสินค้า
  final TextEditingController _detailController = TextEditingController();

  Map<String, dynamic>? senderAddress;
  List<Map<String, dynamic>> receiverList = [];
  Map<String, dynamic>? selectedReceiver;
  bool isLoading = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _chooseSenderAddress() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsertAddressPage(userId: widget.userId),
      ),
    );
    if (selected != null && selected is Map<String, dynamic>) {
      setState(() => senderAddress = selected);
    }
  }

  Future<void> _searchReceiver() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณากรอกเบอร์โทร")));
      return;
    }

    setState(() {
      isLoading = true;
      receiverList = [];
      selectedReceiver = null;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isGreaterThanOrEqualTo: phone)
          .where('phone', isLessThanOrEqualTo: "$phone\uf8ff")
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          receiverList = query.docs.map((e) => e.data()).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ไม่พบผู้รับที่ตรงกับเบอร์โทร")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }

    setState(() => isLoading = false);
  }

  Future<String?> _uploadImageToSupabase(File file) async {
    try {
      final fileName = "product_${DateTime.now().millisecondsSinceEpoch}.jpg";
      await SupabaseConfig.client.storage
          .from("product_images")
          .upload(fileName, file);
      final imageUrl = SupabaseConfig.client.storage
          .from("product_images")
          .getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      debugPrint("❌ อัปโหลดรูปไม่สำเร็จ: $e");
      return null;
    }
  }

  Future<void> _sendOrder() async {
    if (senderAddress == null || selectedReceiver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณาเลือกที่อยู่ผู้ส่งและผู้รับก่อนส่งสินค้า"),
        ),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณากรอกชื่อสินค้า")));
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImageToSupabase(_imageFile!);
      }

      await FirebaseFirestore.instance.collection('orders').add({
        'senderId': widget.userId,
        'senderAddress': senderAddress!['address'],
        'senderLat': senderAddress!['lat'],
        'senderLng': senderAddress!['lng'],
        'receiverName': selectedReceiver!['name'] ?? '',
        'receiverPhone': selectedReceiver!['phone'] ?? '',
        'receiverAddress': selectedReceiver!['address'] ?? 'ไม่พบที่อยู่',
        'productName': _nameController.text.trim(), // ✅ เก็บชื่อสินค้า
        'productDetail': _detailController.text.trim(),
        'productImage': imageUrl,
        'status': 'รอจัดส่ง',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ส่งสินค้าเรียบร้อย ✅")));

      setState(() {
        _imageFile = null;
        senderAddress = null;
        selectedReceiver = null;
        receiverList = [];
        _phoneController.clear();
        _nameController.clear(); // ✅ ล้างช่องชื่อสินค้า
        _detailController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4E066D),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('ส่งสินค้า', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ ที่อยู่ผู้ส่ง
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _chooseSenderAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                    ),
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    label: const Text('เลือกที่อยู่ผู้ส่ง'),
                  ),
                  const SizedBox(height: 8),
                  if (senderAddress != null)
                    Text(
                      "📦 ${senderAddress!['address']}\n🌍 Lat: ${senderAddress!['lat']} | Lng: ${senderAddress!['lng']}",
                      style: const TextStyle(color: Colors.white),
                    )
                  else
                    const Text(
                      "ยังไม่ได้เลือกที่อยู่ผู้ส่ง",
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ ค้นหาผู้รับ
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.purple[100],
                      hintText: 'ค้นหาผู้รับจากเบอร์โทร',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _searchReceiver,
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ ผู้รับที่เลือก
            if (selectedReceiver != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "👤 ${selectedReceiver!['name']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "📞 ${selectedReceiver!['phone']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "📍 ${selectedReceiver!['address']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => selectedReceiver = null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        "เปลี่ยนผู้รับ",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ แสดงผลการค้นหา
            if (receiverList.isNotEmpty && selectedReceiver == null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: receiverList.map((user) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedReceiver = user),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "👤 ${user['name'] ?? '-'}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "📞 ${user['phone'] ?? '-'}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "📍 ${user['address'] ?? '-'}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // ✅ อัปโหลดรูปสินค้า
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.purple[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imageFile == null
                  ? Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('เลือกรูปสินค้า'),
                      ),
                    )
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: () => setState(() => _imageFile = null),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // ✅ ชื่อสินค้า
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.purple[100],
                hintText: 'ชื่อสินค้า',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ รายละเอียดสินค้า
            TextField(
              controller: _detailController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.purple[100],
                hintText: 'รายละเอียดสินค้า',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ ปุ่มส่งสินค้า
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[900],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("ส่งสินค้า"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
