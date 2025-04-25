import 'package:flutter/material.dart';

import '../../../widget/provider/get_all_services_provider.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    return GetAllServicesProvider();
  }
}
