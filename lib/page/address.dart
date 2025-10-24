import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/page/addaddessafter.dart';
import 'package:delidash/page/addressInsert.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

class AddressPage extends StatefulWidget {
  final String userId;
  const AddressPage({super.key, required this.userId});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ที่อยู่ของฉัน'),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Homepage(userId: widget.userId),
              ),
            );
          },
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 117, 34, 150),
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('addresses')
              .where('userId', isEqualTo: widget.userId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            // กรณีโหลดอยู่
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            // กรณี error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "เกิดข้อผิดพลาด: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            }

            // ถ้าไม่มีข้อมูลเลย
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "ยังไม่มีที่อยู่ที่บันทึกไว้",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }

            // แสดงรายการที่อยู่จริง
            final addresses = snapshot.data!.docs;

            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final data = addresses[index].data() as Map<String, dynamic>;
                final address = data['address'] ?? "ไม่พบข้อมูลที่อยู่";
                final lat = data['lat'] ?? "-";
                final lng = data['lng'] ?? "-";
                final createdAt = data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp).toDate()
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 232, 214, 235),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text("Lat: $lat, Lng: $lng"),
                      if (createdAt != null)
                        Text(
                          "เพิ่มเมื่อ: ${createdAt.toLocal()}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[200],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAddressAfter(userId: widget.userId),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
