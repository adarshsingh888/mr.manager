import '../models/job_model.dart';
import '../models/user_profile_model.dart';

class CriterionCheck {
  final String title;
  final bool passed;
  final String userValue;
  final String requiredValue;
  final String message;

  CriterionCheck({
    required this.title,
    required this.passed,
    required this.userValue,
    required this.requiredValue,
    required this.message,
  });
}

class EligibilityReport {
  final bool isEligible;
  final bool isEligibleViaRelaxation;
  final int matchPercentage;
  final String summaryStatus; // 'Eligible', 'Eligible (Age Relaxed)', 'Ineligible'
  final List<CriterionCheck> criteria;
  final List<String> reasons;
  final List<String> warnings;

  EligibilityReport({
    required this.isEligible,
    required this.isEligibleViaRelaxation,
    required this.matchPercentage,
    required this.summaryStatus,
    required this.criteria,
    required this.reasons,
    required this.warnings,
  });
}

class EligibilityEngine {
  /// Evaluates whether the user profile meets all criteria for a given job posting
  static EligibilityReport evaluate({
    required UserProfile user,
    required JobModel job,
  }) {
    final criteria = <CriterionCheck>[];
    final reasons = <String>[];
    final warnings = <String>[];
    
    int passedCount = 0;
    int totalCount = 4; // Education, Age, Percentage, Gender/Domicile

    // 1. Education Level Check
    bool educationPassed = user.highestEducation.rank >= job.minEducation.rank;
    
    // Degree specific check (if job requires specific degrees e.g. B.Tech, LLB)
    bool degreeMatched = true;
    if (job.eligibleDegrees.isNotEmpty) {
      degreeMatched = job.eligibleDegrees.any((d) => 
        user.degreeName.toLowerCase().contains(d.toLowerCase()) ||
        user.stream.toLowerCase().contains(d.toLowerCase()) ||
        d.toLowerCase() == 'any graduate' ||
        d.toLowerCase() == 'any degree'
      );
    }

    final finalEduPassed = educationPassed && degreeMatched;
    if (finalEduPassed) {
      passedCount++;
      criteria.add(CriterionCheck(
        title: 'Educational Qualification',
        passed: true,
        userValue: '${user.highestEducation.displayName} (${user.degreeName})',
        requiredValue: job.minEducation.displayName + (job.eligibleDegrees.isNotEmpty ? ' [${job.eligibleDegrees.join(", ")}]' : ''),
        message: 'You satisfy the educational requirements.',
      ));
    } else {
      String failMsg = !educationPassed
          ? 'Requires at least ${job.minEducation.displayName}. Your current is ${user.highestEducation.displayName}.'
          : 'Specific degree required: ${job.eligibleDegrees.join(", ")}. Your degree is ${user.degreeName}.';
      criteria.add(CriterionCheck(
        title: 'Educational Qualification',
        passed: false,
        userValue: '${user.highestEducation.displayName} (${user.degreeName})',
        requiredValue: job.minEducation.displayName,
        message: failMsg,
      ));
      reasons.add(failMsg);
    }

    // 2. Age Criteria & Reservation Relaxation
    final userAge = user.getAgeAsOf(job.applicationStartDate);
    final int relaxation = user.categoryAgeRelaxationYears;
    final int effectiveMaxAge = job.maxAgeGeneral + relaxation;
    
    bool isWithinGeneralLimit = userAge >= job.minAge && userAge <= job.maxAgeGeneral;
    bool isWithinRelaxedLimit = userAge >= job.minAge && userAge <= effectiveMaxAge;
    bool agePassed = isWithinRelaxedLimit;
    bool ageRelaxedUsed = false;

    if (agePassed) {
      passedCount++;
      if (!isWithinGeneralLimit && isWithinRelaxedLimit) {
        ageRelaxedUsed = true;
        criteria.add(CriterionCheck(
          title: 'Age Limit (Relaxation Applied)',
          passed: true,
          userValue: '$userAge years',
          requiredValue: '${job.minAge} - ${job.maxAgeGeneral} yrs (Up to $effectiveMaxAge yrs with ${user.category} relaxation)',
          message: 'Eligible under ${user.category} category relaxation (+$relaxation yrs).',
        ));
      } else {
        criteria.add(CriterionCheck(
          title: 'Age Limit',
          passed: true,
          userValue: '$userAge years',
          requiredValue: '${job.minAge} - ${job.maxAgeGeneral} years',
          message: 'Your age falls within the standard age bracket.',
        ));
      }
    } else {
      String failMsg;
      if (userAge < job.minAge) {
        failMsg = 'Minimum age is ${job.minAge} years. You are currently $userAge years old.';
      } else {
        failMsg = 'Maximum age exceeded. Allowed: $effectiveMaxAge (with ${user.category} relaxation). You are $userAge.';
      }
      criteria.add(CriterionCheck(
        title: 'Age Limit',
        passed: false,
        userValue: '$userAge years',
        requiredValue: '${job.minAge} - $effectiveMaxAge years (incl. relaxation)',
        message: failMsg,
      ));
      reasons.add(failMsg);
    }

    // 3. Minimum Percentage Check
    bool percentagePassed = true;
    if (job.minPercentage > 0) {
      percentagePassed = user.percentage >= job.minPercentage;
      if (percentagePassed) {
        passedCount++;
        criteria.add(CriterionCheck(
          title: 'Minimum Aggregate Marks',
          passed: true,
          userValue: '${user.percentage}%',
          requiredValue: 'Min ${job.minPercentage}%',
          message: 'Marks criteria fulfilled.',
        ));
      } else {
        String msg = 'Requires min ${job.minPercentage}% in qualifying exam. Your score is ${user.percentage}%.';
        criteria.add(CriterionCheck(
          title: 'Minimum Aggregate Marks',
          passed: false,
          userValue: '${user.percentage}%',
          requiredValue: 'Min ${job.minPercentage}%',
          message: msg,
        ));
        reasons.add(msg);
      }
    } else {
      passedCount++;
      criteria.add(CriterionCheck(
        title: 'Minimum Aggregate Marks',
        passed: true,
        userValue: '${user.percentage}%',
        requiredValue: 'No minimum % specified',
        message: 'No minimum cut-off percentage required.',
      ));
    }

    // 4. Gender & Domicile Check
    bool genderPassed = job.genderConstraint == 'All' ||
        job.genderConstraint.toLowerCase() == user.gender.toLowerCase();
    
    bool domicilePassed = job.state == 'All India' ||
        job.state.toLowerCase() == user.domicileState.toLowerCase();

    if (!domicilePassed && job.state != 'All India') {
      warnings.add('State specific quota (${job.state}). Non-domiciles might only apply under unreserved/general quota.');
    }

    if (genderPassed) {
      passedCount++;
      criteria.add(CriterionCheck(
        title: 'Gender / Category Scope',
        passed: true,
        userValue: '${user.gender}, ${user.category}',
        requiredValue: job.genderConstraint == 'All' ? 'Open to All' : job.genderConstraint,
        message: 'Eligible for this post.',
      ));
    } else {
      String msg = 'Post is reserved for ${job.genderConstraint} applicants only.';
      criteria.add(CriterionCheck(
        title: 'Gender Eligibility',
        passed: false,
        userValue: user.gender,
        requiredValue: job.genderConstraint,
        message: msg,
      ));
      reasons.add(msg);
    }

    final bool overallEligible = finalEduPassed && agePassed && percentagePassed && genderPassed;
    final int score = ((passedCount / totalCount) * 100).round();

    String statusText;
    if (overallEligible) {
      statusText = ageRelaxedUsed ? 'Eligible (Relaxed)' : 'Eligible';
    } else {
      statusText = 'Ineligible';
    }

    return EligibilityReport(
      isEligible: overallEligible,
      isEligibleViaRelaxation: ageRelaxedUsed,
      matchPercentage: score,
      summaryStatus: statusText,
      criteria: criteria,
      reasons: reasons,
      warnings: warnings,
    );
  }
}
