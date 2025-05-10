// import '../../../cubit/schedule_cubit/schedule_cubit.dart';
// import '../../../cubit/schedule_cubit/schedule_state.dart';
// import '../../../models/schedule_model.dart';
// import '../../../models/time_slot.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// /// صفحة عرض الجداول الزمنية مع حركة توسع سلسة
// class SchedulePage extends StatefulWidget {
//   @override
//   _SchedulePageState createState() => _SchedulePageState();
// }

// class _SchedulePageState extends State<SchedulePage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<ScheduleCubit>().loadSchedules();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ScheduleCubit, ScheduleState>(
//       builder: (context, state) {
//         if (state.status == ScheduleStatus.loading) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (state.status == ScheduleStatus.failure) {
//           return Center(child: Text('حدث خطأ: ${state.errorMessage}'));
//         }
//         final schedules = state.schedules;
//         if (schedules.isEmpty) {
//           return Center(child: Text('لا توجد جداول زمنية بعد'));
//         }
//         return ListView.builder(
//           padding: EdgeInsets.symmetric(vertical: 8),
//           itemCount: schedules.length,
//           itemBuilder: (context, index) {
//             return _ScheduleCard(
//               schedule: schedules[index],
//               onDeleteSchedule: (date) {
//                 context.read<ScheduleCubit>().deleteSchedule(date);
//               },
//               onToggleSlot: (date, slot) {
//                 context.read<ScheduleCubit>().updateTimeSlot(
//                   dateId: date,
//                   slot: slot,
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }

// /// كرت عرض جدول يومي: أول 4 أوقات تظهر دائماً، والباقي يتوسع بحركة سلسة
// class _ScheduleCard extends StatefulWidget {
//   final ScheduleModel schedule;
//   final void Function(String dateId) onDeleteSchedule;
//   final void Function(String dateId, TimeSlot slot) onToggleSlot;

//   const _ScheduleCard({
//     Key? key,
//     required this.schedule,
//     required this.onDeleteSchedule,
//     required this.onToggleSlot,
//   }) : super(key: key);

//   @override
//   __ScheduleCardState createState() => __ScheduleCardState();
// }

// class __ScheduleCardState extends State<_ScheduleCard>
//     with TickerProviderStateMixin {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     final allSlots = widget.schedule.slots;
//     final previewSlots = allSlots.take(4).toList();
//     final remainingSlots = allSlots.length > 4 ? allSlots.skip(4).toList() : [];

