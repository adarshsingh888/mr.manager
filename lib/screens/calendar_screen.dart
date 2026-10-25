import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event_model.dart';
import '../services/job_repository.dart';
import '../services/profile_provider.dart';
import '../services/notification_service.dart';
import 'job_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _onlyEligible = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<ExamCalendarEvent> _getEventsForDay(DateTime day, List<ExamCalendarEvent> allEvents) {
    return allEvents.where((event) {
      if (_onlyEligible && !event.isEligibleForUser) return false;
      return isSameDay(event.date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<ProfileProvider>().user;
    final repo = context.watch<JobRepository>();
    final allEvents = repo.getAllCalendarEvents(user);
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay, allEvents);
    final dateFormat = DateFormat('EEE, dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Calendar & Milestones', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Filter Eligible Only',
            icon: Icon(_onlyEligible ? Icons.filter_alt : Icons.filter_alt_off),
            onPressed: () {
              setState(() {
                _onlyEligible = !_onlyEligible;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLegendDot(CalendarEventType.applicationStart.colorValue, 'App Starts'),
                  const SizedBox(width: 12),
                  _buildLegendDot(CalendarEventType.applicationDeadline.colorValue, 'Last Date'),
                  const SizedBox(width: 12),
                  _buildLegendDot(CalendarEventType.admitCardRelease.colorValue, 'Admit Card'),
                  const SizedBox(width: 12),
                  _buildLegendDot(CalendarEventType.examDate.colorValue, 'Exam Day'),
                  const SizedBox(width: 12),
                  _buildLegendDot(CalendarEventType.resultDate.colorValue, 'Result'),
                ],
              ),
            ),
          ),

          // Interactive Calendar widget
          TableCalendar<ExamCalendarEvent>(
            firstDay: DateTime.now().subtract(const Duration(days: 60)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getEventsForDay(day, allEvents),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerSize: 7,
              markersMaxCount: 4,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),

          const Divider(height: 1),

          // Selected Day Event Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(_selectedDay ?? _focusedDay),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '${selectedEvents.length} Events',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Events list for selected date
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No exam events on this date',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap dates with color dots to see application deadlines or exams.',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: selectedEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      return _buildEventTile(context, event, repo);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(int colorVal, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: Color(colorVal), shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEventTile(BuildContext context, ExamCalendarEvent event, JobRepository repo) {
    final theme = Theme.of(context);
    final eventColor = Color(event.eventType.colorValue);

    return Container(
      decoration: BoxDecoration(
        color: eventColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: eventColor.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: eventColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getEventIcon(event.eventType),
            color: eventColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                event.jobTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: eventColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.eventType.label,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(event.description, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  event.organization,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
                if (!event.isEligibleForUser) ...[
                  const SizedBox(width: 8),
                  const Text('• Ineligible', style: TextStyle(color: Colors.red, fontSize: 11)),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          onPressed: () {
            final job = repo.jobs.firstWhere((j) => j.id == event.jobId);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
            );
          },
        ),
      ),
    );
  }

  IconData _getEventIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.applicationStart:
        return Icons.edit_calendar;
      case CalendarEventType.applicationDeadline:
        return Icons.alarm;
      case CalendarEventType.admitCardRelease:
        return Icons.confirmation_number_outlined;
      case CalendarEventType.examDate:
        return Icons.school_outlined;
      case CalendarEventType.resultDate:
        return Icons.grade_outlined;
    }
  }
}
