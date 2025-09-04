import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/home_repository.dart';
import '../data/models/home_pooja_category_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/song_repository.dart';
import '../data/models/song_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

final songRepositoryProvider = Provider<SongRepository>(
  (ref) => SongRepository(),
);

final homePoojaCategoriesProvider = FutureProvider<HomePoojaCategoryResponse>((
  ref,
) async {
  final repository = ref.read(homeRepositoryProvider);
  return await repository.fetchPoojaCategories();
});

final profileProvider = FutureProvider<ProfileResponse>((ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return await repository.fetchProfile();
});

final songProvider = FutureProvider<SongResponse>((ref) async {
  final repository = ref.read(songRepositoryProvider);
  return await repository.fetchSong(14); // Using song ID 14 as specified
});
