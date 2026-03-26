import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String skills;
  final String bio;
  final String profileImageUrl;
  final String resumeUrl;
  final String fcmToken;
  final String? headline;
  final String? location;
  final String? desiredRole;
  final String? experienceLevel;
  final String? languagesKnown;
  final String? portfolioGithub;
  final String? portfolioLinkedin;
  final String? portfolioWebsite;
  final String? educationDegree;
  final String? educationCollege;
  final String? educationYear;
  final String? educationScore;
  final String? projectTitle;
  final String? projectDescription;
  final String? projectTechnologies;
  final String? projectLink;
  final String? achievements;
  final String? certifications;
  final String? awards;
  final String? hackathons;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.skills,
    required this.bio,
    required this.profileImageUrl,
    required this.resumeUrl,
    required this.fcmToken,
    required this.headline,
    required this.location,
    required this.desiredRole,
    required this.experienceLevel,
    required this.languagesKnown,
    required this.portfolioGithub,
    required this.portfolioLinkedin,
    required this.portfolioWebsite,
    required this.educationDegree,
    required this.educationCollege,
    required this.educationYear,
    required this.educationScore,
    required this.projectTitle,
    required this.projectDescription,
    required this.projectTechnologies,
    required this.projectLink,
    required this.achievements,
    required this.certifications,
    required this.awards,
    required this.hackathons,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>? ?? {});
    return UserModel(
      uid: doc.id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'jobseeker',
      skills: map['skills']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      profileImageUrl: map['profileImageUrl']?.toString() ?? '',
      resumeUrl: map['resumeUrl']?.toString() ?? '',
      fcmToken: map['fcmToken']?.toString() ?? '',
      headline: map['headline']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      desiredRole: map['desiredRole']?.toString() ?? '',
      experienceLevel: map['experienceLevel']?.toString() ?? '',
      languagesKnown: map['languagesKnown']?.toString() ?? '',
      portfolioGithub: map['portfolioGithub']?.toString() ?? '',
      portfolioLinkedin: map['portfolioLinkedin']?.toString() ?? '',
      portfolioWebsite: map['portfolioWebsite']?.toString() ?? '',
      educationDegree: map['educationDegree']?.toString() ?? '',
      educationCollege: map['educationCollege']?.toString() ?? '',
      educationYear: map['educationYear']?.toString() ?? '',
      educationScore: map['educationScore']?.toString() ?? '',
      projectTitle: map['projectTitle']?.toString() ?? '',
      projectDescription: map['projectDescription']?.toString() ?? '',
      projectTechnologies: map['projectTechnologies']?.toString() ?? '',
      projectLink: map['projectLink']?.toString() ?? '',
      achievements: map['achievements']?.toString() ?? '',
      certifications: map['certifications']?.toString() ?? '',
      awards: map['awards']?.toString() ?? '',
      hackathons: map['hackathons']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'skills': skills,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'resumeUrl': resumeUrl,
      'fcmToken': fcmToken,
      'headline': headline ?? '',
      'location': location ?? '',
      'desiredRole': desiredRole ?? '',
      'experienceLevel': experienceLevel ?? '',
      'languagesKnown': languagesKnown ?? '',
      'portfolioGithub': portfolioGithub ?? '',
      'portfolioLinkedin': portfolioLinkedin ?? '',
      'portfolioWebsite': portfolioWebsite ?? '',
      'educationDegree': educationDegree ?? '',
      'educationCollege': educationCollege ?? '',
      'educationYear': educationYear ?? '',
      'educationScore': educationScore ?? '',
      'projectTitle': projectTitle ?? '',
      'projectDescription': projectDescription ?? '',
      'projectTechnologies': projectTechnologies ?? '',
      'projectLink': projectLink ?? '',
      'achievements': achievements ?? '',
      'certifications': certifications ?? '',
      'awards': awards ?? '',
      'hackathons': hackathons ?? '',
    };
  }
}
