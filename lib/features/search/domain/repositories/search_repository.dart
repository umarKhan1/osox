import 'package:osox/features/search/domain/models/user_search_result.dart';

// ignore: one_member_abstracts
abstract class ISearchRepository {
  Future<List<UserSearchResult>> searchUsers(String query);
}
