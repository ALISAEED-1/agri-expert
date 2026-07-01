import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/upload_field.dart';

class AddVideoScreen extends StatefulWidget {
  // When these are set the screen acts as an EDIT screen for an existing video.
  final String? videoId;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialThumbnailUrl;

  const AddVideoScreen({
    super.key,
    this.videoId,
    this.initialTitle,
    this.initialDescription,
    this.initialThumbnailUrl,
  });

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();
  bool _loading = false;
  String? _videoFileName;
  String? _thumbnailFileName;
  String? _videoPath;
  String? _thumbnailPath;

  bool get _isEdit => widget.videoId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _titleCtrl.text = widget.initialTitle ?? '';
      _descCtrl.text = widget.initialDescription ?? '';
    }
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _videoFileName = file.name;
        _videoPath = file.path;
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _thumbnailFileName = file.name;
        _thumbnailPath = file.path;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Title is required'), backgroundColor: Colors.red),
      );
      return;
    }
    // Video is required when adding; optional when editing (keep existing).
    if (!_isEdit && _videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a video'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Upload media only if a new file was picked.
      String? videoUrl;
      if (_videoPath != null) {
        videoUrl = await SupabaseService.uploadVideoFile(_videoPath!);
      }
      String? thumbnailUrl;
      if (_thumbnailPath != null) {
        thumbnailUrl =
            await SupabaseService.uploadVideoThumbnail(_thumbnailPath!);
      }

      if (_isEdit) {
        await SupabaseService.updateVideo(
          videoId: widget.videoId!,
          title: title,
          description: _descCtrl.text.trim(),
          videoUrl: videoUrl, // null = keep existing
          thumbnailUrl: thumbnailUrl, // null = keep existing
        );
      } else {
        await SupabaseService.addVideo(
          title: title,
          description: _descCtrl.text.trim(),
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
        );
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
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (!mounted) return;

    if (_isEdit) {
      // Return to the list, which refreshes on pop.
      Navigator.pop(context);
      return;
    }

    _titleCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _videoFileName = null;
      _thumbnailFileName = null;
      _videoPath = null;
      _thumbnailPath = null;
      _loading = false;
    });
    _showUploaded();
  }

  void _showUploaded() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.done_all,
                  color: AppColors.primary, size: 64),
              const SizedBox(height: 16),
              const Text('Uploaded',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Video uploaded',
                  style: TextStyle(color: AppColors.primary)),
              const SizedBox(height: 24),
              CustomButton(
                text: 'View Videos',
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // back to the videos list
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.primary, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(_isEdit ? 'Edit Video' : 'Add Video',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // ── Scrollable body ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ── Video preview — shows picked thumbnail if any ──
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFFE8E8E8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_thumbnailPath != null)
                            Positioned.fill(
                              child: Image.file(
                                File(_thumbnailPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (_isEdit &&
                              widget.initialThumbnailUrl != null &&
                              widget.initialThumbnailUrl!.isNotEmpty)
                            Positioned.fill(
                              child: Image.network(
                                widget.initialThumbnailUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(230),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_outlined,
                                color: AppColors.primary, size: 30),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── All fields padded ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          // Upload Video
                          UploadField(
                            label: 'Upload Video',
                            fileName: _videoFileName,
                            onTap: _pickVideo,
                          ),
                          const SizedBox(height: 14),

                          // Upload Thumbnail
                          UploadField(
                            label: 'Upload Thumbnail',
                            fileName: _thumbnailFileName,
                            onTap: _pickThumbnail,
                          ),
                          const SizedBox(height: 18),

                          // Title field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              controller: _titleCtrl,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Title',
                                hintStyle: TextStyle(
                                    color: AppColors.textHint, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Description field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              controller: _descCtrl,
                              maxLines: 5,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Description',
                                hintStyle: TextStyle(
                                    color: AppColors.textHint, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Post / Update button
                          CustomButton(
                              text: _isEdit ? 'Update' : 'Post',
                              loading: _loading,
                              onPressed: _post),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
