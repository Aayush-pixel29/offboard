import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exit_post.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/services/cache_service.dart';

class ExitPostService {
  static SupabaseClient? get _client {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Fetch posts with 0ms Offline-First Device Cache + Live Supabase Sync
  static Future<List<ExitPost>> getPosts() async {
    // 1. Immediately read from device cache for 0ms instant render
    final localCached = await CacheService.getCachedPosts();

    final client = _client;
    if (client == null) {
      return localCached;
    }

    // 2. Fetch fresh posts from Supabase in background
    try {
      final response = await client
          .from('exit_posts')
          .select()
          .eq('is_hidden', false)
          .order('created_at', ascending: false)
          .limit(50);

      final List<dynamic> data = response as List<dynamic>;
      final freshPosts =
          data.map((item) => ExitPost.fromJson(item as Map<String, dynamic>)).toList();

      if (freshPosts.isNotEmpty) {
        // Update device flash cache
        await CacheService.cachePosts(freshPosts);
        return freshPosts;
      }
    } catch (_) {
      // Return cached posts if offline
    }

    return localCached;
  }

  /// Insert a new exit autopsy post to Supabase & update local cache
  static Future<ExitPost?> insertPost(ExitPost post) async {
    final client = _client;
    if (client == null) return post;

    try {
      final response = await client
          .from('exit_posts')
          .insert(post.toJson())
          .select()
          .single();

      final created = ExitPost.fromJson(response);
      return created;
    } catch (e) {
      return post; // Fallback to memory
    }
  }

  /// Vote / React to a post using atomic RPC
  static Future<bool> reactToPost({
    required String postId,
    required String clientId,
    required String reactionType,
  }) async {
    final client = _client;
    if (client == null) return true;

    try {
      final res = await client.rpc('react_to_post', params: {
        'p_post_id': postId,
        'p_client_id': clientId,
        'p_reaction_type': reactionType,
      });
      return res['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
