import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _companyUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _dailyActivitiesController = TextEditingController();
  final _locationController = TextEditingController(text: 'Remote');
  final _salaryController = TextEditingController(text: 'Negotiable');
  final _skillsController = TextEditingController();
  final _educationController = TextEditingController();
  final _openingsController = TextEditingController(text: '1');
  final _deadlineController = TextEditingController();
  final _joiningController = TextEditingController();

  String _type = 'Full-time';
  String _workMode = 'Remote';
  String _experienceLevel = 'Fresher';

  bool _isLoading = false;
  bool _notDisclosed = false;
  bool _urgentHiring = false;
  bool _fresherFriendly = false;
  bool _isDraft = false;

  DateTime? _applicationDeadline;
  DateTime? _joiningDate;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _companyUrlController.dispose();
    _descriptionController.dispose();
    _responsibilitiesController.dispose();
    _dailyActivitiesController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    _openingsController.dispose();
    _deadlineController.dispose();
    _joiningController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isDeadline) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isDeadline) {
          _applicationDeadline = picked;
          _deadlineController.text = picked.toLocal().toString().split(' ')[0];
        } else {
          _joiningDate = picked;
          _joiningController.text = picked.toLocal().toString().split(' ')[0];
        }
      });
    }
  }

  void _generateWithAI() {
    const generated =
        'Responsibilities:\n- Own feature development and delivery\n- Collaborate with cross-functional teams\n- Write clean, maintainable code\n\nDaily Activities:\n- Participate in standups\n- Review pull requests\n- Deliver focused work in 1-2 week cycles';
    setState(() {
      _descriptionController.text =
          'Join our team as a ${_titleController.text.trim().isEmpty ? 'developer' : _titleController.text}.\n\n${generated}';
      _responsibilitiesController.text =
          '• Collaborate with team members\n• Design and implement features\n• Ensure code quality and testing\n• Participate in demos';
      _dailyActivitiesController.text =
          '• Daily standup and planning\n• Coding and peer review\n• Test and ship features\n• Sync with PM and designer';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI sample text generated (editable)')),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(jobsRepositoryProvider)
          .addJob(
            title: _titleController.text.trim(),
            company: _companyController.text.trim(),
            companyUrl: _companyUrlController.text.trim().isEmpty
                ? null
                : _companyUrlController.text.trim(),
            postedBy: userId,
            description: _descriptionController.text.trim(),
            responsibilities: _responsibilitiesController.text.trim(),
            dailyActivities: _dailyActivitiesController.text.trim(),
            location: _locationController.text.trim(),
            type: _type,
            workMode: _workMode,
            skills: _skillsController.text.trim(),
            experienceLevel: _experienceLevel,
            education: _educationController.text.trim(),
            salary: _notDisclosed
                ? 'Not disclosed'
                : _salaryController.text.trim(),
            notDisclosed: _notDisclosed,
            applicationDeadline: _applicationDeadline,
            joiningDate: _joiningDate,
            openings: int.tryParse(_openingsController.text.trim()) ?? 1,

            urgentHiring: _urgentHiring,
            fresherFriendly: _fresherFriendly,

            isDraft: _isDraft,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isDraft ? 'Draft saved!' : 'Job posted!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('🧾 Basic Job Details'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  hintText: 'e.g., Frontend Intern, Junior Developer',
                ),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Startup Name',
                ),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyUrlController,
                decoration: const InputDecoration(
                  labelText: 'Company Website URL (optional)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Job Type'),
                items: ['Internship', 'Full-time', 'Part-time', 'Freelance']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _workMode,
                decoration: const InputDecoration(labelText: 'Work Mode'),
                items: ['Remote', 'On-site', 'Hybrid']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _workMode = value ?? _workMode),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (if not remote)',
                ),
              ),

              _buildSectionTitle('📄 Job Description'),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description',
                  alignLabelWithHint: true,
                ),
                minLines: 4,
                maxLines: 8,
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Please provide a description'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _responsibilitiesController,
                decoration: const InputDecoration(
                  labelText:
                      'Responsibilities (bullet points, separate with newline)',
                ),
                minLines: 4,
                maxLines: 6,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dailyActivitiesController,
                decoration: const InputDecoration(
                  labelText: 'Daily Activities',
                ),
                minLines: 3,
                maxLines: 5,
              ),
              TextButton.icon(
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Generate with AI'),
                onPressed: _generateWithAI,
              ),

              _buildSectionTitle('🎯 Requirements'),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Required Skills (comma-separated)',
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Required skills help candidates apply'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _experienceLevel,
                decoration: const InputDecoration(
                  labelText: 'Experience Level',
                ),
                items: ['Fresher', '0–1 yr', '1–3 yr', '3+ yr']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(
                  () => _experienceLevel = value ?? _experienceLevel,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _educationController,
                decoration: const InputDecoration(
                  labelText: 'Education (optional)',
                  hintText: 'e.g., B.Tech / Any graduation',
                ),
              ),

              _buildSectionTitle('💰 Salary / Stipend'),
              Row(
                children: [
                  Checkbox(
                    value: _notDisclosed,
                    onChanged: (v) =>
                        setState(() => _notDisclosed = v ?? false),
                  ),
                  const Expanded(child: Text('Not disclosed')),
                ],
              ),
              if (!_notDisclosed)
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salary range or stipend (e.g., ₹20k-30k)',
                  ),
                ),

              _buildSectionTitle('⏰ Application Details'),
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Last Date to Apply',
                ),
                onTap: () => _pickDate(context, true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _joiningController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Joining Date (optional)',
                ),
                onTap: () => _pickDate(context, false),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _openingsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Openings',
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Enter valid number' : null,
              ),

              _buildSectionTitle('📌 Extra Features'),
              SwitchListTile(
                title: const Text('Urgent Hiring'),
                value: _urgentHiring,
                onChanged: (v) => setState(() => _urgentHiring = v),
              ),
              SwitchListTile(
                title: const Text('Fresher Friendly'),
                value: _fresherFriendly,
                onChanged: (v) => setState(() => _fresherFriendly = v),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _isDraft = true);
                              _submit();
                            },
                      child: const Text('Save as draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _isDraft = false);
                              _submit();
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Publish Job'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
