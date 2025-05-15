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
  Business? _currentBusiness;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _checkAuthAndLoadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      // Tab change completed
      if (_tabController.index == 0 && _currentBusiness != null) {
        // When returning to Services tab (index 0), reload services
        context.read<BusinessCubit>().loadBusinessServices(
          _currentBusiness!.id,
        );
      }
    }
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
    } else if (message.contains('failed-precondition') ||
        message.contains('multiple attempts')) {
      setState(() {
        _error = 'حدث خطأ في الاتصال بقاعدة البيانات. جاري إعادة المحاولة...';
        _isLoading = false;
      });
      // Retry after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _loadData();
        }
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
                _currentBusiness = state.business;
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
            } else if (state is BusinessServicesLoaded) {
              setState(() {
                _currentBusiness = state.business;
              });
            } else if (state is BusinessProfileUpdated) {
              setState(() {
                _currentBusiness = state.business;
              });
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
        if (state is BusinessLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        Business? business;
        List<Service> services = [];

        if (state is BusinessServicesLoaded) {
          business = state.business;
          services = state.services;
        } else if (state is BusinessProfileLoaded) {
          business = state.business;
          // If we have business but no services, trigger services load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<BusinessCubit>().loadBusinessServices(business!.id);
          });
        } else if (state is BusinessProfileUpdated) {
          business = state.business;
          // If we have business but no services, trigger services load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<BusinessCubit>().loadBusinessServices(business!.id);
          });
        }

        if (business == null) {
          return const Center(child: Text('خطأ: لم يتم العثور على معرف العمل'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(context, business!.id),
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
                                            business!.id,
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

  void _showAddServiceDialog(BuildContext context, String businessId) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(businessId: businessId),
    );
  }

  void _showEditServiceDialog(
    BuildContext context,
    Service service,
    String businessId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) =>
              ServiceFormDialog(service: service, businessId: businessId),
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

class _AvailabilityTab extends StatefulWidget {
  @override
  State<_AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<_AvailabilityTab> {
  void _showGenerateTimeSlotsDialog(BuildContext context, Business business) {
    showDialog(
      context: context,
      builder: (context) => TimeSlotGeneratorDialog(business: business),
    );
  }

  void _showDeleteSlotDialog(
    BuildContext context,
    TimeSlot slot,
    String businessId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف الموعد'),
            content: Text(
              'هل أنت متأكد من حذف موعد ${DateFormat('HH:mm').format(slot.startTime)}؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<BusinessCubit>().deleteTimeSlot(
                    slot.id,
                    businessId,
                    slot.startTime,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDateDialog(
    BuildContext context,
    DateTime date,
    String businessId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف جميع مواعيد اليوم'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل أنت متأكد من حذف جميع مواعيد يوم ${DateFormat('yyyy-MM-dd').format(date)}؟',
                ),
                const SizedBox(height: 8),
                const Text(
                  'سيتم حذف جميع المواعيد المتاحة في هذا اليوم بشكل نهائي.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<BusinessCubit>().deleteTimeSlotsByDate(
                    businessId,
                    date,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessCubit, BusinessState>(
      listener: (context, state) {
        if (state is BusinessError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BusinessLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        Business? business;
        List<TimeSlot> slots = [];

        if (state is BusinessTimeSlotsLoaded) {
          slots = state.slots;
          business = state.business;
        } else if (state is BusinessServicesLoaded ||
            state is BusinessProfileLoaded ||
            state is BusinessProfileUpdated) {
          business =
              state is BusinessServicesLoaded
                  ? state.business
                  : state is BusinessProfileLoaded
                  ? state.business
                  : (state as BusinessProfileUpdated).business;

          // تحميل المواعيد عند تغيير الحالة
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<BusinessCubit>().loadAvailableTimeSlots(
              business!.id,
              DateTime.now(),
            );
          });
        }

        if (business == null) {
          return const Center(child: Text('خطأ: لم يتم العثور على معرف العمل'));
        }

        // تجميع المواعيد حسب التاريخ
        final groupedSlots = <DateTime, List<TimeSlot>>{};
        for (var slot in slots) {
          final date = DateTime(
            slot.startTime.year,
            slot.startTime.month,
            slot.startTime.day,
          );
          if (!groupedSlots.containsKey(date)) {
            groupedSlots[date] = [];
          }
          groupedSlots[date]!.add(slot);
        }

        // ترتيب التواريخ تصاعدياً
        final sortedDates =
            groupedSlots.keys.toList()..sort((a, b) => a.compareTo(b));

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<BusinessCubit>().loadAvailableTimeSlots(
              business!.id,
              DateTime.now(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      () => _showGenerateTimeSlotsDialog(context, business!),
                  icon: const Icon(Icons.add),
                  label: const Text('إنشاء مواعيد جديدة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      groupedSlots.isEmpty
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
                            itemCount: sortedDates.length,
                            itemBuilder: (context, index) {
                              final date = sortedDates[index];
                              final dateSlots = groupedSlots[date]!;

                              // ترتيب المواعيد حسب الوقت
                              dateSlots.sort(
                                (a, b) => a.startTime.compareTo(b.startTime),
                              );

                              return Card(
                                child: ExpansionTile(
                                  title: Text(
                                    DateFormat('yyyy-MM-dd').format(date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'عدد المواعيد: ${dateSlots.length}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _showDeleteDateDialog(
                                          context,
                                          date,
                                          business!.id,
                                        ),
                                  ),
                                  children:
                                      dateSlots.map((slot) {
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.access_time,
                                          ),
                                          title: Text(
                                            DateFormat(
                                              'HH:mm',
                                            ).format(slot.startTime),
                                          ),
                                          subtitle: Text(
                                            'حتى: ${DateFormat('HH:mm').format(slot.endTime)}',
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _showDeleteSlotDialog(
                                                  context,
                                                  slot,
                                                  business!.id,
                                                ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        );
      },
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('HH:mm').format(slot.startTime),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const Divider(),
                              if (slot.customerName != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(width: 8),
                                    Text(
                                      'العميل: ${slot.customerName}',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (slot.serviceName != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.design_services),
                                    const SizedBox(width: 8),
                                    Text(
                                      'الخدمة: ${slot.serviceName}',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (slot.notes != null &&
                                  slot.notes!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.note),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'ملاحظات: ${slot.notes}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
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
