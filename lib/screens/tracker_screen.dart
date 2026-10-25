import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job_model.dart';
import '../services/job_repository.dart';
import 'job_detail_screen.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<JobRepository>();
    final trackedJobs = repo.jobs.where((j) => j.trackingStage != ApplicationStage.none || j.isBookmarked).toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Exam Pipeline & Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All Tracked'),
              Tab(text: 'Forms Submitted'),
              Tab(text: 'Admit Card Ready'),
              Tab(text: 'Saved / Wishlist'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildJobList(context, trackedJobs, repo),
            _buildJobList(
              context,
              trackedJobs.where((j) => j.trackingStage == ApplicationStage.applied).toList(),
              repo,
            ),
            _buildJobList(
              context,
              trackedJobs.where((j) => j.trackingStage == ApplicationStage.admitCardDownloaded).toList(),
              repo,
            ),
            _buildJobList(
              context,
              trackedJobs.where((j) => j.isBookmarked && j.trackingStage == ApplicationStage.none).toList(),
              repo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(BuildContext context, List<JobModel> jobs, JobRepository repo) {
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 54, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                'No exams in this category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap "Apply Online" or bookmark an exam from the dashboard to track it here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        job.trackingStage.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    Text(
                      job.organization,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  job.postName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),

                // Credentials storage banner
                if (job.applicationNumber != null || job.rollNumber != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (job.applicationNumber != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('App Number', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                SelectableText(
                                  job.applicationNumber!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        if (job.rollNumber != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Roll Number', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                SelectableText(
                                  job.rollNumber!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (job.admitCardUrl != null)
                      TextButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Admit Card', style: TextStyle(fontSize: 12)),
                        onPressed: () => _launchUrl(job.admitCardUrl!),
                      ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      child: const Text('Manage', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
