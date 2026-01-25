import 'package:get_it/get_it.dart';
import 'package:osox/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:osox/features/auth/domain/repositories/auth_repository.dart';
import 'package:osox/features/chat/data/repositories/supabase_chat_repository.dart';
import 'package:osox/features/chat/domain/repositories/chat_repository.dart';
import 'package:osox/features/home/data/repositories/supabase_home_repository.dart';
import 'package:osox/features/home/domain/repositories/home_repository.dart';
import 'package:osox/features/posts/data/repositories/supabase_comment_repository.dart';
import 'package:osox/features/posts/data/repositories/supabase_post_repository.dart';
import 'package:osox/features/posts/domain/repositories/comment_repository.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:osox/features/profile/data/repositories/supabase_profile_repository.dart';
import 'package:osox/features/profile/domain/repositories/profile_repository.dart';
import 'package:osox/features/search/data/repositories/supabase_search_repository.dart';
import 'package:osox/features/search/domain/repositories/search_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  getIt
    ..registerLazySingleton<SupabaseClient>(() => Supabase.instance.client)
    ..registerLazySingleton<IPostRepository>(
      () => SupabasePostRepository(getIt<SupabaseClient>()),
    )
    ..registerLazySingleton<ICommentRepository>(
      () => SupabaseCommentRepository(
        getIt<SupabaseClient>(),
        getIt<IPostRepository>(),
      ),
    )
    ..registerLazySingleton<IHomeRepository>(
      () => SupabaseHomeRepository(getIt<SupabaseClient>()),
    )
    ..registerLazySingleton<IAuthRepository>(
      () => SupabaseAuthRepository(getIt<SupabaseClient>()),
    )
    ..registerLazySingleton<ISearchRepository>(
      () => SupabaseSearchRepository(getIt<SupabaseClient>()),
    )
    ..registerLazySingleton<IProfileRepository>(
      () => SupabaseProfileRepository(getIt<SupabaseClient>()),
    )
    ..registerLazySingleton<IChatRepository>(
      () => SupabaseChatRepository(getIt<SupabaseClient>()),
    );
}
