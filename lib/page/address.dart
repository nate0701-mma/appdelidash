import 'package:flutter/material.dart';
import '../page/profileuser.dart'; // import หน้า ProfileUserPage ของคุณ

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  // ตัวอย่าง list ของที่อยู่
  List<String> addresses = ['ที่อยู่ที่1', 'ที่อยู่ที่2', 'ที่อยู่ที่3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ที่อยู่ของฉัน'),
        backgroundColor: const Color.fromARGB(255, 253, 252, 253),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // กลับไปหน้า ProfileUserPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileUserPage()),
            );
          },
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 117, 34, 150),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 232, 214, 235),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      addresses[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // เพิ่มที่อยู่ใหม่
                  setState(() {
                    addresses.add('ที่อยู่ใหม่ ${addresses.length + 1}');
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'เพิ่มที่อยู่',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
