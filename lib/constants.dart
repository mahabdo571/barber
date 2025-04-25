import 'package:firebase_auth/firebase_auth.dart';

final kUserAuth = FirebaseAuth.instance.currentUser;
const kAppName = 'مواعيد';
const kDBUser = 'users';

final kUid = kUserAuth == null ? -1 : kUserAuth?.uid;
