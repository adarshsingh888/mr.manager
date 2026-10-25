import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/job_model.dart';
import '../models/user_profile_model.dart';
import '../services/job_repository.dart';
import '../services/profile_provider.dart';
import '../services/eligibility_engine.dart';
import '../services/notification_service.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = context.watch<ProfileProvider>().user;
    final jobRepo = context.watch<JobRepository>();
    final eligibleJobs = jobRepo.getEligibleJobs(userProfile);
    final urgentJobs = jobRepo.getUrgentDeadlines(userProfile);
    final displayedJobs = jobRepo.getFilteredJobs(userProfile);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.verified_user, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mr. Manager',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Gov Job & Exam Assistant',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Trigger Live Alert Test',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {
              NotificationService().sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Notification test fired! Check notification bar.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Sync Live Govt Feeds',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await jobRepo.refreshJobsLive();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚡ Updated latest government notifications.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => jobRepo.refreshJobsLive(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Eligibility Status Card
              _buildEligibilitySummaryCard(context, userProfile, eligibleJobs.length, urgentJobs.length),
              const SizedBox(height: 16),

              // 2. Urgent Live Alerts Carousel
              _buildUrgentAlertsBanner(context, urgentJobs, jobRepo.getAdmitCardsAvailable(userProfile)),
              const SizedBox(height: 20),

              // 3. Search and Quick Filters
              _buildSearchAndFilters(context, jobRepo),
              const SizedBox(height: 14),

              // 4. Job List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    jobRepo.onlyEligibleFilter
                        ? 'Eligible Exams for You (${displayedJobs.length})'
                        : 'All Gov Exams & Notifications (${displayedJobs.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  FilterChip(
                    label: const Text('Only My Eligible'),
                    selected: jobRepo.onlyEligibleFilter,
                    avatar: Icon(
                      jobRepo.onlyEligibleFilter ? Icons.check_circle : Icons.tune,
                      size: 16,
                      color: jobRepo.onlyEligibleFilter ? Colors.white : null,
                    ),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: jobRepo.onlyEligibleFilter ? Colors.white : null,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) => jobRepo.toggleOnlyEligible(val),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 5. Job Cards Feed
              if (displayedJobs.isEmpty)
                _buildEmptyState(context)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedJobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = displayedJobs[index];
                    final report = EligibilityEngine.evaluate(user: userProfile, job: job);
                    return _buildJobCard(context, job, report, jobRepo);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEligibilitySummaryCard(
    BuildContext context,
    UserProfile user,
    int eligibleCount,
    int urgentCount,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user.name}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.degreeName} • Age ${user.currentAge} (${user.category})',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Verified Profile',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.check_circle_outline,
                  value: '$eligibleCount',
                  label: 'Eligible Exams',
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white24),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.alarm,
                  value: '$urgentCount',
                  label: 'Closing Soon',
                  highlight: urgentCount > 0,
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white24),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.workspace_premium_outlined,
                  value: '100%',
                  label: 'Live Match',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: highlight ? Colors.amberAccent : Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: highlight ? Colors.amberAccent : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildUrgentAlertsBanner(
    BuildContext context,
    List<JobModel> urgentJobs,
    List<JobModel> admitCardJobs,
  ) {
    if (urgentJobs.isEmpty && admitCardJobs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notification_important, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Urgent Action Items (${urgentJobs.length + admitCardJobs.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.brown.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var job in urgentJobs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      '${job.title} application closes in ${job.daysRemainingForApplication} days!',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Apply Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          for (var job in admitCardJobs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Text('🎟️ ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      '${job.organization}: Admit Card is out! Download now.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Download', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, JobRepository repo) {
    return Column(
      children: [
        TextField(
          onChanged: (v) => repo.setSearchQuery(v),
          decoration: InputDecoration(
            hintText: 'Search by exam, post name, UPSC, SSC, RRB...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.08),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All Sectors'),
                selected: repo.selectedSector == null,
                onSelected: (val) => repo.setSectorFilter(null),
              ),
              const SizedBox(width: 8),
              ...JobSector.values.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.displayName),
                      selected: repo.selectedSector == s,
                      onSelected: (val) => repo.setSectorFilter(val ? s : null),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    JobModel job,
    EligibilityReport report,
    JobRepository repo,
  ) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Badge styling based on eligibility
    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;

    if (report.isEligible) {
      if (report.isEligibleViaRelaxation) {
        statusBgColor = Colors.orange.shade50;
        statusTextColor = Colors.orange.shade800;
        statusIcon = Icons.verified;
      } else {
        statusBgColor = Colors.green.shade50;
        statusTextColor = Colors.green.shade800;
        statusIcon = Icons.check_circle;
      }
    } else {
      statusBgColor = Colors.red.shade50;
      statusTextColor = Colors.red.shade800;
      statusIcon = Icons.cancel;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: report.isEligible ? theme.colorScheme.primary.withOpacity(0.3) : Colors.grey.shade200,
          width: report.isEligible ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sector & Eligibility Chip Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.sector.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusTextColor),
                        const SizedBox(width: 4),
                        Text(
                          report.summaryStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                job.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                job.postName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 10),

              // Key details grid: Vacancies, Pay, Min Edu
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vacancies', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            '${job.totalVacancies.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Posts',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Education', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            job.minEducation.displayName.split('(').first.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last Date', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            dateFormat.format(job.applicationEndDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: job.daysRemainingForApplication <= 5 ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Bottom Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        job.isApplicationOpen ? Icons.timelapse : Icons.lock_clock,
                        size: 14,
                        color: job.isApplicationOpen ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.isApplicationOpen
                            ? (job.daysRemainingForApplication >= 0
                                ? '${job.daysRemainingForApplication} days left to apply'
                                : 'Application Ending Today')
                            : 'Application Closed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: job.isApplicationOpen ? Colors.green.shade700 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          job.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: job.isBookmarked ? theme.colorScheme.primary : null,
                          size: 20,
                        ),
                        onPressed: () => repo.toggleBookmark(job.id),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('View & Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No jobs match your filter criteria',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Try clearing filters or updating your educational qualifications.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
