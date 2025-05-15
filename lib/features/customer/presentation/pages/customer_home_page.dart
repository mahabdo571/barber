import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/customer_cubit.dart';
import '../../domain/entities/booking.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final cubit = context.read<CustomerCubit>();
    // Load customer profile
    cubit.loadCustomer('current_user_id'); // TODO: Get from auth
    // Load upcoming bookings
    cubit.loadUpcomingBookings('current_user_id'); // TODO: Get from auth
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.access_time, color: Colors.white)),
            Tab(text: 'حجوزاتي'),
            Tab(text: 'المفضلة'),
          ],
        ),
      ),
      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError) {
            return Center(child: Text(state.message));
          }

          return TabBarView(
            controller: _tabController,
            children: [_SalonsTab(), _BookingsTab(), _FavoritesTab()],
          );
        },
      ),
    );
  }
}

class _SalonsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('قائمة الصالونات')); // TODO: Implement
  }
}

class _BookingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerBookingsLoaded) {
          return state.bookings.isEmpty
              ? const Center(child: Text('لا توجد حجوزات'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return _BookingCard(booking: booking);
                },
              );
        }
        return const SizedBox();
      },
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('الصالونات المفضلة')); // TODO: Implement
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(DateFormat('yyyy-MM-dd HH:mm').format(booking.startTime)),
        subtitle: Text('الحالة: ${_getStatusText(booking.status)}'),
        trailing:
            booking.status == 'pending' || booking.status == 'confirmed'
                ? TextButton(
                  onPressed: () {
                    context.read<CustomerCubit>().cancelBooking(
                      booking.id,
                      booking.customerId,
                    );
                  },
                  child: const Text('إلغاء'),
                )
                : null,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'cancelled':
        return 'ملغي';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }
}
