import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole {
  lead('Lead', 'Engineering Lead', 'Full oversight, deploy approvals, on-call manager'),
  developer('Developer', 'Software Engineer', 'Code commits, deploy requests, work logs'),
  qa('QA Engineer', 'QA / Test Engineer', 'Test verification, bug reports, release sign-offs');

  final String title;
  final String label;
  final String description;
  const UserRole(this.title, this.label, this.description);
}

class UserSession extends ChangeNotifier {
  static final UserSession instance = UserSession._internal();
  UserSession._internal();

  bool _isAuthenticated = false;
  String _username = 'sarahchen';
  String _displayName = 'Sarah Chen';
  final String _avatarUrl = '';
  UserRole _role = UserRole.developer;
  String _workspace = 'acme-platform';
  List<String> _selectedRepos = ['devops-api', 'mobile-client'];
  String _githubToken = '';

  bool get isAuthenticated => _isAuthenticated;
  String get username => _username;
  String get displayName => _displayName;
  String get avatarUrl => _avatarUrl;
  UserRole get role => _role;
  String get workspace => _workspace;
  List<String> get selectedRepos => _selectedRepos;
  String get githubToken => _githubToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    _username = prefs.getString('username') ?? 'sarahchen';
    _displayName = prefs.getString('display_name') ?? 'Sarah Chen';
    _workspace = prefs.getString('workspace') ?? 'acme-platform';
    _githubToken = prefs.getString('github_token') ?? '';
    
    final roleString = prefs.getString('user_role') ?? 'developer';
    _role = UserRole.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () => UserRole.developer,
    );
    notifyListeners();
  }

  Future<void> signIn({
    required String username,
    required String displayName,
    required UserRole role,
    String? token,
  }) async {
    _isAuthenticated = true;
    _username = username;
    _displayName = displayName;
    _role = role;
    if (token != null) _githubToken = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
    await prefs.setString('username', _username);
    await prefs.setString('display_name', _displayName);
    await prefs.setString('user_role', _role.name);
    await prefs.setString('workspace', _workspace);
    if (token != null) await prefs.setString('github_token', token);

    notifyListeners();
  }

  Future<void> setRole(UserRole newRole) async {
    _role = newRole;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _role.name);
    notifyListeners();
  }

  Future<void> setWorkspaceAndRepos(String workspace, List<String> repos) async {
    _workspace = workspace;
    _selectedRepos = repos;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workspace', workspace);
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_authenticated');
    notifyListeners();
  }
}
