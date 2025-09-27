import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool isPro;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int totalConversions;
  final Map<String, dynamic>? subscriptionInfo;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.isPro,
    required this.createdAt,
    this.lastLoginAt,
    this.totalConversions = 0,
    this.subscriptionInfo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      isPro: data['isPro'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : null,
      totalConversions: data['totalConversions'] ?? 0,
      subscriptionInfo: data['subscriptionInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isPro': isPro,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'totalConversions': totalConversions,
      'subscriptionInfo': subscriptionInfo,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isPro,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? totalConversions,
    Map<String, dynamic>? subscriptionInfo,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isPro: isPro ?? this.isPro,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalConversions: totalConversions ?? this.totalConversions,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.isPro == isPro &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.totalConversions == totalConversions;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        isPro.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode ^
        totalConversions.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, isPro: $isPro)';
  }
}
