import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';

class SalonServicesPage extends StatefulWidget {
  final Business business;

  const SalonServicesPage({super.key, required this.business});

  @override
  State<SalonServicesPage> createState() => _SalonServicesPageState();
}

class _SalonServicesPageState extends State<SalonServicesPage> {
  Service? _selectedService;
  final Map<String, bool> _expandedDates = {};

  Stream<QuerySnapshot> _getServicesStream() {
    return FirebaseFirestore.instance
        .collection(AppConstants.colServices)
        .where('businessId', isEqualTo: widget.business.id)
        .snapshots();
  }

  Stream<QuerySnapshot>? _getTimeSlotsStream() {
    if (_selectedService == null) return null;

    return FirebaseFirestore.instance
        .collection(AppConstants.colTimeSlots)
        .where('businessId', isEqualTo: widget.business.id)
        .where('isBooked', isEqualTo: false)
        .where(
          'startTime',
          isGreaterThanOrEqualTo: DateTime.now().toIso8601String(),
        )
        .orderBy('startTime')
        .snapshots();
  }

  Map<String, List<TimeSlot>> _groupSlotsByDate(List<TimeSlot> slots) {
    final grouped = <String, List<TimeSlot>>{};
    for (final slot in slots) {
      final date = DateFormat('yyyy-MM-dd').format(slot.startTime);
      grouped.putIfAbsent(date, () => []).add(slot);
    }
    return grouped;
  }

  Widget _buildTimeSlotsList() {
    final timeStream = _getTimeSlotsStream();
    if (timeStream == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: timeStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Refresh the stream
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy, size: 64),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مواعيد متاحة لخدمة ${_selectedService!.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final slots =
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return TimeSlot.fromMap(data..['id'] = doc.id);
            }).toList();

