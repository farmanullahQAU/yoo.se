import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  BehaviorSubject<User> _user = BehaviorSubject();
  Observable<User> get stream$ => _user.stream;
  User get current => _user.value;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    _user.addStream(_auth.authStateChanges());
  }
  Future<UserCredential> regUser() async {
    return await _auth.signInAnonymously();
  }
}
