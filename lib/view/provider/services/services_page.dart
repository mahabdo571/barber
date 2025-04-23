import 'package:barber/models/service_model.dart';
import 'package:barber/widget/provider/service_card.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({super.key});
  List<Service> services = [
    Service(
      id: '1',
      name: 'حلاقة رجالية',
      description: 'قص وتحديد وتشذيب لحية مع بخار',
      price: 30,
      duration: 40,
    ),

    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (ctx, i) {
        return ServiceCard(
          service: services[i],
          onDelete: () {
            // TODO: تنفيذ الحذف هنا
            print('حذف الخدمة: ${services[i].name}');
          },
          onEdit: () {
            // TODO: تنفيذ التعديل هنا
            print('تعديل الخدمة: ${services[i].name}');
          },
        );
      },
    );
  }
}
