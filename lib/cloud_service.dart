import 'package:cloud_firestore/cloud_firestore.dart';

// serviço na nuvem

class BackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //cria o user
  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  // atualiza o user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  //pega informações do user
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) return doc.data() as Map<String, dynamic>;
    return null;
  }

  // pega informações do user pelo email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  final query = await _firestore
      .collection('users')
      .where('mail', isEqualTo: email)
      .limit(1) // opcional, se espera só um resultado
      .get();

  if (query.docs.isNotEmpty) {
    return query.docs.first.data();
  }

  return null;
}

  // manda convite de treino
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
    'isResponse': false,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

// responde convite de treino
Future<void> respondToWorkoutInvite({
  required String originalSenderId,
  required String responderId,
  required String workoutSuggestion,
  required String responseStatus, // 'accepted' ou 'declined'
}) async {
  await FirebaseFirestore.instance.collection('invites').add({
    'senderId': responderId,         // quem está respondendo
    'receiverId': originalSenderId,  // quem enviou originalmente o convite
    'workoutSuggestion': workoutSuggestion,
    'timestamp': FieldValue.serverTimestamp(),
    'isResponse': true,
    'responseStatus': responseStatus, // 'accepted' ou 'declined'
  });
}


// deleta convites antigos
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


// deleta o convite
Future<void> deleteInvite(String senderId, String receiverId, String workoutSuggestion) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('invites')
      .where('senderId', isEqualTo: senderId)
      .where('receiverId', isEqualTo: receiverId)
      .where('workoutSuggestion', isEqualTo: workoutSuggestion)
      .where('isResponse', isEqualTo: false)
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.delete();
  }
}

  Future<List<Map<String, dynamic>>> getReceivedWorkoutInvites({required String uid}) async {
  final invitesSnapshot = await FirebaseFirestore.instance
      .collection('invites')
      .where('receiverId', isEqualTo: uid)
      .orderBy('timestamp', descending: true)
      .get();

  return invitesSnapshot.docs.map((doc) => doc.data()).toList();
}


// recebe as respostas dos convites
Future<List<Map<String, dynamic>>> getResponsesToWorkoutInvites(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('invites')
      .where('receiverId', isEqualTo: uid)
      .where('isResponse', isEqualTo: true)
      .orderBy('timestamp', descending: true)
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}
}
