import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/upload_field.dart';
import 'account_created_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _qualCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _picker = ImagePicker();
  String? _selectedExpertise;
  String? _profileImageName;
  String? _profileImagePath;
  String? _degreeImageName;
  bool _loading = false;

  Future<void> _saveAndContinue() async {
    if (_selectedExpertise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please choose your expertise'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_qualCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your qualification'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // Upload profile image if picked
      if (_profileImagePath != null) {
        await SupabaseService.uploadAvatar(_profileImagePath!);
      }

      await SupabaseService.updateProfile({
        'expertise': _selectedExpertise,
        'qualification': _qualCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'contact': _contactCtrl.text.trim(),
      });
      if (mounted) {
        AccountCreatedDialog.show(context);
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

  Future<void> _pickImage({required bool isProfile}) async {
    final file = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file != null) {
      setState(() {
        if (isProfile) {
          _profileImageName = file.name;
          _profileImagePath = file.path;
        } else {
          _degreeImageName = file.name;
        }
      });
    }
  }

  @override
  void dispose() {
    _qualCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Details',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Enter your personal details',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),

            // Upload Profile Image - dashed green border
            UploadField(
              label: 'Upload Profile Image',
              fileName: _profileImageName,
              onTap: () => _pickImage(isProfile: true),
            ),
            const SizedBox(height: 16),

            // Choose Experties dropdown
            DropdownButtonFormField<String>(
              value: _selectedExpertise,
              decoration: const InputDecoration(
                hintText: 'Choose Experties',
                hintStyle: TextStyle(color: AppColors.textHint),
              ),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textHint),
              items: const [
                'Crop Expert',
                'Livestock Expert',
                'Machinery Expert',
                'General'
              ]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedExpertise = v),
            ),
            const SizedBox(height: 16),

            // Qualification
            CustomTextField(
              controller: _qualCtrl,
              hint: 'Qualification',
            ),
            const SizedBox(height: 16),

            // Upload Latest Degree Image - dashed green border
            UploadField(
              label: 'Upload Latest Degree Image',
              fileName: _degreeImageName,
              onTap: () => _pickImage(isProfile: false),
            ),
            const SizedBox(height: 16),

            // Address - taller multiline field
            CustomTextField(
              controller: _addressCtrl,
              hint: 'Address',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Contact
            CustomTextField(
              controller: _contactCtrl,
              hint: 'Contact',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 28),

            // Next button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66339D44),
                    offset: Offset(5, 12),
                    blurRadius: 19,
                    spreadRadius: -11,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _loading ? null : _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF339D44),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Next',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),

            // Back link
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Back',
                  style: TextStyle(
                      color: Color(0xFF339D44),
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
