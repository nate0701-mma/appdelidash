import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailOrderPage extends StatelessWidget {
  const DetailOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D6EE), // สีพื้นหลังม่วงอ่อน
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'ข้อมูลสินค้า',
          style: GoogleFonts.prompt(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Order #0056',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-15-pro-max-storage-select-202309-6-7inch-gold_AV1?wid=940&hei=1112&fmt=png-alpha&.v=1693082205056',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'IPHONE 17',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'ราคา 39000 บาท',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
