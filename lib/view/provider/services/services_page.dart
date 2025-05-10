import '../../../constants.dart';
import 'package:flutter/material.dart';

import '../../../widget/provider/get_all_services_provider.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({super.key,required this.uid});
  final uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppName)),
      body: GetAllServicesProvider(uid:uid),
    );
  }
}
