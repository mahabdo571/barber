import 'package:barber/feature/company_mode/cubit/service_section_cubit/service_section_cubit.dart';
import 'package:barber/feature/company_mode/models/service_model.dart';
import 'package:barber/feature/company_mode/widget/service_section/card_swipe_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceCard extends StatefulWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.service.id),
      background: const CardSwipeBackground(icon: Icons.delete, color: Colors.red, alignment: Alignment.centerLeft),
      secondaryBackground: const CardSwipeBackground(icon: Icons.edit, color: Colors.blue, alignment: Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          context.read<ServiceSectionCubit>().deleteService(widget.service.id);
          return true;
        } else if (direction == DismissDirection.endToStart) {
          Navigator.pushNamed(context, '/editService', arguments: widget.service);
          return false;
        }
        return false;
      },
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.service.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.circle, size: 12, color: widget.service.isAvailable ? Colors.green : Colors.grey)
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 8),
                  Text(widget.service.description),
                  const SizedBox(height: 4),
                  Text('السعر: ${widget.service.price.toStringAsFixed(2)} \$', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
