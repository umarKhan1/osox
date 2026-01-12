import 'package:get_it/get_it.dart';
import 'package:osox/features/posts/data/repositories/post_repository.dart';

final getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  // Repositories
  getIt.registerLazySingleton(PostRepository.new);
}
