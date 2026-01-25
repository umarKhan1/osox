import 'package:osox/features/search/domain/models/user_search_result.dart';
import 'package:osox/features/search/domain/repositories/search_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSearchRepository implements ISearchRepository {
  SupabaseSearchRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];

      // Search profiles by full_name, exclude current user
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, email, avatar_url')
          .ilike('full_name', '%$query%')
          .neq('id', currentUser.id)
          .limit(20)
          .order('full_name');

      return (response as List)
          .map(
            (json) => UserSearchResult.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
