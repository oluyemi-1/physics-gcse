import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  String? _displayName;
  bool _loading = false;
  String? _error;
  StreamSubscription<AuthState>? _authSub;

  User? get user => _user;
  String? get displayName => _displayName;
  bool get isGuest => _user == null;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  AuthProvider() {
    _user = supabase.auth.currentUser;
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _loadDisplayName();
      } else {
        _displayName = null;
      }
      notifyListeners();
    });
    if (_user != null) {
      _loadDisplayName();
    }
  }

  Future<void> _loadDisplayName() async {
    _displayName = await _supabaseService.getDisplayName();
    _displayName ??= _user?.email?.split('@').first;
    notifyListeners();
  }

  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      if (response.user != null) {
        await _supabaseService.createProfile(displayName);
        _displayName = displayName;
      }
      _loading = false;
      notifyListeners();
      return response.user != null;
    } on AuthException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      _loading = false;
      notifyListeners();
      return response.user != null;
    } on AuthException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (kIsWeb) {
        await supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.physicsgcse://callback',
        );
        _loading = false;
        notifyListeners();
        return true;
      } else {
        const webClientId = 'YOUR_WEB_CLIENT_ID'; // TODO: Replace
        const iosClientId = 'YOUR_IOS_CLIENT_ID'; // TODO: Replace
        final googleSignIn = GoogleSignIn(clientId: iosClientId, serverClientId: webClientId);
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          _error = 'Google sign-in cancelled';
          _loading = false;
          notifyListeners();
          return false;
        }
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        final accessToken = googleAuth.accessToken;
        if (idToken == null) {
          _error = 'Failed to get Google ID token';
          _loading = false;
          notifyListeners();
          return false;
        }
        final response = await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        if (response.user != null) {
          final name = googleUser.displayName ?? googleUser.email.split('@').first;
          await _supabaseService.createProfile(name);
          _displayName = name;
        }
        _loading = false;
        notifyListeners();
        return response.user != null;
      }
    } on AuthException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Google sign-in failed: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      _user = null;
      _displayName = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
