import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _user = UserProfile.defaultProfile();
  bool _isLoaded = false;

  UserProfile get user => _user;
  bool get isLoaded => _isLoaded;

  ProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('mr_manager_user_profile');
      if (profileJson != null) {
        _user = UserProfile.fromJson(profileJson);
      }
    } catch (e) {
      // Fallback to default
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    _user = updated;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mr_manager_user_profile', _user.toJson());
    } catch (e) {
      // Local fallback
    }
  }

  Future<void> updateBasicDetails({
    required String name,
    required DateTime dob,
    required String category,
    required String gender,
    required String domicileState,
    required bool isPwd,
    required bool isExServiceman,
  }) async {
    _user = _user.copyWith(
      name: name,
      dateOfBirth: dob,
      category: category,
      gender: gender,
      domicileState: domicileState,
      isPwd: isPwd,
      isExServiceman: isExServiceman,
    );
    await updateProfile(_user);
  }

  Future<void> updateEducation({
    required EducationLevel highestEducation,
    required String degreeName,
    required String stream,
    required double percentage,
  }) async {
    _user = _user.copyWith(
      highestEducation: highestEducation,
      degreeName: degreeName,
      stream: stream,
      percentage: percentage,
    );
    await updateProfile(_user);
  }
}