//     return Dismissible(
//       key: ValueKey(widget.schedule.date),
//       direction: DismissDirection.startToEnd,
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerLeft,
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         child: Icon(Icons.delete, color: Colors.white),
//       ),
//       confirmDismiss: (_) async {
//         widget.onDeleteSchedule(widget.schedule.date);
//         return false;
//       },
//       child: Card(
//         margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 2,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () => setState(() => _expanded = !_expanded),
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: AnimatedSize(
//               duration: Duration(milliseconds: 500),
//               curve: Curves.easeInOut,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // عنوان التاريخ مع سهم متحرك
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         widget.schedule.date,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       AnimatedRotation(
//                         turns: _expanded ? 0.5 : 0,
//                         duration: Duration(milliseconds: 500),
//                         child: Icon(Icons.keyboard_arrow_down),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   // أول 4 مواعيد دائماً
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 4,
//                     children:
//                         previewSlots.map((slot) {
//                           final isBooked = slot.bookingId != null;
//                           return FilterChip(
//                             label: Text(slot.time),
//                             selected: slot.available,
//                             showCheckmark: false,
//                             onSelected:
//                                 isBooked
//                                     ? null
//                                     : (val) => widget.onToggleSlot(
//                                       widget.schedule.date,
//                                       slot.copyWith(available: val),
//                                     ),
//                             selectedColor: Colors.green.shade200,
//                             disabledColor: Colors.grey.shade400,
//                             labelStyle: TextStyle(
//                               color: isBooked ? Colors.white : Colors.black,
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                   // باقي المواعيد عند التوسيع
//                   if (_expanded && remainingSlots.isNotEmpty) ...[
//                     SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 4,
//                       children:
//                           remainingSlots.map((slot) {
//                             final isBooked = slot.bookingId != null;
//                             return FilterChip(
//                               label: Text(slot.time),
//                               selected: slot.available,
//                               showCheckmark: false,
//                               onSelected:
//                                   isBooked
//                                       ? null
//                                       : (val) => widget.onToggleSlot(
//                                         widget.schedule.date,
//                                         slot.copyWith(available: val),
//                                       ),
//                               selectedColor: Colors.green.shade200,
//                               disabledColor: Colors.grey.shade400,
//                               labelStyle: TextStyle(
//                                 color: isBooked ? Colors.white : Colors.black,
//                               ),
//                             );
//                           }).toList(),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../cubit/schedule_cubit/schedule_cubit.dart';
import '../../../cubit/schedule_cubit/schedule_state.dart';
import '../../../models/schedule_model.dart';
import '../../../models/time_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// صفحة عرض الجداول الزمنية
class SchedulePage extends StatefulWidget {
  /// حدد إذا كانت للمدير أو المستخدم العادي
  final bool isAdmin;

  const SchedulePage({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late String _currentUid;

  @override
  void initState() {
    super.initState();
    // جلب الـ uid للمستخدم الحالي
    _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<ScheduleCubit>().loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        if (state.status == ScheduleStatus.loading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.status == ScheduleStatus.failure) {
          return Center(child: Text('حدث خطأ: ${state.errorMessage}'));
        }
        final schedules = state.schedules;
        if (schedules.isEmpty) {
          return Center(child: Text('لا توجد جداول زمنية بعد'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            return ScheduleCard(
              schedule: schedules[index],
              isAdmin: widget.isAdmin,
              currentUid: _currentUid,
              onDelete: (date) {
                context.read<ScheduleCubit>().deleteSchedule(date);
              },
              onToggleAvailability: (date, slot) {
                context.read<ScheduleCubit>().updateTimeSlot(
                  dateId: date,
                  slot: slot,
                );
              },
              onBookSlot: (date, slot) async {
                // تحديث الحجز بكتابة UID في bookingId
                final updated = slot.copyWith(bookingId: _currentUid);
                await FirebaseFirestore.instance
                    .collection('schedules')
                    .doc(date)
                    .update({
                      'slots': FieldValue.arrayRemove([slot.toJson()]),
                    });
                await FirebaseFirestore.instance
                    .collection('schedules')
                    .doc(date)
                    .update({
                      'slots': FieldValue.arrayUnion([updated.toJson()]),
                    });
                // إعادة تحميل البيانات
                context.read<ScheduleCubit>().loadSchedules();
              },
            );
          },
        );
      },
    );
  }
}

/// كرت عرض جدول يومي
class ScheduleCard extends StatefulWidget {
  final ScheduleModel schedule;
  final bool isAdmin;
  final String currentUid;
  final void Function(String date) onDelete;
  final void Function(String date, TimeSlot slot) onToggleAvailability;
  final Future<void> Function(String date, TimeSlot slot) onBookSlot;

  const ScheduleCard({
    Key? key,
    required this.schedule,
    required this.isAdmin,
    required this.currentUid,
    required this.onDelete,
    required this.onToggleAvailability,
    required this.onBookSlot,
  }) : super(key: key);

  @override
  _ScheduleCardState createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final allSlots =
        widget.isAdmin
            ? widget.schedule.slots
            : widget.schedule.slots
                .where((s) => s.available && s.bookingId == null)
                .toList();
    final preview = allSlots.take(4).toList();
    List<TimeSlot> more = allSlots.length > 4 ? allSlots.skip(4).toList() : [];

    return Dismissible(
      key: ValueKey(widget.schedule.date),
      direction:
          widget.isAdmin ? DismissDirection.startToEnd : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        widget.onDelete(widget.schedule.date);
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildChips(preview),
                  if (_expanded && more.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildChips(more),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.schedule.date,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        AnimatedRotation(
          turns: _expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 400),
          child: const Icon(Icons.keyboard_arrow_down),
        ),
      ],
    );
  }

  Widget _buildChips(List<TimeSlot> slots) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          slots
              .map(
                (s) => _SlotChip(
                  slot: s,
                  isAdmin: widget.isAdmin,
                  onToggle: () {
                    if (widget.isAdmin) {
                      widget.onToggleAvailability(widget.schedule.date, s);
                    } else {
                      widget.onBookSlot(widget.schedule.date, s);
                    }
                  },
                ),
              )
              .toList(),
    );
  }
}

/// شريحة عرض الموعد
class _SlotChip extends StatelessWidget {
  final TimeSlot slot;
  final bool isAdmin;
  final VoidCallback onToggle;

  const _SlotChip({
    Key? key,
    required this.slot,
    required this.isAdmin,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final disabled = slot.bookingId != null;
    return FilterChip(
      label: Text(slot.time),
      selected: isAdmin ? slot.available : false,
      showCheckmark: false,
      onSelected: disabled ? null : (_) => onToggle(),
      selectedColor: Colors.green.shade200,
      disabledColor: Colors.grey.shade400,
      labelStyle: TextStyle(color: disabled ? Colors.white : Colors.black),
    );
  }
}
