import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String text;
  final String ownerUserId;
  final String documentId;

  const CloudNote({
    required this.text,
    required this.ownerUserId,
    required this.documentId,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      text = snapshot.data()[textFieldName] as String,
      ownerUserId = snapshot.data()[ownerUserIdFieldName];
}
