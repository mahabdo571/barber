import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/booking.dart';
import '../cubit/customer_cubit.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String businessId;

  const BusinessDetailsPage({super.key, required this.businessId});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedServiceId;
  String? _selectedTimeSlotId;
  Service? _selectedService;

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _loadBusinessDetails() {
    context.read<CustomerCubit>().loadBusinessDetails(widget.businessId);
  }

  Stream<QuerySnapshot> _getServicesStream() {
    return FirebaseFirestore.instance
        .collection(AppConstants.colServices)
        .where('businessId', isEqualTo: widget.businessId)
        .snapshots();
  }

  void _showBookingDialog(BuildContext context, String timeSlotId) {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار خدمة أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحجز'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الخدمة: ${_selectedService!.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('السعر: ${_selectedService!.price} ريال'),
                Text('المدة: ${_selectedService!.duration} دقيقة'),
                const SizedBox(height: 8),
                Text(
                  'الموعد: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!)}',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات للصالون (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final booking = Booking(
                    id: '',
                    customerId: '',
                    businessId: widget.businessId,
                    serviceId: _selectedServiceId!,
                    timeSlotId: timeSlotId,
                    startTime: _selectedDate!,
                    endTime: _selectedDate!.add(
                      Duration(minutes: _selectedService!.duration),
                    ),
                    status: 'pending',
                    notes: _notesController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context.read<CustomerCubit>().createBooking(booking);
                  Navigator.pop(context);
                },
                child: const Text('تأكيد الحجز'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الصالون'), centerTitle: true),
      body: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Business? business;
          if (state is CustomerBusinessDetailsLoaded) {
            business = state.business;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (business != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Expanded(child: Text(business.address)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16),
                            const SizedBox(width: 4),
                            Text(business.phone),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                business.isActive ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            business.isActive ? 'مفتوح' : 'مغلق',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الخدمات المتوفرة',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: _getServicesStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'لا توجد خدمات متوفرة لهذا الصالون',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }

                          final services =
                              snapshot.data!.docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return Service.fromMap(data..['id'] = doc.id);
                              }).toList();

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: services.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final service = services[index];
                              final isSelected =
                                  _selectedServiceId == service.id;

                              return ListTile(
                                title: Text(
                                  service.name,
                                  style: TextStyle(
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  'السعر: ${service.price} ريال - المدة: ${service.duration} دقيقة',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (service.isActive)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    else
                                      const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                    if (service.isActive) ...[
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedServiceId = service.id;
                                            _selectedService = service;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              isSelected ? Colors.green : null,
                                        ),
                                        child: Text(
                                          isSelected ? 'تم الاختيار' : 'اختيار',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                enabled: service.isActive,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedService != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المواعيد المتاحة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        CalendarDatePicker(
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                          onDateChanged: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                            if (_selectedServiceId != null) {
                              context
                                  .read<CustomerCubit>()
                                  .loadBusinessTimeSlots(
                                    widget.businessId,
                                    date,
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_selectedDate != null &&
                            state is CustomerTimeSlotsLoaded) ...[
                          if (state.slots.isEmpty)
                            const Center(
                              child: Text(
                                'لا توجد مواعيد متاحة في هذا اليوم',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: state.slots.length,
                              itemBuilder: (context, index) {
                                final slot = state.slots[index];
                                return ElevatedButton(
                                  onPressed: () {
                                    _selectedTimeSlotId = slot.id;
                                    _showBookingDialog(context, slot.id);
                                  },
                                  child: Text(
                                    DateFormat('HH:mm').format(slot.startTime),
                                  ),
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
