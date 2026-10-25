import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/user_profile_model.dart';
import '../models/calendar_event_model.dart';
import 'eligibility_engine.dart';

class JobRepository extends ChangeNotifier {
  List<JobModel> _jobs = [];
  bool _isLoading = false;
  String _searchQuery = '';
  JobSector? _selectedSector;
  bool _onlyEligibleFilter = false;

  List<JobModel> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  JobSector? get selectedSector => _selectedSector;
  bool get onlyEligibleFilter => _onlyEligibleFilter;

  JobRepository() {
    _initializeJobs();
  }

  void _initializeJobs() {
    final now = DateTime.now();

    _jobs = [
      JobModel(
        id: 'ssc_cgl_2026',
        title: 'SSC CGL 2026 (Combined Graduate Level)',
        organization: 'Staff Selection Commission (SSC)',
        postName: 'Assistant Section Officer, Inspector (GST/IT), Sub-Inspector (CBI), Tax Assistant',
        sector: JobSector.ssc,
        totalVacancies: 14250,
        state: 'All India',
        minAge: 18,
        maxAgeGeneral: 30,
        minEducation: EducationLevel.graduate,
        eligibleDegrees: [],
        minPercentage: 0.0,
        applicationStartDate: now.subtract(const Duration(days: 12)),
        applicationEndDate: now.add(const Duration(days: 8)), // Closing soon!
        admitCardReleaseDate: now.add(const Duration(days: 42)),
        examDate: now.add(const Duration(days: 52)),
        examEndDate: now.add(const Duration(days: 64)),
        resultDate: now.add(const Duration(days: 110)),
        payScale: 'Level 4 to Level 7 (₹25,500 - ₹1,42,400)',
        applicationFee: '₹100 (Exempted for Women, SC, ST, PwD, ESM)',
        officialWebsite: 'https://ssc.gov.in',
        applyUrl: 'https://ssc.gov.in/apply-cgl',
        admitCardUrl: 'https://ssc.gov.in/admit-card',
        syllabusSummary: 'Tier 1: General Intelligence, General Awareness, Quantitative Aptitude, English Comprehension. Tier 2: Mathematical Abilities, Reasoning, English, General Awareness, Computer Knowledge.',
        examStages: ['Tier-1 Computer Based Exam', 'Tier-2 Mains Exam', 'Computer Proficiency & Typing Test', 'Document Verification'],
        isBookmarked: true,
        trackingStage: ApplicationStage.applied,
        applicationNumber: 'SSC-CGL-2026-89472',
      ),
      JobModel(
        id: 'upsc_cse_2026',
        title: 'UPSC Civil Services Examination (IAS / IPS / IFS) 2026',
        organization: 'Union Public Service Commission',
        postName: 'Indian Administrative Service, Indian Police Service, Indian Foreign Service, Central Group A',
        sector: JobSector.upsc,
        totalVacancies: 1120,
        state: 'All India',
        minAge: 21,
        maxAgeGeneral: 32,
        minEducation: EducationLevel.graduate,
        eligibleDegrees: [],
        minPercentage: 0.0,
        applicationStartDate: now.subtract(const Duration(days: 5)),
        applicationEndDate: now.add(const Duration(days: 25)),
        admitCardReleaseDate: now.add(const Duration(days: 75)),
        examDate: now.add(const Duration(days: 90)), // Prelims
        examEndDate: now.add(const Duration(days: 90)),
        resultDate: now.add(const Duration(days: 130)),
        payScale: 'Pay Level 10 (₹56,100 - ₹2,50,000+ per month)',
        applicationFee: '₹100 (Free for Female/SC/ST/Persons with Benchmark Disability)',
        officialWebsite: 'https://upsc.gov.in',
        applyUrl: 'https://upsconline.nic.in',
        syllabusSummary: 'Prelims: Paper I (General Studies - 200 Marks) + Paper II (CSAT - qualifying 33%). Mains: 9 descriptive papers including Essay, GS I-IV, and Optional Subject.',
        examStages: ['Civil Services Preliminary (Objective)', 'Civil Services Main (Descriptive)', 'Personality Test / Interview'],
        isBookmarked: true,
        trackingStage: ApplicationStage.saved,
      ),
      JobModel(
        id: 'ibps_po_2026',
        title: 'IBPS Probationary Officers (PO / MT-XVI)',
        organization: 'Institute of Banking Personnel Selection',
        postName: 'Probationary Officer / Management Trainee in 11 Public Sector Banks',
        sector: JobSector.banking,
        totalVacancies: 4850,
        state: 'All India',
        minAge: 20,
        maxAgeGeneral: 30,
        minEducation: EducationLevel.graduate,
        eligibleDegrees: [],
        minPercentage: 55.0,
        applicationStartDate: now.subtract(const Duration(days: 20)),
        applicationEndDate: now.subtract(const Duration(days: 2)), // Application Closed, Admit Card Out!
        admitCardReleaseDate: now.subtract(const Duration(days: 1)), // Out right now!
        examDate: now.add(const Duration(days: 14)),
        resultDate: now.add(const Duration(days: 45)),
        payScale: 'Initial Basic ₹36,000 (Gross approx ₹58,000 + Perquisites)',
        applicationFee: '₹850 (₹175 for SC/ST/PwD)',
        officialWebsite: 'https://ibps.in',
        applyUrl: 'https://ibps.in/crp-po-mt-xvi',
        admitCardUrl: 'https://ibps.in/download-po-admit-card',
        syllabusSummary: 'Prelims: English Language (30 Qs), Quantitative Aptitude (35 Qs), Reasoning Ability (35 Qs). Mains: Reasoning & Computer Aptitude, Data Analysis, General Banking Awareness, English.',
        examStages: ['Online Preliminary Exam', 'Online Mains Exam', 'Common Interview by participating Banks'],
        isBookmarked: true,
        trackingStage: ApplicationStage.admitCardDownloaded,
        applicationNumber: 'IBPS-PO-448291',
        rollNumber: '28401928',
      ),
      JobModel(
        id: 'rrb_ntpc_2026',
        title: 'RRB NTPC Centralized Employment Notice (Graduate & Under-Graduate)',
        organization: 'Railway Recruitment Boards (Indian Railways)',
        postName: 'Station Master, Goods Train Manager, Senior Clerk cum Typist, Commercial Apprentice',
        sector: JobSector.railway,
        totalVacancies: 11558,
        state: 'All India',
        minAge: 18,
        maxAgeGeneral: 33, // Railway extended age limit
        minEducation: EducationLevel.twelfthPass,
        eligibleDegrees: [],
        minPercentage: 0.0,
        applicationStartDate: now.subtract(const Duration(days: 2)),
        applicationEndDate: now.add(const Duration(days: 30)),
        admitCardReleaseDate: now.add(const Duration(days: 85)),
        examDate: now.add(const Duration(days: 95)),
        resultDate: now.add(const Duration(days: 150)),
        payScale: 'Level 2 to Level 6 (₹19,900 - ₹35,400 Basic + DA, HRA, Travel Allowance)',
        applicationFee: '₹500 (₹400 refunded after CBT-1) / ₹250 for reserved categories (fully refunded)',
        officialWebsite: 'https://indianrailways.gov.in',
        applyUrl: 'https://rrbapply.gov.in',
        syllabusSummary: 'CBT 1: General Awareness (40 Qs), Mathematics (30 Qs), General Intelligence & Reasoning (30 Qs). Total 100 Qs in 90 minutes. CBT 2: 120 Questions.',
        examStages: ['1st Stage CBT (Screening)', '2nd Stage CBT', 'Typing Skill Test / CBAT', 'Document Verification & Medical Exam'],
        isBookmarked: false,
      ),
      JobModel(
        id: 'ssc_chsl_2026',
        title: 'SSC CHSL 10+2 (Combined Higher Secondary Level)',
        organization: 'Staff Selection Commission (SSC)',
        postName: 'Lower Division Clerk (LDC), Junior Secretariat Assistant (JSA), Data Entry Operator (DEO)',
        sector: JobSector.ssc,
        totalVacancies: 3712,
        state: 'All India',
        minAge: 18,
        maxAgeGeneral: 27,
        minEducation: EducationLevel.twelfthPass,
        eligibleDegrees: [],
        minPercentage: 0.0,
        applicationStartDate: now.add(const Duration(days: 10)), // Upcoming!
        applicationEndDate: now.add(const Duration(days: 40)),
        admitCardReleaseDate: now.add(const Duration(days: 70)),
        examDate: now.add(const Duration(days: 80)),
        resultDate: now.add(const Duration(days: 120)),
        payScale: 'Pay Level 2 & Level 4 (₹19,900 - ₹81,100)',
        applicationFee: '₹100 (Free for Women/SC/ST)',
        officialWebsite: 'https://ssc.gov.in',
        applyUrl: 'https://ssc.gov.in',
        syllabusSummary: 'Tier 1: English (25 Qs), General Intelligence (25 Qs), Quantitative Aptitude (25 Qs), General Awareness (25 Qs). Tier 2: Mathematical, Reasoning, English, General Awareness, Skill/Typing.',
        examStages: ['Tier 1 Computer Based Exam', 'Tier 2 Subjective + Typing Skill Test'],
        isBookmarked: false,
      ),
      JobModel(
        id: 'sbi_clerk_2026',
        title: 'SBI Junior Associates (Customer Support & Sales)',
        organization: 'State Bank of India',
        postName: 'Clerk / Junior Associate in SBI branches nationwide',
        sector: JobSector.banking,
        totalVacancies: 8283,
        state: 'All India',
        minAge: 20,
        maxAgeGeneral: 28,
        minEducation: EducationLevel.graduate,
        eligibleDegrees: [],
        minPercentage: 0.0,
        applicationStartDate: now.subtract(const Duration(days: 15)),
        applicationEndDate: now.add(const Duration(days: 5)), // 5 days left!
        admitCardReleaseDate: now.add(const Duration(days: 28)),
        examDate: now.add(const Duration(days: 35)),
        resultDate: now.add(const Duration(days: 65)),
        payScale: 'Starting Basic ₹19,900 (Total Emoluments approx ₹38,000 in metro)',
        applicationFee: '₹750 (Nil for SC/ST/PwD/ESM)',
        officialWebsite: 'https://sbi.co.in/careers',
        applyUrl: 'https://bank.sbi/careers/current-openings',
        syllabusSummary: 'Prelims: 100 Marks (English 30, Numerical Ability 35, Reasoning 35 in 60 mins). Mains: 200 Marks (Financial Awareness, English, Quant, Reasoning & Computer).',
        examStages: ['Phase-I Preliminary Exam', 'Phase-II Main Exam', 'Specified Local Language Test'],
        isBookmarked: false,
      ),
      JobModel(
        id: 'cds_ii_2026',
        title: 'UPSC Combined Defence Services (CDS Examination II)',
        organization: 'Union Public Service Commission & Ministry of Defence',
        postName: 'IMA (Dehradun), INA (Ezhimala), Air Force Academy (Hyderabad), OTA (Chennai)',
        sector: JobSector.defence,
        totalVacancies: 459,
        state: 'All India',
        minAge: 19,
        maxAgeGeneral: 24,
        minEducation: EducationLevel.graduate,
        eligibleDegrees: ['B.Tech', 'B.E.', 'B.Sc', 'Degree in any discipline'],
        minPercentage: 0.0,
        applicationStartDate: now.subtract(const Duration(days: 3)),
        applicationEndDate: now.add(const Duration(days: 18)),
        admitCardReleaseDate: now.add(const Duration(days: 60)),
        examDate: now.add(const Duration(days: 72)),
        resultDate: now.add(const Duration(days: 110)),
        payScale: 'Lieutenant (Level 10: ₹56,100 - ₹1,77,500 + Military Service Pay ₹15,500/mo)',
        applicationFee: '₹200 (Female/SC/ST exempted)',
        officialWebsite: 'https://upsc.gov.in',
        applyUrl: 'https://upsconline.nic.in',
        syllabusSummary: 'IMA/INA/AFA: English (100 M), General Knowledge (100 M), Elementary Mathematics (100 M). OTA: English (100 M) & GK (100 M). Followed by 5-day SSB interview.',
        examStages: ['Written Examination', 'SSB Interview (Stage 1 & Stage 2)', 'Medical Examination'],
        isBookmarked: false,
      ),
      JobModel(
        id: 'drdo_ceptam_2026',
        title: 'DRDO CEPTAM Senior Technical Assistant (STA-B)',
        organization: 'Defence Research & Development Organisation',
        postName: 'Senior Technical Assistant-B in DRDO Laboratories',
        sector: JobSector.psu,
        totalVacancies: 1901,
        state: 'All India',
        minAge: 18,
        maxAgeGeneral: 28,
        minEducation: EducationLevel.diploma,
        eligibleDegrees: ['B.Sc', 'B.Tech', 'Diploma', 'Engineering'],
        minPercentage: 60.0,
        applicationStartDate: now.subtract(const Duration(days: 8)),
        applicationEndDate: now.add(const Duration(days: 14)),
        admitCardReleaseDate: now.add(const Duration(days: 48)),
        examDate: now.add(const Duration(days: 58)),
        resultDate: now.add(const Duration(days: 90)),
        payScale: 'Pay Level 6 (₹35,400 - ₹1,12,400) + Central allowances',
        applicationFee: '₹100 (Exempted for Women/SC/ST/PwBD/ESM)',
        officialWebsite: 'https://drdo.gov.in',
        applyUrl: 'https://drdo.gov.in/careers',
        syllabusSummary: 'Tier-I (Screening): Quantitative aptitude, Reasoning, General awareness, English, General Science (120 Qs). Tier-II (Selection): Specific Subject / Discipline Test (100 Qs).',
        examStages: ['Tier-I CBT (Screening)', 'Tier-II CBT (Subject Specific Merit List)', 'Document Verification'],
        isBookmarked: false,
      ),
      JobModel(
        id: 'uppsc_pcs_2026',
        title: 'UPPSC Combined State / Upper Subordinate Services (PCS 2026)',
        organization: 'Uttar Pradesh Public Service Commission',
        postName: 'Deputy Collector (SDM), Deputy Superintendent of Police (DSP), Block Development Officer (BDO)',
        sector: JobSector.statePsc,
        totalVacancies: 220,
        state: 'Uttar Pradesh',
        minAge: 21,
        maxAgeGeneral: 40, // High age limit for State PSC!
        minEducation: EducationLevel.graduate,
        eligibleDegrees: [],
        minPercentage: 0.0,
        applicationStartDate: now.subtract(const Duration(days: 10)),
        applicationEndDate: now.add(const Duration(days: 12)),
        admitCardReleaseDate: now.add(const Duration(days: 50)),
        examDate: now.add(const Duration(days: 62)),
        resultDate: now.add(const Duration(days: 105)),
        payScale: 'Pay Matrix Level 10 (₹56,100 - ₹1,77,500) & Level 7',
        applicationFee: '₹125 (₹65 for SC/ST, ₹25 for PwD)',
        officialWebsite: 'https://uppsc.up.nic.in',
        applyUrl: 'https://uppsc.up.nic.in/ApplyOnline',
        syllabusSummary: 'Prelims: GS-I (150 Qs, 200 M) + GS-II CSAT (100 Qs, qualifying 33%). Mains: General Hindi, Essay, GS-I through GS-VI (including UP specific GS V & VI).',
        examStages: ['Preliminary Examination (Objective)', 'Main Examination (Written Conventional)', 'Interview'],
        isBookmarked: false,
      ),
      JobModel(
        id: 'rbi_grade_b_2026',
        title: 'Reserve Bank of India (RBI) Grade "B" Officers (General/DEPR/DSIM)',
        organization: 'Reserve Bank of India',
        postName: 'Officers in Grade ‘B’ (DR) - General',
        sector: JobSector.banking,
        totalVacancies: 160,
        state: 'All India',
        minAge: 21,
        maxAgeGeneral: 30,
        minEducation: EducationLevel.graduate,
        eligibleDegrees: [],
        minPercentage: 60.0, // Strict 60% requirement!
        applicationStartDate: now.subtract(const Duration(days: 1)),
        applicationEndDate: now.add(const Duration(days: 22)),
        admitCardReleaseDate: now.add(const Duration(days: 50)),
        examDate: now.add(const Duration(days: 60)),
        resultDate: now.add(const Duration(days: 95)),
        payScale: 'Basic ₹55,200 (Total monthly CTC approx ₹1,16,000 + perquisites)',
        applicationFee: '₹850 (₹100 for SC/ST/PwBD)',
        officialWebsite: 'https://rbi.org.in',
        applyUrl: 'https://opportunities.rbi.org.in',
        syllabusSummary: 'Phase-I: General Awareness, English, Quantitative Aptitude, Reasoning (200 M). Phase-II: Paper 1 (Economic & Social Issues), Paper 2 (English Writing), Paper 3 (Finance & Management).',
        examStages: ['Phase-I Online Examination', 'Phase-II Online Examination (Objective + Descriptive)', 'Interview'],
        isBookmarked: false,
      ),
    ];
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSectorFilter(JobSector? sector) {
    _selectedSector = sector;
    notifyListeners();
  }

  void toggleOnlyEligible(bool value) {
    _onlyEligibleFilter = value;
    notifyListeners();
  }

  List<JobModel> getFilteredJobs(UserProfile user) {
    return _jobs.where((job) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesQuery = job.title.toLowerCase().contains(q) ||
            job.organization.toLowerCase().contains(q) ||
            job.postName.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }

      if (_selectedSector != null && job.sector != _selectedSector) {
        return false;
      }

      if (_onlyEligibleFilter) {
        final report = EligibilityEngine.evaluate(user: user, job: job);
        if (!report.isEligible) return false;
      }

      return true;
    }).toList();
  }

  List<JobModel> getEligibleJobs(UserProfile user) {
    return _jobs.where((job) {
      final report = EligibilityEngine.evaluate(user: user, job: job);
      return report.isEligible;
    }).toList();
  }

  List<JobModel> getUrgentDeadlines(UserProfile user) {
    return getEligibleJobs(user).where((job) {
      return job.isApplicationOpen && job.daysRemainingForApplication <= 7;
    }).toList();
  }

  List<JobModel> getAdmitCardsAvailable(UserProfile user) {
    return _jobs.where((job) => job.isAdmitCardReleased).toList();
  }

  List<ExamCalendarEvent> getAllCalendarEvents(UserProfile user) {
    final List<ExamCalendarEvent> events = [];

    for (var job in _jobs) {
      final report = EligibilityEngine.evaluate(user: user, job: job);

      // Application Deadline Event
      events.add(ExamCalendarEvent(
        id: '${job.id}_deadline',
        jobId: job.id,
        jobTitle: job.title,
        organization: job.organization,
        eventType: CalendarEventType.applicationDeadline,
        date: job.applicationEndDate,
        description: 'Last date to submit online application form for ${job.title}.',
        actionUrl: job.applyUrl,
        isEligibleForUser: report.isEligible,
      ));

      // Application Start Event
      events.add(ExamCalendarEvent(
        id: '${job.id}_start',
        jobId: job.id,
        jobTitle: job.title,
        organization: job.organization,
        eventType: CalendarEventType.applicationStart,
        date: job.applicationStartDate,
        description: 'Online application opens for ${job.title}.',
        actionUrl: job.applyUrl,
        isEligibleForUser: report.isEligible,
      ));

      // Admit Card Release Event
      if (job.admitCardReleaseDate != null) {
        events.add(ExamCalendarEvent(
          id: '${job.id}_admit',
          jobId: job.id,
          jobTitle: job.title,
          organization: job.organization,
          eventType: CalendarEventType.admitCardRelease,
          date: job.admitCardReleaseDate!,
          description: 'Admit Card release date for ${job.title}. Download hall ticket.',
          actionUrl: job.admitCardUrl ?? job.officialWebsite,
          isEligibleForUser: report.isEligible,
        ));
      }

      // Exam Date Event
      if (job.examDate != null) {
        events.add(ExamCalendarEvent(
          id: '${job.id}_exam',
          jobId: job.id,
          jobTitle: job.title,
          organization: job.organization,
          eventType: CalendarEventType.examDate,
          date: job.examDate!,
          description: 'Written / CBT Exam Day for ${job.title}.',
          actionUrl: job.officialWebsite,
          isEligibleForUser: report.isEligible,
        ));
      }

      // Result Date Event
      if (job.resultDate != null) {
        events.add(ExamCalendarEvent(
          id: '${job.id}_result',
          jobId: job.id,
          jobTitle: job.title,
          organization: job.organization,
          eventType: CalendarEventType.resultDate,
          date: job.resultDate!,
          description: 'Tentative result declaration date for ${job.title}.',
          actionUrl: job.officialWebsite,
          isEligibleForUser: report.isEligible,
        ));
      }
    }

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  void toggleBookmark(String jobId) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _jobs[index].isBookmarked = !_jobs[index].isBookmarked;
      notifyListeners();
    }
  }

  void updateApplicationStage(String jobId, ApplicationStage stage, {String? appNo, String? rollNo}) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _jobs[index].trackingStage = stage;
      if (appNo != null) _jobs[index].applicationNumber = appNo;
      if (rollNo != null) _jobs[index].rollNumber = rollNo;
      notifyListeners();
    }
  }

  Future<void> refreshJobsLive() async {
    _isLoading = true;
    notifyListeners();

    // Simulating live network sync with Sarkari / Official Gov API endpoint
    await Future.delayed(const Duration(milliseconds: 1200));

    _isLoading = false;
    notifyListeners();
  }
}
