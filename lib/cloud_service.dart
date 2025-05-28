import 'package:cloud_firestore/cloud_firestore.dart';

class BackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) return doc.data() as Map<String, dynamic>;
    return null;
  }

  Future<void> addFriend(String uid, Map<String, dynamic> friendData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .add(friendData);
  }

  Future<void> sendWorkoutInvite({
  required String senderId,
  required String receiverId,
  required String workoutSuggestion,
}) async {
  await FirebaseFirestore.instance.collection('invites').add({
    'senderId': senderId,
    'receiverId': receiverId,
    'workoutSuggestion': workoutSuggestion,
    'status': 'pending',
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<void> deleteOldPendingInvites() async {
  final now = DateTime.now();

  final snapshot = await FirebaseFirestore.instance
      .collection('invites')
      .where('status', isEqualTo: 'pending')
      .get();

  for (var doc in snapshot.docs) {
    final timestamp = doc['timestamp']?.toDate();
    if (timestamp != null) {
      final diff = now.difference(timestamp);
      if (diff.inHours >= 24) {
        await doc.reference.delete();
      }
    }
  }
}

  Future<List<Map<String, dynamic>>> getReceivedWorkoutInvites({required String uid}) async {
  final invitesSnapshot = await FirebaseFirestore.instance
      .collection('workout_invites')
      .where('receiverId', isEqualTo: uid)
      .orderBy('timestamp', descending: true)
      .get();

  return invitesSnapshot.docs.map((doc) => doc.data()).toList();
}
}
