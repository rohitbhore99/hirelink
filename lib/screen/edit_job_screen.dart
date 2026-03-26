import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/core/theme/app_radius.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';
import 'package:hirelink1/features/jobs/domain/models/job_model.dart';
import 'package:hirelink1/services/firestore_service.dart';

class EditJobScreen extends ConsumerStatefulWidget {
  final JobModel job;

  const EditJobScreen({super.key, required this.job});

  @override
  ConsumerState<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends ConsumerState<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _companyController;
  late final TextEditingController _companyUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _responsibilitiesController;
  late final TextEditingController _dailyActivitiesController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryController;
  late final TextEditingController _skillsController;
  late final TextEditingController _educationController;
  late final TextEditingController _openingsController;
  late final TextEditingController _deadlineController;
  late final TextEditingController _joiningController;

  late String _type;
  late String _workMode;
  late String _experienceLevel;
  late bool _notDisclosed;
  late bool _urgentHiring;
  late bool _fresherFriendly;
  late bool _isDraft;

  DateTime? _applicationDeadline;
  DateTime? _joiningDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    _titleController = TextEditingController(text: job.title);
    _companyController = TextEditingController(text: job.company);
    _companyUrlController = TextEditingController(text: job.companyUrl ?? '');
    _descriptionController = TextEditingController(text: job.description);
    _responsibilitiesController = TextEditingController(
      text: job.responsibilities,
    );
    _dailyActivitiesController = TextEditingController(
      text: job.dailyActivities,
    );
    _locationController = TextEditingController(text: job.location);
    _salaryController = TextEditingController(text: job.salary);
    _skillsController = TextEditingController(text: job.skills);
    _educationController = TextEditingController(text: job.education);
    _openingsController = TextEditingController(text: job.openings.toString());
    _deadlineController = TextEditingController(
      text: job.applicationDeadline != null
          ? job.applicationDeadline!.toLocal().toString().split(' ')[0]
          : '',
    );

    _joiningController = TextEditingController(
      text: job.joiningDate != null
          ? job.joiningDate!.toLocal().toString().split(' ')[0]
          : '',
    );

    _type = job.type;
    _workMode = job.workMode;
    _experienceLevel = job.experienceLevel;
    _notDisclosed = job.notDisclosed;
    _urgentHiring = job.urgentHiring;
    _fresherFriendly = job.fresherFriendly;
    _isDraft = job.isDraft;
    _applicationDeadline = job.applicationDeadline;
    _joiningDate = job.joiningDate;
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateJob(widget.job.id, {
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'companyUrl': _companyUrlController.text.trim().isEmpty
            ? null
            : _companyUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'responsibilities': _responsibilitiesController.text.trim(),
        'dailyActivities': _dailyActivitiesController.text.trim(),
        'location': _locationController.text.trim(),
        'type': _type,
        'workMode': _workMode,
        'skills': _skillsController.text.trim(),
        'experienceLevel': _experienceLevel,
        'education': _educationController.text.trim(),
        'salary': _notDisclosed
            ? 'Not disclosed'
            : _salaryController.text.trim(),
        'notDisclosed': _notDisclosed,
        'applicationDeadline': _applicationDeadline,
        'joiningDate': _joiningDate,
        'openings': int.tryParse(_openingsController.text.trim()) ?? 1,
        'urgentHiring': _urgentHiring,
        'fresherFriendly': _fresherFriendly,
        'isDraft': _isDraft,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update job: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('Delete', style: TextStyle(color: Colors.white)),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.deleteJob(widget.job.id); // Use deleteJob method
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Job deleted!')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete job: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete Job',
          onPressed: _deleteJob,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Basic Job Details'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
              ),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              TextFormField(
                controller: _companyUrlController,
                decoration: const InputDecoration(
                  labelText: 'Company Website (optional)',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Job Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'Internship',
                    child: Text('Internship'),
                  ),
                  DropdownMenuItem(
                    value: 'Full-time',
                    child: Text('Full-time'),
                  ),
                  DropdownMenuItem(
                    value: 'Part-time',
                    child: Text('Part-time'),
                  ),
                  DropdownMenuItem(
                    value: 'Freelance',
                    child: Text('Freelance'),
                  ),
                ],
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _workMode,
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
                value: _experienceLevel,
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
                onChanged: (v) => setState(() => _urgentHiring = v ?? false),
              ),
              SwitchListTile(
                title: const Text('Fresher Friendly'),
                value: _fresherFriendly,
                onChanged: (v) => setState(() => _fresherFriendly = v ?? false),
              ),
              SwitchListTile(
                title: const Text('Keep as Draft'),
                subtitle: const Text('Hide from applicants temporarily'),
                value: _isDraft,
                onChanged: (v) => setState(() => _isDraft = v ?? false),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Job'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
