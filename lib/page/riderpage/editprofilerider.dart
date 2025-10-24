import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileRiderPage extends StatefulWidget {
  const EditProfileRiderPage({Key? key}) : super(key: key);

  @override
  State<EditProfileRiderPage> createState() => _EditProfileRiderPageState();
}

class _EditProfileRiderPageState extends State<EditProfileRiderPage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'โคทาโร่ โคคิมิจิ',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '0991234567',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'rider@gmail.com',
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _carNumberController = TextEditingController(
    text: 'กง1568',
  );

  File? _profileImage;
  File? _vehicleImage;
  final ImagePicker _picker = ImagePicker();

  // เลือกรูปโปรไฟล์
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // เลือกรูปรถ
  Future<void> _pickVehicleImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _vehicleImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกการแก้ไขโปรไฟล์เรียบร้อยแล้ว')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1D9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'แก้ไขโปรไฟล์ไรเดอร์',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // รูปโปรไฟล์
            Column(
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.purple,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'แตะเพื่อแก้ไขรูปโปรไฟล์',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ช่องกรอกข้อมูล
            _buildTextField('ชื่อ', _nameController),
            _buildTextField('เบอร์โทร', _phoneController),
            _buildTextField('อีเมล', _emailController),
            _buildTextField('รหัสผ่าน', _passwordController, obscureText: true),
            _buildTextField(
              'ยืนยันรหัสผ่าน',
              _confirmPasswordController,
              obscureText: true,
            ),
            _buildTextField('ทะเบียนรถ', _carNumberController),
            const SizedBox(height: 15),

            const Text(
              'ยานพาหนะ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // รูปรถ
            _vehicleImage != null
                ? Image.file(_vehicleImage!, height: 140)
                : Image.asset(
                    'assets/images/car.png',
                    height: 140,
                    fit: BoxFit.cover,
                  ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickVehicleImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('แก้ไขรูปยานพาหนะ'),
            ),

            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'ยืนยันการแก้ไขโปรไฟล์',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget ช่องกรอกข้อมูล
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
