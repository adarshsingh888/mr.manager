import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_profile_model.dart';
import '../services/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _degreeController;
  late TextEditingController _streamController;
  late TextEditingController _percentageController;

  late DateTime _selectedDob;
  late String _selectedCategory;
  late String _selectedGender;
  late EducationLevel _selectedEduLevel;
  late String _selectedState;
  late bool _isPwd;
  late bool _isExServiceman;

  final List<String> _categories = ['General', 'OBC', 'SC', 'ST', 'EWS'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _indianStates = [
    'All India', 'Andhra Pradesh', 'Assam', 'Bihar', 'Delhi', 'Gujarat', 
    'Haryana', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 
    'Punjab', 'Rajasthan', 'Tamil Nadu', 'Telangana', 'Uttar Pradesh', 
    'West Bengal'
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().user;
    _nameController = TextEditingController(text: profile.name);
    _degreeController = TextEditingController(text: profile.degreeName);
    _streamController = TextEditingController(text: profile.stream);
    _percentageController = TextEditingController(text: profile.percentage.toString());
    _selectedDob = profile.dateOfBirth;
    _selectedCategory = profile.category;
    _selectedGender = profile.gender;
    _selectedEduLevel = profile.highestEducation;
    _selectedState = _indianStates.contains(profile.domicileState) ? profile.domicileState : 'Delhi';
    _isPwd = profile.isPwd;
    _isExServiceman = profile.isExServiceman;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _degreeController.dispose();
    _streamController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime(1970),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  void _saveProfile() {
    final provider = context.read<ProfileProvider>();
    final double pct = double.tryParse(_percentageController.text) ?? 60.0;

    final updated = provider.user.copyWith(
      name: _nameController.text.trim(),
      dateOfBirth: _selectedDob,
      category: _selectedCategory,
      gender: _selectedGender,
      highestEducation: _selectedEduLevel,
      degreeName: _degreeController.text.trim(),
      stream: _streamController.text.trim(),
      percentage: pct,
      domicileState: _selectedState,
      isPwd: _isPwd,
      isExServiceman: _isExServiceman,
    );

    provider.updateProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Eligibility profile updated! Job recommendations refreshed.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<ProfileProvider>().user;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Eligibility Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Mr. Manager continuously checks every government job against these parameters to find posts you are eligible for.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Basic & Age
            const Text('Personal & Age Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (Used for Age Calculation)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateFormat.format(_selectedDob)),
                    Text(
                      '${user.currentAge} years old',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Caste Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: _genders
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedGender = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: const InputDecoration(
                labelText: 'Home Domicile State (For State PSC)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map_outlined),
              ),
              items: _indianStates
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedState = v);
              },
            ),
            const SizedBox(height: 20),

            // Section 2: Educational Qualification
            const Text('Educational Qualification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            DropdownButtonFormField<EducationLevel>(
              value: _selectedEduLevel,
              decoration: const InputDecoration(
                labelText: 'Highest Education Level',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: EducationLevel.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.displayName)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedEduLevel = v);
              },
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _degreeController,
              decoration: const InputDecoration(
                labelText: 'Degree / Course Name',
                hintText: 'e.g. B.Tech, B.Sc, B.Com, BA, BCA, LLB',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.workspace_premium_outlined),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _streamController,
                    decoration: const InputDecoration(
                      labelText: 'Specialization / Stream',
                      hintText: 'e.g. Computer Science, General',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _percentageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Score (%)',
                      hintText: 'e.g. 72.5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 3: Special Relaxations
            const Text('Reservation & Relaxations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Person with Benchmark Disability (PwD)'),
              subtitle: const Text('+10 years age relaxation applicable across central posts'),
              value: _isPwd,
              onChanged: (val) => setState(() => _isPwd = val),
            ),

            SwitchListTile(
              title: const Text('Ex-Serviceman (ESM)'),
              subtitle: const Text('Relaxation in age & educational cut-offs for defence personnel'),
              value: _isExServiceman,
              onChanged: (val) => setState(() => _isExServiceman = val),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save & Recalculate Eligible Jobs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _saveProfile,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
