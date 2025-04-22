import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
const kAppName = 'مواعيد الحلاقين';
final kUid = user == null ? -1 : user?.uid;
