import '../datasources/local_database.dart';
import '../models/user_profile.dart';

class UserRepository {
  static const _collection = 'users';

  Future<UserProfile?> getUser(String uid) async {
    final items = await LocalDatabase.readAll(_collection);
    final match = items.where((e) => e['uid'] == uid);
    if (match.isEmpty) return null;
    return UserProfile.fromJson(match.first);
  }

  Future<void> saveUser(UserProfile user) async {
    final items = await LocalDatabase.readAll(_collection);
    items.removeWhere((e) => e['uid'] == user.uid);
    items.add(user.toJson());
    await LocalDatabase.writeAll(_collection, items);
  }

  Future<void> deleteUser(String uid) async {
    final items = await LocalDatabase.readAll(_collection);
    items.removeWhere((e) => e['uid'] == uid);
    await LocalDatabase.writeAll(_collection, items);
  }
}
