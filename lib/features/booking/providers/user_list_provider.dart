import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_list_repository.dart';
import '../data/user_list_model.dart';

final userListRepositoryProvider = Provider<UserListRepository>((ref) {
  return UserListRepository();
});

final userListsProvider = FutureProvider<List<UserList>>((ref) async {
  final repository = ref.read(userListRepositoryProvider);
  return await repository.getUserLists();
});

final selectedUsersProvider = StateProvider.family<List<UserList>, int>((
  ref,
  userId,
) {
  // Get the current user as default
  final currentUserAsync = ref.watch(currentUserProvider(userId));
  return currentUserAsync.when(
    data: (currentUser) => [currentUser],
    loading: () => [],
    error: (_, __) => [],
  );
});

final visibleUsersProvider = StateProvider.family<List<UserList>, int>((
  ref,
  userId,
) {
  // Get the current user as default
  final currentUserAsync = ref.watch(currentUserProvider(userId));
  return currentUserAsync.when(
    data: (currentUser) => [currentUser],
    loading: () => [],
    error: (_, __) => [],
  );
});

final currentUserProvider = FutureProvider.family<UserList, int>((
  ref,
  userId,
) async {
  final repository = ref.read(userListRepositoryProvider);
  return await repository.getCurrentUser(userId);
});

final addNewUserProvider =
    FutureProvider.family<UserList, Map<String, dynamic>>((
      ref,
      userData,
    ) async {
      final repository = ref.read(userListRepositoryProvider);
      return await repository.addNewUser(userData);
    });

final updateUserProvider =
    FutureProvider.family<
      UserList,
      ({int userId, Map<String, dynamic> userData})
    >((ref, params) async {
      final repository = ref.read(userListRepositoryProvider);
      return await repository.updateUser(params.userId, params.userData);
    });
