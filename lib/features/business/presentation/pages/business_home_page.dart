import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../cubit/business_cubit.dart';
import '../widgets/service_form_dialog.dart';
import '../widgets/time_slot_generator_dialog.dart';

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({super.key});

  @override
  State<BusinessHomePage> createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _timeFormat = DateFormat('HH:mm');
  String? _currentUserId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkAuthAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAuthAndLoadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.userId;
      _loadData();
    }
  }

  void _loadData() {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final cubit = context.read<BusinessCubit>();
    // Load business profile
    cubit.loadBusinessByOwnerId(_currentUserId!);
  }

  void _handleError(String message) {
    if (message.contains('No business profile found')) {
      context.go(AppConstants.routeBusinessProfile);
    } else if (message.contains('failed-precondition')) {
      setState(() {
        _error = 'جاري تهيئة قاعدة البيانات، يرجى المحاولة مرة أخرى بعد قليل';
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.go(AppConstants.routeLogin);
            } else if (state is AuthAuthenticated) {
              _currentUserId = state.userId;
              _loadData();
            }
          },
        ),
        BlocListener<BusinessCubit, BusinessState>(
          listener: (context, state) {
            if (state is BusinessProfileLoaded) {
              setState(() {
                _isLoading = false;
                _error = null;
              });
              // Load services when business profile is loaded
              context.read<BusinessCubit>().loadBusinessServices(
                state.business.id,
              );
              // Load today's bookings
              context.read<BusinessCubit>().loadBookedTimeSlots(
                state.business.id,
                DateTime.now(),
              );
            } else if (state is BusinessError) {
              _handleError(state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.design_services, size: 24),
                text: 'الخدمات',
                height: 64,
              ),
              Tab(
                icon: Icon(Icons.calendar_month, size: 24),
                text: 'المواعيد المتاحة',
                height: 64,
              ),
              Tab(
                icon: Icon(Icons.today, size: 24),
                text: 'حجوزات اليوم',
                height: 64,
              ),
              Tab(
                icon: Icon(Icons.settings, size: 24),
                text: 'الإعدادات',
                height: 64,
              ),
            ],
          ),
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _ServicesTab(),
                    _AvailabilityTab(),
                    _TodayAppointmentsTab(),
                    _SettingsTab(),
                  ],
                ),
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessCubit, BusinessState>(
      builder: (context, state) {
        final services = state is BusinessServicesLoaded ? state.services : [];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة خدمة جديدة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    services.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.design_services_outlined, size: 64),
                              SizedBox(height: 16),
                              Text('لا توجد خدمات مضافة'),
                              SizedBox(height: 8),
                              Text('اضغط على زر الإضافة لإضافة خدمة جديدة'),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.design_services),
                                title: Text(service.name),
                                subtitle: Text(
                                  'السعر: ${service.price} ريال - المدة: ${service.duration} دقيقة',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: service.isActive,
                                      onChanged: (value) {
                                        context
                                            .read<BusinessCubit>()
                                            .updateServiceStatus(
                                              service.id,
                                              value,
                                              service.businessId,
                                            );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          () => _showEditServiceDialog(
                                            context,
                                            service,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed:
                                          () => _showDeleteDialog(
                                            context,
                                            service,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ServiceFormDialog(),
    );
  }

  void _showEditServiceDialog(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(service: service),
    );
  }

  void _showDeleteDialog(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف الخدمة'),
            content: Text('هل أنت متأكد من حذف خدمة ${service.name}؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  context.read<BusinessCubit>().deleteService(
                    service.id,
                    service.businessId,
                  );
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }
}

class _AvailabilityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessCubit, BusinessState>(
      builder: (context, state) {
        final slots = state is BusinessTimeSlotsLoaded ? state.slots : [];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showGenerateTimeSlotsDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إنشاء مواعيد جديدة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    slots.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.calendar_month_outlined, size: 64),
                              SizedBox(height: 16),
                              Text('لا توجد مواعيد متاحة'),
                              SizedBox(height: 8),
                              Text('اضغط على زر الإضافة لإنشاء مواعيد جديدة'),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: slots.length,
                          itemBuilder: (context, index) {
                            final slot = slots[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.access_time),
                                title: Text(
                                  DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(slot.startTime),
                                ),
                                subtitle: Text(
                                  'حتى: ${DateFormat('HH:mm').format(slot.endTime)}',
                                ),
                                trailing: Switch(
                                  value: !slot.isBooked,
                                  onChanged: (value) {
                                    context
                                        .read<BusinessCubit>()
                                        .updateTimeSlotStatus(
                                          slot.id,
                                          !value,
                                          null,
                                        );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGenerateTimeSlotsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TimeSlotGeneratorDialog(),
    );
  }
}

class _TodayAppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessCubit, BusinessState>(
      builder: (context, state) {
        final slots = state is BusinessTimeSlotsLoaded ? state.slots : [];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              slots.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.event_available_outlined, size: 64),
                        SizedBox(height: 16),
                        Text('لا توجد حجوزات لليوم'),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(
                            DateFormat('HH:mm').format(slot.startTime),
                          ),
                          subtitle: Text(
                            'حتى: ${DateFormat('HH:mm').format(slot.endTime)}',
                          ),
                          // TODO: Add customer name from booking
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}

class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessCubit, BusinessState>(
      builder: (context, state) {
        Business? business;

        if (state is BusinessProfileLoaded) {
          business = state.business;
        } else if (state is BusinessProfileUpdated) {
          business = state.business;
        }

        if (business == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64),
                SizedBox(height: 16),
                Text('لا يمكن تحميل الإعدادات'),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(business.name),
                    subtitle: Text(business.phone),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.store),
                    title: const Text('حالة الصالون'),
                    subtitle: Text(
                      business.isActive ? 'مفتوح للحجوزات' : 'مغلق للحجوزات',
                    ),
                    value: business.isActive,
                    onChanged: (value) {
                      context.read<BusinessCubit>().updateBusinessStatus(
                        business!.id,
                        value,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('العنوان'),
                    subtitle: Text(business.address),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('الوصف'),
                    subtitle: Text(business.description),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('تسجيل الخروج'),
                          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.read<AuthCubit>().signOut();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('تسجيل الخروج'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
