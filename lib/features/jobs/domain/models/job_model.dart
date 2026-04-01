import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String company;
  final String? companyUrl;
  final String description;
  final String responsibilities;
  final String dailyActivities;
  final String location;
  final String type;
  final String workMode;
  final String skills;
  final String experienceLevel;
  final String education;
  final String salary;
  final bool notDisclosed;
  final DateTime? applicationDeadline;
  final DateTime? joiningDate;
  final int openings;

  final bool urgentHiring;
  final bool fresherFriendly;
  final bool blindHiring;
  final String postedBy;

  final bool isDraft;
  final DateTime? createdAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    this.companyUrl,
    this.description = '',
    this.responsibilities = '',
    this.dailyActivities = '',
    this.location = 'Remote',
    this.type = 'Full-time',
    this.workMode = 'Remote',
    this.skills = '',
    this.experienceLevel = 'Fresher',
    this.education = '',
    this.salary = 'Negotiable',
    this.notDisclosed = false,
    this.applicationDeadline,
    this.joiningDate,
    this.openings = 1,
    this.urgentHiring = false,
    this.fresherFriendly = false,
    this.blindHiring = false,
    required this.postedBy,
    this.isDraft = false,
    this.createdAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>? ?? {});

    Timestamp? parseTs(Object? value) {
      if (value is Timestamp) return value;
      if (value is DateTime) return Timestamp.fromDate(value);
      return null;
    }

    return JobModel(
      id: doc.id,
      title: map['title']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      companyUrl:
          map['companyUrl']?.toString() ?? map['companyLogo']?.toString(),
      description: map['description']?.toString() ?? '',
      responsibilities: map['responsibilities']?.toString() ?? '',
      dailyActivities: map['dailyActivities']?.toString() ?? '',
      location: map['location']?.toString() ?? 'Remote',
      type: map['type']?.toString() ?? 'Full-time',
      workMode: map['workMode']?.toString() ?? 'Remote',
      skills: map['skills']?.toString() ?? '',
      experienceLevel: map['experienceLevel']?.toString() ?? 'Fresher',
      education: map['education']?.toString() ?? '',
      salary: map['salary']?.toString() ?? 'Negotiable',
      notDisclosed: map['notDisclosed'] == true,
      applicationDeadline: parseTs(map['applicationDeadline'])?.toDate(),
      joiningDate: parseTs(map['joiningDate'])?.toDate(),
      openings: (map['openings'] is int
          ? map['openings'] as int
          : int.tryParse(map['openings']?.toString() ?? '') ?? 1),
      urgentHiring: map['urgentHiring'] == true,
      fresherFriendly: map['fresherFriendly'] == true,
      blindHiring: map['blindHiring'] == true,
      postedBy: map['postedBy']?.toString() ?? '',
      isDraft: map['isDraft'] == true,
      createdAt: parseTs(map['createdAt'])?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'companyUrl': companyUrl ?? '',
      'description': description,
      'responsibilities': responsibilities,
      'dailyActivities': dailyActivities,
      'location': location,
      'type': type,
      'workMode': workMode,
      'skills': skills,
      'experienceLevel': experienceLevel,
      'education': education,
      'salary': salary,
      'notDisclosed': notDisclosed,
      'applicationDeadline': applicationDeadline == null
          ? null
          : Timestamp.fromDate(applicationDeadline!),
      'joiningDate': joiningDate == null
          ? null
          : Timestamp.fromDate(joiningDate!),
      'openings': openings,
      'urgentHiring': urgentHiring,
      'fresherFriendly': fresherFriendly,
      'blindHiring': blindHiring,
      'postedBy': postedBy,
      'isDraft': isDraft,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
