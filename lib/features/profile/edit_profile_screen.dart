import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _picker = ImagePicker();
  String? _avatarUrl;
  String? _pickedImagePath;
  bool _loading = false;
  bool _fetching = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await SupabaseService.getProfile();
      if (profile != null && mounted) {
        _nameCtrl.text = profile['full_name'] as String? ?? '';
        _emailCtrl.text = profile['email'] as String? ?? '';
        _avatarUrl = profile['avatar_url'] as String?;
      }
    } catch (_) {}
    if (mounted) setState(() => _fetching = false);
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file != null) {
      setState(() => _pickedImagePath = file.path);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Name is required'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // Upload avatar if picked
      if (_pickedImagePath != null) {
        final url = await SupabaseService.uploadAvatar(_pickedImagePath!);
        if (url != null) _avatarUrl = url;
      }

      await SupabaseService.updateProfile({'full_name': name});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated!'),
              backgroundColor: AppColors.primary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Widget _buildAvatar() {
    if (_pickedImagePath != null) {
      return CircleAvatar(
        radius: 44,
        backgroundImage: FileImage(File(_pickedImagePath!)),
      );
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 44,
        backgroundImage: CachedNetworkImageProvider(_avatarUrl!),
        backgroundColor: AppColors.surface,
      );
    }
    return CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.surface,
      child: Text(
        _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Color(0xff339D44),),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: _fetching
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar with edit icon
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        _buildAvatar(),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary,
                            child: const Icon(Icons.edit,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    controller: _nameCtrl,
                    label: 'Name',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Spacer(),
                  CustomButton(
                    text: 'Save Changes',
                    loading: _loading,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
