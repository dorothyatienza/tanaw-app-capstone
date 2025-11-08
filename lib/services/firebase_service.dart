import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> uploadDetection(Map<String, dynamic> data) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        ...data,
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
    return _firestore
        .collection('detections')
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