        final groupedSlots = _groupSlotsByDate(slots);

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupedSlots.length,
          itemBuilder: (context, index) {
            final date = groupedSlots.keys.elementAt(index);
            final dateSlots = groupedSlots[date]!;
            final isExpanded = _expandedDates[date] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      DateFormat.yMMMMd('ar').format(dateSlots.first.startTime),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () {
                      setState(() {
                        _expandedDates[date] = !isExpanded;
                      });
                    },
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            dateSlots.map((slot) {
                              return ActionChip(
                                label: Text(
                                  DateFormat.jm().format(slot.startTime),
                                ),
                                onPressed: () {
                                  _showBookingDialog(context, slot);
                                },
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingDialog(BuildContext context, TimeSlot slot) {
    final TextEditingController notesController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('تأكيد الحجز'),
                  content:
                      isLoading
                          ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('جاري تأكيد الحجز...'),
                              ],
                            ),
                          )
                          : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الخدمة: ${_selectedService!.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('السعر: ${_selectedService!.price} ريال'),
                                Text(
                                  'المدة: ${_selectedService!.duration} دقيقة',
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'الموعد: ${DateFormat.yMMMd().add_jm().format(slot.startTime)}',
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: notesController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    labelText: 'ملاحظات للصالون (اختياري)',
                                    hintText:
                                        'اكتب أي طلبات أو ملاحظات خاصة هنا',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  actions:
                      isLoading
                          ? []
                          : [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // Set loading state
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  // Get user info
                                  final authState =
                                      context.read<AuthCubit>().state;
                                  if (authState is! AuthAuthenticated) {
                                    throw Exception('يجب تسجيل الدخول أولاً');
                                  }

                                  // Check if slot is still available (race condition check)
                                  final slotDoc =
                                      await FirebaseFirestore.instance
                                          .collection(AppConstants.colTimeSlots)
                                          .doc(slot.id)
                                          .get();

                                  final currentSlot = TimeSlot.fromMap({
                                    ...slotDoc.data()!,
                                    'id': slotDoc.id,
                                  });

                                  if (currentSlot.isBooked) {
                                    throw Exception(
                                      'عذراً، تم حجز هذا الموعد بالفعل',
                                    );
                                  }

                                  // Get customer info
                                  final customerDoc =
                                      await FirebaseFirestore.instance
                                          .collection(AppConstants.colUsers)
                                          .doc(authState.userId)
                                          .get();

                                  if (!customerDoc.exists) {
                                    throw Exception(
                                      'معلومات العميل غير متوفرة',
                                    );
                                  }

                                  final customerData = customerDoc.data()!;
                                  final customerName =
                                      customerData['name'] as String;
                                  final customerPhone =
                                      customerData['phone'] as String;

                                  // Use a transaction to ensure atomic updates
                                  await FirebaseFirestore.instance.runTransaction(
                                    (transaction) async {
                                      // 1. Create a new booking document
                                      final bookingRef =
                                          FirebaseFirestore.instance
                                              .collection(
                                                AppConstants.colBookings,
                                              )
                                              .doc();

                                      // Prepare booking data
                                      final booking = {
                                        'id': bookingRef.id,
                                        'customerId': authState.userId,
                                        'customerName': customerName,
                                        'customerPhone': customerPhone,
                                        'salonId': widget.business.id,
                                        'salonName': widget.business.name,
                                        'serviceId': _selectedService!.id,
                                        'serviceName': _selectedService!.name,
                                        'timeSlotId': slot.id,
                                        'startTime':
                                            slot.startTime.toIso8601String(),
                                        'endTime':
                                            slot.startTime
                                                .add(
                                                  Duration(
                                                    minutes:
                                                        _selectedService!
                                                            .duration,
                                                  ),
                                                )
                                                .toIso8601String(),
                                        'note': notesController.text,
                                        'status': 'pending',
                                        'createdAt':
                                            DateTime.now().toIso8601String(),
                                        'updatedAt':
                                            DateTime.now().toIso8601String(),
                                      };

                                      // 2. Update the time slot to be booked
                                      final timeSlotRef = FirebaseFirestore
                                          .instance
                                          .collection(AppConstants.colTimeSlots)
                                          .doc(slot.id);

                                      // Set the booking in the transaction
                                      transaction.set(bookingRef, booking);

                                      // Update the time slot in the transaction
                                      transaction.update(timeSlotRef, {
                                        'isBooked': true,
                                        'bookingId': bookingRef.id,
                                        'bookedBy': authState.userId,
                                        'updatedAt':
                                            DateTime.now().toIso8601String(),
                                      });
                                    },
                                  );

                                  // Close the dialog
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }

                                  // Show success message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم حجز الموعد بنجاح!'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );

                                    // Navigate back to the home screen
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                } catch (error) {
                                  // Handle errors
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'حدث خطأ: ${error.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('تأكيد الحجز'),
                            ),
                          ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '﷼', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(widget.business.name), centerTitle: true),
      body: Column(
        children: [
          // Salon Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 4),
                                Expanded(child: Text(widget.business.address)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16),
                                const SizedBox(width: 4),
                                Text(widget.business.phone),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              widget.business.isActive
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.business.isActive ? 'مفتوح' : 'مغلق',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Services and Time Slots
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getServicesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Refresh the stream
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_mall_directory_outlined, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد خدمات متوفرة لهذا الصالون',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final services =
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Service.fromMap(data..['id'] = doc.id);
                    }).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Services List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: services.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final isSelected = _selectedService?.id == service.id;

                        return Card(
                          color:
                              isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.3)
                                  : null,
                          child: InkWell(
                            onTap:
                                service.isActive
                                    ? () {
                                      setState(() {
                                        _selectedService =
                                            isSelected ? null : service;
                                        _expandedDates.clear();
                                      });
                                    }
                                    : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${currencyFormat.format(service.price)} - ${service.duration} دقيقة',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Time Slots Section
                    if (_selectedService != null) ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'المواعيد المتاحة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildTimeSlotsList(),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
