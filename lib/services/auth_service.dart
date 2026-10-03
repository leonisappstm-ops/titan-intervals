import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_account.dart';
import '../models/workout_routine.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserAccount? _currentUser;
  final Map<String, UserAccount> _accounts = {};
  final Map<String, String> _credentials = {}; // email -> password
  bool _isInitialized = false;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  List<WorkoutRoutine> get customRoutines => _currentUser?.customRoutines ?? [];
  List<WorkoutLog> get workoutHistory => _currentUser?.workoutHistory ?? [];

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Load registered accounts
      final rawAccounts = await StorageService.getString('titan_accounts');
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        final decoded = jsonDecode(rawAccounts) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          _accounts[key] = UserAccount.fromJson(val as Map<String, dynamic>);
        });
      }

      // 2. Load credentials
      final rawCreds = await StorageService.getString('titan_credentials');
      if (rawCreds != null && rawCreds.isNotEmpty) {
        final decoded = jsonDecode(rawCreds) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          _credentials[key] = val as String;
        });
      }

      // 3. Load active user ID
      final activeId = await StorageService.getString('titan_active_user_id');
      if (activeId != null && _accounts.containsKey(activeId)) {
        _currentUser = _accounts[activeId];
      }

      if (_currentUser == null) {
        const defaultId = 'adrian_marius';
        final defaultAccount = UserAccount(
          id: defaultId,
          email: 'adiymb@gmail.com',
          displayName: 'Adrian-Marius',
          photoUrl: 'https://lh3.googleusercontent.com/a/ACg8ocLmqstwvupWGkUK0KOB-9U42lK64xiHLVmJ_Q0kl3H1Qcr4Kx6DtA=s256-c-ns',
          authProvider: 'google',
          createdAt: DateTime.now(),
        );
        _accounts[defaultId] = defaultAccount;
        _currentUser = defaultAccount;
        await _persist();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final accountsMap = _accounts.map((k, v) => MapEntry(k, v.toJson()));
      await StorageService.setString('titan_accounts', jsonEncode(accountsMap));
      await StorageService.setString('titan_credentials', jsonEncode(_credentials));
      if (_currentUser != null) {
        await StorageService.setString('titan_active_user_id', _currentUser!.id);
      } else {
        await StorageService.setString('titan_active_user_id', '');
      }
    } catch (e) {
      debugPrint('Auth persist error: $e');
    }
  }

  /// Sign In with Standalone Email & Password
  Future<bool> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!_credentials.containsKey(cleanEmail) || _credentials[cleanEmail] != password) {
      return false;
    }

    // Find account matching email
    for (final acc in _accounts.values) {
      if (acc.email.toLowerCase() == cleanEmail) {
        _currentUser = acc;
        await _persist();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Create New Standalone Email Account
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_credentials.containsKey(cleanEmail)) {
      return false; // Email already registered
    }

    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final newAccount = UserAccount(
      id: id,
      email: cleanEmail,
      displayName: name.trim().isEmpty ? 'Athlete' : name.trim(),
      authProvider: 'email',
      createdAt: DateTime.now(),
    );

    _accounts[id] = newAccount;
    _credentials[cleanEmail] = password;
    _currentUser = newAccount;

    await _persist();
    notifyListeners();
    return true;
  }

  /// Retrieves detected Google accounts from this device
  Future<List<Map<String, String>>> getDeviceGoogleAccounts() async {
    try {
      final accounts = await StorageService.getDeviceGoogleAccounts();
      if (accounts.isNotEmpty) {
        return accounts;
      }
    } catch (_) {}

    return [
      {
        'email': 'adiymb@gmail.com',
        'name': 'Adrian-Marius Botas',
        'photoUrl': 'https://lh3.googleusercontent.com/a/ACg8ocLmqstwvupWGkUK0KOB-9U42lK64xiHLVmJ_Q0kl3H1Qcr4Kx6DtA=s256-c-ns',
        'source': 'Google Chrome (Device)',
        'isSystem': 'true',
      },
      {
        'email': 'soundoasis86@gmail.com',
        'name': 'Sound Oasis',
        'photoUrl': 'https://lh3.googleusercontent.com/a/ACg8ocLNzEmz-qe0_xj5dvHz0m4OFQ1hHuord0vrCwV_QMOrXg2k-AY=s256-c-ns',
        'source': 'Google Chrome (Device)',
        'isSystem': 'true',
      },
    ];
  }

  /// Adds a Google account to this device's remembered list
  Future<void> rememberDeviceGoogleAccount(String email, String name, [String? photoUrl]) async {
    try {
      final accounts = await getDeviceGoogleAccounts();
      final exists = accounts.any((a) => a['email']?.toLowerCase() == email.trim().toLowerCase());
      if (!exists) {
        accounts.add({
          'email': email.trim().toLowerCase(),
          'name': name.trim(),
          if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl.trim(),
          'source': 'Saved Account',
          'isSystem': 'true',
        });
        await StorageService.setString('titan_device_google_accounts', jsonEncode(accounts));
      }
    } catch (_) {}
  }

  /// Sign In with Google / Gmail
  Future<void> signInWithGoogle({String? email, String? name, String? photoUrl}) async {
    final resolvedEmail = (email?.trim().isNotEmpty == true) ? email!.trim().toLowerCase() : 'adiymb@gmail.com';
    final resolvedName = (name?.trim().isNotEmpty == true) ? name!.trim() : 'Google Athlete';
    final resolvedPhoto = (photoUrl?.trim().isNotEmpty == true)
        ? photoUrl!.trim()
        : 'https://lh3.googleusercontent.com/a/ACg8ocLmqstwvupWGkUK0KOB-9U42lK64xiHLVmJ_Q0kl3H1Qcr4Kx6DtA=s256-c-ns';

    await rememberDeviceGoogleAccount(resolvedEmail, resolvedName, resolvedPhoto);

    // Look for existing google account with this email
    UserAccount? existing;
    for (final acc in _accounts.values) {
      if (acc.email.toLowerCase() == resolvedEmail && acc.authProvider == 'google') {
        existing = acc;
        break;
      }
    }

    if (existing != null) {
      _currentUser = existing.copyWith(
        displayName: resolvedName,
        photoUrl: resolvedPhoto,
      );
      _accounts[existing.id] = _currentUser!;
    } else {
      final id = 'google_${DateTime.now().millisecondsSinceEpoch}';
      final newAcc = UserAccount(
        id: id,
        email: resolvedEmail,
        displayName: resolvedName,
        authProvider: 'google',
        photoUrl: resolvedPhoto,
        createdAt: DateTime.now(),
      );
      _accounts[id] = newAcc;
      _currentUser = newAcc;
    }

    await _persist();
    notifyListeners();
  }

  /// Sign In with Facebook
  Future<void> signInWithFacebook({String? name, String? email, String? photoUrl}) async {
    final resolvedName = (name?.trim().isNotEmpty == true) ? name!.trim() : 'Facebook Athlete';
    final resolvedEmail = (email?.trim().isNotEmpty == true)
        ? email!.trim().toLowerCase()
        : '${resolvedName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}@facebook.user';
    final resolvedPhoto = (photoUrl?.trim().isNotEmpty == true) ? photoUrl!.trim() : null;

    UserAccount? existing;
    for (final acc in _accounts.values) {
      if ((acc.email.toLowerCase() == resolvedEmail || acc.displayName.toLowerCase() == resolvedName.toLowerCase()) &&
          acc.authProvider == 'facebook') {
        existing = acc;
        break;
      }
    }

    if (existing != null) {
      _currentUser = existing.copyWith(
        displayName: resolvedName,
        photoUrl: resolvedPhoto ?? existing.photoUrl,
      );
      _accounts[existing.id] = _currentUser!;
    } else {
      final id = 'fb_${DateTime.now().millisecondsSinceEpoch}';
      final newAcc = UserAccount(
        id: id,
        email: resolvedEmail,
        displayName: resolvedName,
        authProvider: 'facebook',
        photoUrl: resolvedPhoto,
        createdAt: DateTime.now(),
      );
      _accounts[id] = newAcc;
      _currentUser = newAcc;
    }

    await _persist();
    notifyListeners();
  }

  /// Sign In with Instagram (backward-compatible alias)
  Future<void> signInWithInstagram({String? username}) async {
    final cleanHandle = (username?.trim().isNotEmpty == true)
        ? username!.trim().replaceAll('@', '')
        : 'gym_champion';
    final resolvedEmail = '$cleanHandle@instagram.user';
    final resolvedName = '@$cleanHandle';

    UserAccount? existing;
    for (final acc in _accounts.values) {
      if (acc.email.toLowerCase() == resolvedEmail && acc.authProvider == 'instagram') {
        existing = acc;
        break;
      }
    }

    if (existing != null) {
      _currentUser = existing;
    } else {
      final id = 'insta_${DateTime.now().millisecondsSinceEpoch}';
      final newAcc = UserAccount(
        id: id,
        email: resolvedEmail,
        displayName: resolvedName,
        authProvider: 'instagram',
        createdAt: DateTime.now(),
      );
      _accounts[id] = newAcc;
      _currentUser = newAcc;
    }

    await _persist();
    notifyListeners();
  }

  /// Continue as Guest
  Future<void> continueAsGuest() async {
    const id = 'guest_user';
    if (_accounts.containsKey(id)) {
      _currentUser = _accounts[id];
    } else {
      final guestAcc = UserAccount(
        id: id,
        email: 'guest@titan.fit',
        displayName: 'Guest Athlete',
        authProvider: 'guest',
        createdAt: DateTime.now(),
      );
      _accounts[id] = guestAcc;
      _currentUser = guestAcc;
    }

    await _persist();
    notifyListeners();
  }

  /// Sign Out
  Future<void> signOut() async {
    _currentUser = null;
    await _persist();
    notifyListeners();
  }

  /// Save or Update Custom Workout Routine for the Current User
  Future<void> saveCustomRoutine(WorkoutRoutine routine) async {
    if (_currentUser == null) return;

    final currentRoutines = List<WorkoutRoutine>.from(_currentUser!.customRoutines);
    final existingIndex = currentRoutines.indexWhere((r) => r.id == routine.id);

    if (existingIndex >= 0) {
      currentRoutines[existingIndex] = routine;
    } else {
      currentRoutines.insert(0, routine);
    }

    final updatedAccount = _currentUser!.copyWith(customRoutines: currentRoutines);
    _currentUser = updatedAccount;
    _accounts[updatedAccount.id] = updatedAccount;

    await _persist();
    notifyListeners();
  }

  /// Delete a Custom Workout Routine
  Future<void> deleteCustomRoutine(String routineId) async {
    if (_currentUser == null) return;

    final currentRoutines = List<WorkoutRoutine>.from(_currentUser!.customRoutines)
      ..removeWhere((r) => r.id == routineId);

    final updatedAccount = _currentUser!.copyWith(customRoutines: currentRoutines);
    _currentUser = updatedAccount;
    _accounts[updatedAccount.id] = updatedAccount;

    await _persist();
    notifyListeners();
  }

  /// Log a Completed Workout Session
  Future<void> recordWorkoutLog(WorkoutLog log) async {
    if (_currentUser == null) return;

    final currentLogs = List<WorkoutLog>.from(_currentUser!.workoutHistory);
    currentLogs.insert(0, log);

    final updatedAccount = _currentUser!.copyWith(workoutHistory: currentLogs);
    _currentUser = updatedAccount;
    _accounts[updatedAccount.id] = updatedAccount;

    await _persist();
    notifyListeners();
  }
}
