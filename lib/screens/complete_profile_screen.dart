import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tanaw_app/state/profile_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const CompleteProfileScreen({super.key, required this.onCompleted});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _localImagePath;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _localImagePath = picked.path;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final profileState = Provider.of<ProfileState>(context, listen: false);
      if (_nameController.text.trim().isNotEmpty) {
        profileState.updateUserName(_nameController.text.trim());
      }
      if (_localImagePath != null && !kIsWeb) {
        profileState.updateUserImage(_localImagePath!);
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF153A5B)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Profile updated!',
                  style: TextStyle(color: Color(0xFF153A5B), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      widget.onCompleted();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = Provider.of<ProfileState>(context);
    _nameController.text = _nameController.text.isEmpty ? profileState.userName : _nameController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: const Color(0xFF153A5B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundImage: _localImagePath != null && !kIsWeb
                      ? FileImage(File(_localImagePath!))
                      : (profileState.userImageUrl != null
                          ? NetworkImage(profileState.userImageUrl!)
                          : (profileState.userImagePath != null && !kIsWeb
                              ? FileImage(File(profileState.userImagePath!))
                              : const AssetImage('assets/TANAW-LOGO2.0.png'))) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF153A5B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.photo_camera, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your name',
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF153A5B)),
                filled: true,
                fillColor: const Color(0xFFF3F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF153A5B),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}


