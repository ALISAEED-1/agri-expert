import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? videoId;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    this.videoId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
    _countView();
  }

  Future<void> _countView() async {
    final id = widget.videoId;
    if (id == null) return;
    try {
      await SupabaseService.incrementVideoViews(id);
    } catch (_) {}
  }

  Future<void> _init() async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await controller.initialize();
      _videoController = controller;
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true, // volume / mute control
        aspectRatio: controller.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
        ),
        placeholder: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        errorBuilder: (_, msg) => Center(
          child: Text(msg,
              style: const TextStyle(color: Colors.white70)),
        ),
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to play this video');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title,
            style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: Center(
        child: _error != null
            ? Text(_error!, style: const TextStyle(color: Colors.white70))
            : _chewieController != null &&
                    _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  )
                : const CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
