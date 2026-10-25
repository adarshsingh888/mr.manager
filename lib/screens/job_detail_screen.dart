import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job_model.dart';
import '../services/job_repository.dart';
import '../services/profile_provider.dart';
import '../services/eligibility_engine.dart';
import '../services/notification_service.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late TextEditingController _appNoController;
  late TextEditingController _rollNoController;

  @override
  void initState() {
    super.initState();
    _appNoController = TextEditingController(text: widget.job.applicationNumber ?? '');
    _rollNoController = TextEditingController(text: widget.job.rollNumber ?? '');
  }

  @override
  void dispose() {
    _appNoController.dispose();
    _rollNoController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<ProfileProvider>().user;
    final repo = context.watch<JobRepository>();
    final report = EligibilityEngine.evaluate(user: user, job: widget.job);
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.organization, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(
              widget.job.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: widget.job.isBookmarked ? theme.colorScheme.primary : null,
            ),
            onPressed: () {
              repo.toggleBookmark(widget.job.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share link copied for ${widget.job.title}')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.alarm_add, size: 18),
                label: const Text('Set Reminder'),
                onPressed: () {
                  NotificationService().scheduleRemindersForJob(widget.job);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Smart notification alerts scheduled for deadlines & admit card!'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Apply Online'),
                onPressed: () => _launchUrl(widget.job.applyUrl),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header & Organization Info
            Text(
              widget.job.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              widget.job.postName,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // 2. Comprehensive Eligibility Card
            _buildEligibilityBanner(context, report, user),
            const SizedBox(height: 20),

            // 3. Important Dates & Milestones (Application, Admit Card, Exam, Result)
            _buildTimelineCard(context, dateFormat),
            const SizedBox(height: 20),

            // 4. Job Overview (Salary, Fees, Vacancies)
            _buildOverviewGrid(context),
            const SizedBox(height: 20),

            // 5. Application Tracking & Hall Ticket Center
            _buildTrackerSection(context, repo),
            const SizedBox(height: 20),

            // 6. Syllabus & Selection Stages
            _buildSyllabusSection(context),
            const SizedBox(height: 20),

            // 7. Official Resources
            _buildOfficialLinksSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityBanner(BuildContext context, EligibilityReport report, dynamic user) {
    final theme = Theme.of(context);
    final isEligible = report.isEligible;

    return Container(
      decoration: BoxDecoration(
        color: isEligible ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEligible ? Colors.green.shade300 : Colors.red.shade300,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEligible ? Icons.verified : Icons.error_outline,
                color: isEligible ? Colors.green.shade800 : Colors.red.shade800,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEligible
                      ? (report.isEligibleViaRelaxation
                          ? 'Eligible with Category Relaxation (${user.category})'
                          : 'You are Eligible for this Exam!')
                      : 'You are Currently Ineligible',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isEligible ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isEligible ? Colors.green.shade600 : Colors.red.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${report.matchPercentage}% Match',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Criteria List
          for (var item in report.criteria)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.passed ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: item.passed ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          item.message,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, DateFormat dateFormat) {
    final job = widget.job;

    return Card(
      elevation: 0,
      color: Colors.grey.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, size: 20),
                SizedBox(width: 8),
                Text(
                  'Important Exam Calendar Dates',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildTimelineRow(
              'Application Window',
              '${dateFormat.format(job.applicationStartDate)}  ➔  ${dateFormat.format(job.applicationEndDate)}',
              job.isApplicationOpen ? 'Active' : 'Closed',
              job.isApplicationOpen ? Colors.green : Colors.grey,
            ),
            _buildTimelineRow(
              'Admit Card / Hall Ticket',
              job.admitCardReleaseDate != null
                  ? dateFormat.format(job.admitCardReleaseDate!)
                  : 'To be announced',
              job.isAdmitCardReleased ? 'Released' : 'Pending',
              job.isAdmitCardReleased ? Colors.blue : Colors.orange,
            ),
            _buildTimelineRow(
              'Exam Date',
              job.examDate != null ? dateFormat.format(job.examDate!) : 'To be declared',
              job.daysUntilExam != null ? '${job.daysUntilExam} days away' : 'TBD',
              Colors.purple,
            ),
            if (job.resultDate != null)
              _buildTimelineRow(
                'Result Date',
                dateFormat.format(job.resultDate!),
                'Tentative',
                Colors.teal,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(String label, String value, String tag, Color tagColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tagColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(BuildContext context) {
    final job = widget.job;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailCell('Total Vacancies', '${job.totalVacancies} Posts', Icons.people_outline),
              ),
              Expanded(
                child: _buildDetailCell('Pay Scale', job.payScale, Icons.currency_rupee),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDetailCell('Application Fee', job.applicationFee, Icons.payment),
              ),
              Expanded(
                child: _buildDetailCell('State / Jurisdiction', job.state, Icons.location_on_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCell(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackerSection(BuildContext context, JobRepository repo) {
    final job = widget.job;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_turned_in_outlined, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'My Application Tracker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<ApplicationStage>(
            value: job.trackingStage,
            decoration: const InputDecoration(
              labelText: 'Current Status',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
            ),
            items: ApplicationStage.values
                .map((stage) => DropdownMenuItem(
                      value: stage,
                      child: Text(stage.label),
                    ))
                .toList(),
            onChanged: (stage) {
              if (stage != null) {
                repo.updateApplicationStage(
                  job.id,
                  stage,
                  appNo: _appNoController.text,
                  rollNo: _rollNoController.text,
                );
              }
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _appNoController,
                  decoration: const InputDecoration(
                    labelText: 'Application No.',
                    hintText: 'e.g. 2026CGL981',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    repo.updateApplicationStage(job.id, job.trackingStage, appNo: val);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _rollNoController,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number',
                    hintText: 'e.g. 8472910',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    repo.updateApplicationStage(job.id, job.trackingStage, rollNo: val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Syllabus & Selection Process',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          widget.job.syllabusSummary,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 10),
        if (widget.job.examStages.isNotEmpty) ...[
          const Text('Stages of Selection:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          for (var i = 0; i < widget.job.examStages.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.job.examStages[i], style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildOfficialLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Official Links & Portals',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          leading: const Icon(Icons.language, color: Colors.blue),
          title: const Text('Official Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(widget.job.officialWebsite, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => _launchUrl(widget.job.officialWebsite),
        ),
        if (widget.job.admitCardUrl != null) ...[
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            tileColor: Colors.blue.shade50,
            leading: const Icon(Icons.download, color: Colors.blue),
            title: const Text('Download Admit Card / Hall Ticket',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
            onTap: () => _launchUrl(widget.job.admitCardUrl!),
          ),
        ],
      ],
    );
  }
}
