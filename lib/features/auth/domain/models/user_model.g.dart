// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  aiImagesGenerated: (json['aiImagesGenerated'] as num?)?.toInt() ?? 0,
  subscriptionStatus: json['subscriptionStatus'] as String?,
  billingPeriod: json['billingPeriod'] as String?,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  subscriptionStartDate: json['subscriptionStartDate'] == null
      ? null
      : DateTime.parse(json['subscriptionStartDate'] as String),
  isAccountDisabled: json['isAccountDisabled'] as bool? ?? false,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt.toIso8601String(),
  'isEmailVerified': instance.isEmailVerified,
  'isAnonymous': instance.isAnonymous,
  'aiImagesGenerated': instance.aiImagesGenerated,
  'subscriptionStatus': instance.subscriptionStatus,
  'billingPeriod': instance.billingPeriod,
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'subscriptionStartDate': instance.subscriptionStartDate?.toIso8601String(),
  'isAccountDisabled': instance.isAccountDisabled,
};
