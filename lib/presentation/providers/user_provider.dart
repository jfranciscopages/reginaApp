import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userNameProvider = StateNotifierProvider<
  UserNameNotifier,
  AsyncValue<String?>
>((ref) => UserNameNotifier(FirebaseAuth.instance, FirebaseFirestore.instance));

class UserNameNotifier extends StateNotifier<AsyncValue<String?>> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  late final StreamSubscription<User?> _sub;

  UserNameNotifier(this._auth, this._db) : super(const AsyncValue.loading()) {
    _sub = _auth.authStateChanges().listen(_handleAuthChange);
    _handleAuthChange(_auth.currentUser);
  }

  Future<void> _handleAuthChange(User? user) async {
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final userName = doc.data()?['nombre'] as String?;
      state = AsyncValue.data(userName);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => _handleAuthChange(_auth.currentUser);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
