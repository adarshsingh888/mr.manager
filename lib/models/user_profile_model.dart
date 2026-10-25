import 'dart:convert';

enum EducationLevel {
  tenthPass,
  twelfthPass,
  diploma,
  graduate,
  postGraduate,
  doctorate;

  String get displayName {
    switch (this) {
      case EducationLevel.tenthPass:
        return '10th / Matriculation';
      case EducationLevel.twelfthPass:
        return '12th / Intermediate';
      case EducationLevel.diploma:
        return 'Polytechnic / Diploma';
      case EducationLevel.graduate:
        return 'Bachelor’s Degree (Graduation)';
      case EducationLevel.postGraduate:
        return 'Master’s Degree (Post Graduation)';
      case EducationLevel.doctorate:
        return 'Ph.D / Doctorate';
    }
  }

  int get rank {
    switch (this) {
      case EducationLevel.tenthPass:
        return 1;
      case EducationLevel.twelfthPass:
        return 2;
      case EducationLevel.diploma:
        return 3;
      case EducationLevel.graduate:
        return 4;
      case EducationLevel.postGraduate:
        return 5;
      case EducationLevel.doctorate:
        return 6;
    }
  }
}

class UserProfile {
  final String name;
  final DateTime dateOfBirth;
  final String category; // General, OBC, SC, ST, EWS
  final String gender; // Male, Female, Other
  final EducationLevel highestEducation;
  final String degreeName; // e.g. B.Tech, B.Sc, B.Com, BA, LLB, MBBS
  final String stream; // e.g. Computer Science, Mechanical, Commerce, General
  final double percentage;
  final String domicileState;
  final bool isPwd;
  final bool isExServiceman;
  final List<String> preferredSectors;

  UserProfile({
    required this.name,
    required this.dateOfBirth,
    required this.category,
    required this.gender,
    required this.highestEducation,
    this.degreeName = 'Bachelor of Science (B.Sc)',
    this.stream = 'General',
    this.percentage = 65.0,
    this.domicileState = 'Delhi',
    this.isPwd = false,
    this.isExServiceman = false,
    this.preferredSectors = const ['Civil Services', 'Staff Selection (SSC)', 'Banking', 'Railways', 'Defence'],
  });

  int get currentAge {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  int getAgeAsOf(DateTime referenceDate) {
    int age = referenceDate.year - dateOfBirth.year;
    if (referenceDate.month < dateOfBirth.month ||
        (referenceDate.month == dateOfBirth.month && referenceDate.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Age relaxation in years based on Indian Gov norms
  int get categoryAgeRelaxationYears {
    int relaxation = 0;
    if (category == 'OBC') relaxation += 3;
    if (category == 'SC' || category == 'ST') relaxation += 5;
    if (isPwd) relaxation += 10;
    if (isExServiceman) relaxation += 3;
    return relaxation;
  }

  UserProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? category,
    String? gender,
    EducationLevel? highestEducation,
    String? degreeName,
    String? stream,
    double? percentage,
    String? domicileState,
    bool? isPwd,
    bool? isExServiceman,
    List<String>? preferredSectors,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      highestEducation: highestEducation ?? this.highestEducation,
      degreeName: degreeName ?? this.degreeName,
      stream: stream ?? this.stream,
      percentage: percentage ?? this.percentage,
      domicileState: domicileState ?? this.domicileState,
      isPwd: isPwd ?? this.isPwd,
      isExServiceman: isExServiceman ?? this.isExServiceman,
      preferredSectors: preferredSectors ?? this.preferredSectors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'category': category,
      'gender': gender,
      'highestEducation': highestEducation.index,
      'degreeName': degreeName,
      'stream': stream,
      'percentage': percentage,
      'domicileState': domicileState,
      'isPwd': isPwd,
      'isExServiceman': isExServiceman,
      'preferredSectors': preferredSectors,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Candidate',
      dateOfBirth: DateTime.tryParse(map['dateOfBirth'] ?? '') ?? DateTime(2001, 5, 15),
      category: map['category'] ?? 'General',
      gender: map['gender'] ?? 'Male',
      highestEducation: EducationLevel.values[map['highestEducation'] ?? EducationLevel.graduate.index],
      degreeName: map['degreeName'] ?? 'Bachelor’s Degree',
      stream: map['stream'] ?? 'General',
      percentage: (map['percentage'] as num?)?.toDouble() ?? 65.0,
      domicileState: map['domicileState'] ?? 'Delhi',
      isPwd: map['isPwd'] ?? false,
      isExServiceman: map['isExServiceman'] ?? false,
      preferredSectors: List<String>.from(map['preferredSectors'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));

  static UserProfile defaultProfile() {
    return UserProfile(
      name: 'Aditya Sharma',
      dateOfBirth: DateTime(2001, 8, 20), // ~25 years old in 2026
      category: 'OBC',
      gender: 'Male',
      highestEducation: EducationLevel.graduate,
      degreeName: 'B.Tech / B.E.',
      stream: 'Engineering / General',
      percentage: 72.5,
      domicileState: 'Uttar Pradesh',
      isPwd: false,
      isExServiceman: false,
      preferredSectors: ['Civil Services', 'Staff Selection (SSC)', 'Banking', 'Railways', 'Defence'],
    );
  }
}
