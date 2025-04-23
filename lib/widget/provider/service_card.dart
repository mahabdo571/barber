import 'package:barber/models/service_model.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.service.id),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete(); // حذف
        } else {
          widget.onEdit(); // تعديل
        }
        return false; // لا تخفي الكرت تلقائيًا
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: AnimatedCrossFade(
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.service.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: Duration(milliseconds: 300),
                        child: Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),
                  Text(
                    "${widget.service.price.toStringAsFixed(0)} ₪ - ${widget.service.duration} دقيقة",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.service.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: Duration(milliseconds: 300),
                        child: Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),
                  Text(
                    "${widget.service.price.toStringAsFixed(0)} ₪ - ${widget.service.duration} دقيقة",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Divider(height: 16),
                  Text(
                    widget.service.description,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
              crossFadeState:
                  _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 300),
            ),
          ),
        ),
      ),
    );
  }
}
