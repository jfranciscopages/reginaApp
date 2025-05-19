import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  final _auth = FirebaseAuth.instance;

  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e.message ?? 'Error desconocido', StackTrace.current);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      state = const AsyncData(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e.message ?? 'Error desconocido', StackTrace.current);
    }
  }

  Future<void> logout() async {
  state = const AsyncLoading();
  try {
    await _auth.signOut();
    state = const AsyncData(null);
  } catch (e, st) {
    state = AsyncError(e, st);
  }
}
}
