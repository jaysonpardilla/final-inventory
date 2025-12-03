import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseAuthDataSource {
final fb.FirebaseAuth _auth;
final FirebaseFirestore _db;


FirebaseAuthDataSource({fb.FirebaseAuth? auth, FirebaseFirestore? db})
: _auth = auth ?? fb.FirebaseAuth.instance,
_db = db ?? FirebaseFirestore.instance;


Future<fb.User?> createUserWithEmailAndPassword(String email, String password) async {
final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
return cred.user;
}


Future<fb.User?> signInWithEmailAndPassword(String email, String password) async {
final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
return cred.user;
}


Future<void> signOut() async => await _auth.signOut();


fb.User? get currentUser => _auth.currentUser;


Future<void> createUserDoc({required String uid, required Map<String, dynamic> data, required String usersCollection}) async {
await _db.collection(usersCollection).doc(uid).set(data);
}


Future<Map<String, dynamic>?> fetchUserDoc(String uid, String usersCollection) async {
final snap = await _db.collection(usersCollection).doc(uid).get();
if (snap.exists) return snap.data();
return null;
}
}