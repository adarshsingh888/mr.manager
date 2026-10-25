import 'dart:convert';
import 'user_profile_model.dart';

enum ApplicationStage {
  none,
  saved,
  applied,
  admitCardDownloaded,
  appeared,
  qualified;

  String get label {
    switch (this) {
      case ApplicationStage.none:
        return 'Not Applied';
      case ApplicationStage.saved:
        return 'Saved / Considering';
      case ApplicationStage.applied:
        return 'Form Submitted';
      case ApplicationStage.admitCardDownloaded:
        return 'Admit Card Ready';
      case ApplicationStage.appeared:
        return 'Exam Appeared';
      case ApplicationStage.qualified:
        return 'Qualified / Selected';
    }
  }
}

enum JobSector {
  centralGov,
  ssc,
  upsc,
  railway,
  banking,
  defence,
  statePsc,
  psu,
  teaching;

  String get displayName {
    switch (this) {
      case JobSector.centralGov:
        return 'Central Govt';
      case JobSector.ssc:
        return 'SSC';
      case JobSector.upsc:
        return 'UPSC';
      case JobSector.railway:
        return 'Railways (RRB)';
      case JobSector.banking:
        return 'Banking (IBPS/SBI)';
      case JobSector.defence:
        return 'Defence (Army/Navy/AF)';
      case JobSector.statePsc:
        return 'State PSC';
      case JobSector.psu:
        return 'PSU / Technical';
      case JobSector.teaching:
        return 'Teaching / Education';
    }
  }
}

class JobModel {
  final String id;
  final String title;
  final String organization; // e.g. Staff Selection Commission
  final String postName; // e.g. CGL (Assistant Section Officer, Inspector)
  final JobSector sector;
  final int totalVacancies;
  final String state; // "All India" or State Name
  
  // Eligibility criteria
  final int minAge;
  final int maxAgeGeneral;
  final EducationLevel minEducation;
  final List<String> eligibleDegrees; // empty means any recognized degree
  final double minPercentage;
  final String genderConstraint; // "All", "Male", "Female"
  
  // Important Dates
  final DateTime applicationStartDate;
  final DateTime applicationEndDate;
  final DateTime? admitCardReleaseDate;
  final DateTime? examDate;
  final DateTime? examEndDate;
  final DateTime? resultDate;

  // Compensation & Details
  final String payScale; // e.g. "Pay Level 7 (₹44,900 - ₹1,42,400)"
  final String applicationFee; // e.g. "₹100 (Exempted for Women/SC/ST)"
  final String officialWebsite;
  final String applyUrl;
  final String? admitCardUrl;
  final String? notificationPdfUrl;
  final String syllabusSummary;
  final List<String> examStages; // e.g. ["Tier 1: Prelims", "Tier 2: Mains", "Document Verification"]

  // User state
  bool isBookmarked;
  ApplicationStage trackingStage;
  String? applicationNumber;
  String? rollNumber;

  JobModel({
    required this.id,
    required this.title,
    required this.organization,
    required this.postName,
    required this.sector,
    required this.totalVacancies,
    required this.state,
    required this.minAge,
    required this.maxAgeGeneral,
    required this.minEducation,
    this.eligibleDegrees = const [],
    this.minPercentage = 0.0,
    this.genderConstraint = 'All',
    required this.applicationStartDate,
    required this.applicationEndDate,
    this.admitCardReleaseDate,
    this.examDate,
    this.examEndDate,
    this.resultDate,
    required this.payScale,
    required this.applicationFee,
    required this.officialWebsite,
    required this.applyUrl,
    this.admitCardUrl,
    this.notificationPdfUrl,
    required this.syllabusSummary,
    this.examStages = const [],
    this.isBookmarked = false,
    this.trackingStage = ApplicationStage.none,
    this.applicationNumber,
    this.rollNumber,
  });

  bool get isApplicationOpen {
    final now = DateTime.now();
    return now.isAfter(applicationStartDate.subtract(const Duration(seconds: 1))) &&
           now.isBefore(applicationEndDate.add(const Duration(days: 1)));
  }

