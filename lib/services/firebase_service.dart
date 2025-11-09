import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> uploadDetection(Map<String, dynamic> data) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        // ignore: avoid_print
        print('uploadDetection error: No user logged in');
        return;
      }

      final Map<String, dynamic> payload = <String, dynamic>{
        ...data,
        'userId': currentUser.uid,
        'userEmail': currentUser.email ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('detections').add(payload);
    } catch (error) {
      // Keep minimal handling for now; can be routed to a logger later
      // Avoid rethrowing to keep the call site simple
      // ignore: avoid_print
      print('uploadDetection error: $error');
    }
  }

  static Stream<List<Map<String, dynamic>>> streamDetections() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.email == null) {
      // Return empty stream if no user is logged in
      return Stream.value(<Map<String, dynamic>>[]);
    }

    return _firestore
        .collection('detections')
        .where('userEmail', isEqualTo: currentUser.email)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              doc.data(),
            );
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }
}
