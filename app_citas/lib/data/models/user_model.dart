import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocation {
  final String country;
  final String state;
  final String city;

  UserLocation({
    required this.country,
    required this.state,
    required this.city,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'country': country, 'state': state, 'city': city};
  }

  @override
  String toString() => '$city, $country';
}

class UserJob {
  final String title;
  final String company;
  final String education;

  UserJob({
    required this.title,
    required this.company,
    required this.education,
  });

  factory UserJob.fromJson(Map<String, dynamic> json) {
    return UserJob(
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      education: json['education'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'company': company, 'education': education};
  }
}

class UserLifestyle {
  final String drink;
  final String smoke;
  final String workout;
  final String zodiac;
  final String height;

  UserLifestyle({
    required this.drink,
    required this.smoke,
    required this.workout,
    required this.zodiac,
    required this.height,
  });

  factory UserLifestyle.fromJson(Map<String, dynamic> json) {
    return UserLifestyle(
      drink: json['drink'] ?? '',
      smoke: json['smoke'] ?? '',
      workout: json['workout'] ?? '',
      zodiac: json['zodiac'] ?? '',
      height: json['height'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drink': drink,
      'smoke': smoke,
      'workout': workout,
      'zodiac': zodiac,
      'height': height,
    };
  }
}

class UserModel {
  final String id;
  final String uid; // Firebase Auth UID
  final String name;
  final int age;
  final String bio;
  final List<String> photos; // Mapped from 'images' in Firestore
  final UserLocation location;
  final double? distance; // Calculated locally
  final List<String> interests;

  // New fields
  final String gender;
  final String sexualOrientation;
  final UserJob job;
  final UserLifestyle lifestyle;
  final String searchIntent;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    required this.location,
    this.distance,
    this.interests = const [],
    required this.gender,
    required this.sexualOrientation,
    required this.job,
    required this.lifestyle,
    required this.searchIntent,
    this.active = false, // Default to false
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      id: id ?? json['uid'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      bio: json['bio'] ?? '',
      photos: List<String>.from(json['images'] ?? []), // 'images' in Firestore
      location: json['location'] != null
          ? UserLocation.fromJson(json['location'])
          : UserLocation(country: '', state: '', city: ''),
      distance: json['distance']?.toDouble(),
      interests: List<String>.from(json['interests'] ?? []),
      gender: json['gender'] ?? '',
      sexualOrientation: json['sexualOrientation'] ?? '',
      job: json['job'] != null
          ? UserJob.fromJson(json['job'])
          : UserJob(title: '', company: '', education: ''),
      lifestyle: json['lifestyle'] != null
          ? UserLifestyle.fromJson(json['lifestyle'])
          : UserLifestyle(
              drink: '',
              smoke: '',
              workout: '',
              zodiac: '',
              height: '',
            ),
      searchIntent: json['searchIntent'] ?? '',
      active: json['active'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'bio': bio,
      'images': photos, // 'images' in Firestore
      'location': location.toJson(),
      'interests': interests,
      'gender': gender,
      'sexualOrientation': sexualOrientation,
      'job': job.toJson(),
      'lifestyle': lifestyle.toJson(),
      'searchIntent': searchIntent,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
