import 'package:barber/helper/help_metod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final kUserAuth = FirebaseAuth.instance.currentUser;
const kAppName = 'مواعيد الحلاقين';
final kUid = kUserAuth == null ? -1 : kUserAuth?.uid;








