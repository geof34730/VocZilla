// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_firestore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserFirestore _$UserFirestoreFromJson(Map<String, dynamic> json) =>
    _UserFirestore(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String,
      providerId: json['providerId'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserFirestoreToJson(_UserFirestore instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'providerId': instance.providerId,
      'isEmailVerified': instance.isEmailVerified,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
