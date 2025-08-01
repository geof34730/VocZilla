// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_firestore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserFirestore _$UserFirestoreFromJson(Map<String, dynamic> json) =>
    _UserFirestore(
      uid: json['uid'] as String,
      email: json['email'] as String,
      lastName: json['lastName'] as String,
      firstName: json['firstName'] as String,
      pseudo: json['pseudo'] as String,
      providerId: json['providerId'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
      photoURL: json['photoURL'] as String? ?? '',
      imageAvatar: json['imageAvatar'] as String? ?? '',
      fcmTokens: (json['fcmTokens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserFirestoreToJson(_UserFirestore instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'lastName': instance.lastName,
      'firstName': instance.firstName,
      'pseudo': instance.pseudo,
      'providerId': instance.providerId,
      'isEmailVerified': instance.isEmailVerified,
      'photoURL': instance.photoURL,
      'imageAvatar': instance.imageAvatar,
      'fcmTokens': instance.fcmTokens,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
