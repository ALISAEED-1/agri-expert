import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ─── Auth ───────────────────────────────────────────────

  static SupabaseClient get client => _client;
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  /// True while a password-recovery deep link is being handled, so the
  /// splash screen doesn't navigate away from the Set New Password flow.
  static bool isPasswordRecovery = false;

  /// Sign up with email, password, and full name.
  /// The DB trigger auto-creates a profile row.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    // Supabase does not throw for an already-registered email when email
    // confirmation is on — it returns an obfuscated user with empty identities.
    // Detect that case and surface a clear error.
    if (res.user != null &&
        (res.user!.identities == null || res.user!.identities!.isEmpty)) {
      throw 'This email is already registered';
    }

    return res;
  }

  /// Sign in with email and password.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Whether an email belongs to a registered account.
  static Future<bool> emailExists(String email) async {
    final res = await _client.rpc('email_exists', params: {'p_email': email});
    return res == true;
  }

  /// Send a password-reset email that deep-links back into the app.
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'agriexpert://reset-password',
    );
  }

  /// Set a new password for the currently-recovering user.
  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Sign out.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Profile ────────────────────────────────────────────

  /// Get the current user's profile.
  static Future<Map<String, dynamic>?> getProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final res =
        await _client.from('profiles').select().eq('id', uid).maybeSingle();
    return res;
  }

  /// Update profile fields for the current user.
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await _client.from('profiles').update(data).eq('id', uid);
  }

  // ─── Avatar Upload ─────────────────────────────────────

  /// Upload a profile image to Supabase Storage and save URL to profile.
  static Future<String?> uploadAvatar(String filePath) async {
    final uid = currentUser?.id;
    if (uid == null) return null;

    final file = File(filePath);
    final ext = filePath.split('.').last.toLowerCase();
    final storagePath = '$uid/avatar.$ext';

    await _client.storage.from('avatars').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl =
        _client.storage.from('avatars').getPublicUrl(storagePath);

    // Add cache-buster so the image refreshes
    final urlWithCacheBust = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

    await updateProfile({'avatar_url': publicUrl});
    debugPrint('Avatar uploaded: $urlWithCacheBust');
    return urlWithCacheBust;
  }

  // ─── Questions ──────────────────────────────────────────

  /// Fetch all questions, newest first.
  static Future<List<Map<String, dynamic>>> getQuestions({
    String? status,
  }) async {
    var query = _client.from('questions').select();
    if (status != null) {
      query = query.eq('status', status);
    }
    final res = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Search questions by text.
  static Future<List<Map<String, dynamic>>> searchQuestions(
      String keyword) async {
    final res = await _client
        .from('questions')
        .select()
        .ilike('text', '%$keyword%')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ─── Answers ────────────────────────────────────────────

  /// Submit an answer and mark the question as answered.
  static Future<void> submitAnswer({
    required String questionId,
    required String text,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) throw Exception('Not logged in');

    await _client.from('answers').insert({
      'question_id': questionId,
      'expert_id': uid,
      'text': text,
    });

    // Mark question as answered
    await _client
        .from('questions')
        .update({'status': 'answered'}).eq('id', questionId);
  }

  /// Update an existing answer.
  static Future<void> updateAnswer({
    required String answerId,
    required String text,
  }) async {
    await _client.from('answers').update({'text': text}).eq('id', answerId);
  }

  /// Delete an answer and send the question back to the pending queue.
  static Future<void> deleteAnswer({
    required String answerId,
    required String questionId,
  }) async {
    await _client.from('answers').delete().eq('id', answerId);
    await _client
        .from('questions')
        .update({'status': 'pending'}).eq('id', questionId);
  }

  /// Get answers for a question.
  static Future<List<Map<String, dynamic>>> getAnswers(
      String questionId) async {
    final res = await _client
        .from('answers')
        .select()
        .eq('question_id', questionId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ─── Videos ─────────────────────────────────────────────

  /// Add a video entry.
  static Future<void> addVideo({
    required String title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) throw Exception('Not logged in');
    await _client.from('videos').insert({
      'expert_id': uid,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
    });
  }

  /// Upload a video file to the `videos` bucket and return its public URL.
  static Future<String> uploadVideoFile(String filePath) async {
    final uid = currentUser?.id;
    if (uid == null) throw Exception('Not logged in');
    final ext = filePath.split('.').last.toLowerCase();
    final storagePath =
        '$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('videos').upload(
          storagePath,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('videos').getPublicUrl(storagePath);
  }

  /// Upload a thumbnail image to the `videos` bucket and return its public URL.
  static Future<String> uploadVideoThumbnail(String filePath) async {
    final uid = currentUser?.id;
    if (uid == null) throw Exception('Not logged in');
    final ext = filePath.split('.').last.toLowerCase();
    final storagePath =
        '$uid/thumb_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('videos').upload(
          storagePath,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('videos').getPublicUrl(storagePath);
  }

  /// Update a video. Only video_url / thumbnail_url that are provided
  /// (non-null) are changed, so editing text keeps the existing media.
  static Future<void> updateVideo({
    required String videoId,
    required String title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
    };
    if (videoUrl != null) data['video_url'] = videoUrl;
    if (thumbnailUrl != null) data['thumbnail_url'] = thumbnailUrl;
    await _client.from('videos').update(data).eq('id', videoId);
  }

  /// Delete a video row.
  static Future<void> deleteVideo(String videoId) async {
    await _client.from('videos').delete().eq('id', videoId);
  }

  /// Get videos for the current expert.
  static Future<List<Map<String, dynamic>>> getMyVideos() async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    final res = await _client
        .from('videos')
        .select()
        .eq('expert_id', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Increment a video's view counter by one (atomic, server-side).
  static Future<void> incrementVideoViews(String videoId) async {
    await _client.rpc('increment_video_views', params: {'p_video_id': videoId});
  }

  /// Search videos by title.
  static Future<List<Map<String, dynamic>>> searchVideos(
      String keyword) async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    final res = await _client
        .from('videos')
        .select()
        .eq('expert_id', uid)
        .ilike('title', '%$keyword%')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ─── Video Comments ────────────────────────────────────

  /// Get comments for a video.
  static Future<List<Map<String, dynamic>>> getVideoComments(
      String videoId) async {
    final res = await _client
        .from('video_comments')
        .select()
        .eq('video_id', videoId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get comment count for a video.
  static Future<int> getVideoCommentCount(String videoId) async {
    final res = await _client
        .from('video_comments')
        .select('id')
        .eq('video_id', videoId);
    return (res as List).length;
  }

  // ─── Reviews ────────────────────────────────────────────

  /// Get reviews for the current expert.
  static Future<List<Map<String, dynamic>>> getMyReviews() async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    final res = await _client
        .from('reviews')
        .select()
        .eq('expert_id', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ─── Recent Questions (for dashboard) ──────────────────

  /// Get the most recent N questions for dashboard preview.
  static Future<List<Map<String, dynamic>>> getRecentQuestions({
    int limit = 5,
  }) async {
    final res = await _client
        .from('questions')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  // ─── Dashboard Stats ───────────────────────────────────

  /// Get dashboard stat counts.
  static Future<Map<String, int>> getDashboardStats() async {
    final uid = currentUser?.id;
    if (uid == null) {
      return {
        'total': 0,
        'answered': 0,
        'pending': 0,
        'views': 0,
        'videos': 0,
      };
    }

    final allQ = await _client.from('questions').select('id');
    final answeredQ =
        await _client.from('questions').select('id').eq('status', 'answered');
    final videos = await _client
        .from('videos')
        .select('views, video_url')
        .eq('expert_id', uid);

    final total = (allQ as List).length;
    final answered = (answeredQ as List).length;
    final videoList = videos as List;
    // Only the real uploaded videos (with a video file) count toward the
    // dashboard's Total Views — the static demo videos are excluded.
    final totalViews = videoList
        .where((v) =>
            v['video_url'] != null && (v['video_url'] as String).isNotEmpty)
        .fold<int>(
            0, (sum, v) => sum + ((v['views'] as num?)?.toInt() ?? 0));

    return {
      'total': total,
      'answered': answered,
      'pending': total - answered,
      'views': totalViews,
      'videos': videoList.length,
    };
  }
}