  int get daysRemainingForApplication {
    final now = DateTime.now();
    return applicationEndDate.difference(now).inDays;
  }

  int? get daysUntilExam {
    if (examDate == null) return null;
    return examDate!.difference(DateTime.now()).inDays;
  }

  bool get isAdmitCardReleased {
    if (admitCardReleaseDate == null) return false;
    return DateTime.now().isAfter(admitCardReleaseDate!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'postName': postName,
      'sector': sector.index,
      'totalVacancies': totalVacancies,
      'state': state,
      'minAge': minAge,
      'maxAgeGeneral': maxAgeGeneral,
      'minEducation': minEducation.index,
      'eligibleDegrees': eligibleDegrees,
      'minPercentage': minPercentage,
      'genderConstraint': genderConstraint,
      'applicationStartDate': applicationStartDate.toIso8601String(),
      'applicationEndDate': applicationEndDate.toIso8601String(),
      'admitCardReleaseDate': admitCardReleaseDate?.toIso8601String(),
      'examDate': examDate?.toIso8601String(),
      'examEndDate': examEndDate?.toIso8601String(),
      'resultDate': resultDate?.toIso8601String(),
      'payScale': payScale,
      'applicationFee': applicationFee,
      'officialWebsite': officialWebsite,
      'applyUrl': applyUrl,
      'admitCardUrl': admitCardUrl,
      'notificationPdfUrl': notificationPdfUrl,
      'syllabusSummary': syllabusSummary,
      'examStages': examStages,
      'isBookmarked': isBookmarked,
      'trackingStage': trackingStage.index,
      'applicationNumber': applicationNumber,
      'rollNumber': rollNumber,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'],
      title: map['title'],
      organization: map['organization'],
      postName: map['postName'],
      sector: JobSector.values[map['sector'] ?? 0],
      totalVacancies: map['totalVacancies'] ?? 0,
      state: map['state'] ?? 'All India',
      minAge: map['minAge'] ?? 18,
      maxAgeGeneral: map['maxAgeGeneral'] ?? 30,
      minEducation: EducationLevel.values[map['minEducation'] ?? EducationLevel.graduate.index],
      eligibleDegrees: List<String>.from(map['eligibleDegrees'] ?? []),
      minPercentage: (map['minPercentage'] as num?)?.toDouble() ?? 0.0,
      genderConstraint: map['genderConstraint'] ?? 'All',
      applicationStartDate: DateTime.parse(map['applicationStartDate']),
      applicationEndDate: DateTime.parse(map['applicationEndDate']),
      admitCardReleaseDate: map['admitCardReleaseDate'] != null
          ? DateTime.tryParse(map['admitCardReleaseDate'])
          : null,
      examDate: map['examDate'] != null ? DateTime.tryParse(map['examDate']) : null,
      examEndDate: map['examEndDate'] != null ? DateTime.tryParse(map['examEndDate']) : null,
      resultDate: map['resultDate'] != null ? DateTime.tryParse(map['resultDate']) : null,
      payScale: map['payScale'] ?? '',
      applicationFee: map['applicationFee'] ?? '',
      officialWebsite: map['officialWebsite'] ?? '',
      applyUrl: map['applyUrl'] ?? '',
      admitCardUrl: map['admitCardUrl'],
      notificationPdfUrl: map['notificationPdfUrl'],
      syllabusSummary: map['syllabusSummary'] ?? '',
      examStages: List<String>.from(map['examStages'] ?? []),
      isBookmarked: map['isBookmarked'] ?? false,
      trackingStage: ApplicationStage.values[map['trackingStage'] ?? 0],
      applicationNumber: map['applicationNumber'],
      rollNumber: map['rollNumber'],
    );
  }

  String toJson() => json.encode(toMap());

  factory JobModel.fromJson(String source) => JobModel.fromMap(json.decode(source));
}
