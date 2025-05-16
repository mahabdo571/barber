import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../cubit/customer_cubit.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../presentation/pages/salon_services_page.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final cubit = context.read<CustomerCubit>();
      cubit.loadCustomer(authState.userId);
      cubit.loadCustomerBookings(authState.userId);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.search, size: 24), text: 'بحث', height: 64),
            Tab(
              icon: Icon(Icons.calendar_month, size: 24),
              text: 'حجوزاتي',
              height: 64,
            ),
            Tab(
              icon: Icon(Icons.favorite, size: 24),
              text: 'المفضلة',
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
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _loadData();
          } else if (state is AuthUnauthenticated) {
            context.go(AppConstants.routeLogin);
          }
        },
        child: BlocConsumer<CustomerCubit, CustomerState>(
          listener: (context, state) {
            if (state is CustomerError) {
              _showMessage(state.message, isError: true);
            } else if (state.message?.isNotEmpty ?? false) {
              _showMessage(state.message!);
            }

            // Handle profile not found
            if (state is CustomerError &&
                state.message.contains('Customer not found')) {
              context.go(AppConstants.routeCustomerProfile);
              return;
            }

            if (state is CustomerProfileCreated) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                context.read<CustomerCubit>().loadCustomer(authState.userId);
              }
            }
          },
          builder: (context, state) {
            if (state is CustomerLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle profile not found
            if (state is CustomerError &&
                state.message.contains('Customer not found')) {
              context.go(AppConstants.routeCustomerProfile);
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _SalonsTab(),
                _BookingsTab(),
                _FavoritesTab(),
                _SettingsTab(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SalonsTab extends StatefulWidget {
  @override
  State<_SalonsTab> createState() => _SalonsTabState();
}

class _SalonsTabState extends State<_SalonsTab> {
  final _phoneController = TextEditingController();
  Business? _foundBusiness;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _searchBusiness() async {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _error = 'الرجاء إدخال رقم الهاتف';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _foundBusiness = null;
    });

    try {
      final business = await context
          .read<CustomerCubit>()
          .searchBusinessByPhone(_phoneController.text);
      setState(() {
        _foundBusiness = business;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم هاتف الصالون',
                      hintText: 'أدخل رقم هاتف الصالون للبحث',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _searchBusiness,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('بحث'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          else if (_foundBusiness != null)
            Expanded(
              child: _BusinessCard(
                business: _foundBusiness!,
                onFavoritePressed: () {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<CustomerCubit>().toggleFavoriteBusiness(
                      authState.userId,
                      _foundBusiness!.id,
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback onFavoritePressed;

  const _BusinessCard({
    required this.business,
    required this.onFavoritePressed,
  });

  Stream<bool> _getFavoriteStatus(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return Stream.value(false);

    return FirebaseFirestore.instance
        .collection(AppConstants.colUsers)
        .doc(authState.userId)
        .collection('favorites')
        .doc(business.id)
        .snapshots()
        .map((doc) => doc.exists);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              business.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: business.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                business.isActive ? 'مفتوح' : 'مغلق',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const Divider(),
          StreamBuilder<bool>(
            stream: _getFavoriteStatus(context),
            builder: (context, snapshot) {
              final isFavorite = snapshot.data ?? false;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    SalonServicesPage(business: business),
                          ),
                        );
                      },
                      icon: const Icon(Icons.store),
                      label: const Text('عرض الخدمات'),
                    ),
                    TextButton.icon(
                      onPressed: onFavoritePressed,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      label: Text(
                        isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BookingsTab extends StatefulWidget {
  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cleanup past bookings when tab is first opened
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<CustomerCubit>().cleanupPastBookings(authState.userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: Text('Please log in to view bookings'));
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'الحجوزات القادمة'),
            Tab(text: 'جميع الحجوزات'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Upcoming bookings
              StreamBuilder<List<Booking>>(
                stream: context
                    .read<CustomerCubit>()
                    .streamCustomerUpcomingBookings(authState.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final bookings = snapshot.data ?? [];

                  if (bookings.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد حجوزات قادمة',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'ابحث عن صالون وقم بحجز موعد',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _BookingCard(
                        booking: booking,
                        showCancelButton: true,
                      );
                    },
                  );
                },
              ),

              // All bookings
              StreamBuilder<List<Booking>>(
                stream: context.read<CustomerCubit>().streamCustomerBookings(
                  authState.userId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final bookings = snapshot.data ?? [];

                  if (bookings.isEmpty) {
                    return const Center(child: Text('لا توجد حجوزات'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      // Only show cancel button for pending/confirmed and future bookings
                      final now = DateTime.now();
                      final showCancel =
                          (booking.status == 'pending' ||
                              booking.status == 'confirmed') &&
                          booking.startTime.isAfter(now);

                      return _BookingCard(
                        booking: booking,
                        showCancelButton: showCancel,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool showCancelButton;

  const _BookingCard({required this.booking, this.showCancelButton = false});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM', 'ar');
    final timeFormat = DateFormat('h:mm a', 'ar');
    final isPastBooking = booking.startTime.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salon name header
            Row(
              children: [
                const Icon(Icons.store, color: Colors.grey),
                const SizedBox(width: 8),
                FutureBuilder<Business>(
                  future: context.read<CustomerCubit>().getBusinessById(
                    booking.businessId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('جاري التحميل...');
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text(booking.businessId);
                    }

                    return Text(
                      snapshot.data!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),

            // Service details
            Row(
              children: [
                const Icon(Icons.design_services, color: Colors.grey),
                const SizedBox(width: 8),
                FutureBuilder<List<Service>>(
                  future: context.read<CustomerCubit>().getBusinessServices(
                    booking.businessId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('جاري التحميل...');
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text(booking.serviceId);
                    }

                    final service = snapshot.data!.firstWhere(
                      (s) => s.id == booking.serviceId,
                      orElse:
                          () => Service(
                            id: booking.serviceId,
                            businessId: booking.businessId,
                            name: 'غير معروف',
                            price: 0,
                            duration: 0,
                            isActive: true,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                    );

                    return Text(service.name);
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date and time
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(booking.startTime)} - ${timeFormat.format(booking.startTime)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isPastBooking ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),

            if (booking.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.notes!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            if (showCancelButton || !isPastBooking)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showCancelButton)
                    TextButton.icon(
                      onPressed: () => _showCancelDialog(context),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        'إلغاء الحجز',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (!isPastBooking)
                    TextButton.icon(
                      onPressed: () => _showEditNotesDialog(context),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('تعديل الملاحظات'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إلغاء الحجز'),
            content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<CustomerCubit>().cancelBooking(
                      booking.id,
                      authState.userId,
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('تأكيد الإلغاء'),
              ),
            ],
          ),
    );
  }

  void _showEditNotesDialog(BuildContext context) {
    final notesController = TextEditingController(text: booking.notes);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تعديل الملاحظات'),
            content: TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'أضف ملاحظات للصالون حول حجزك',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<CustomerCubit>().updateBookingNotes(
                      booking.id,
                      notesController.text,
                      authState.userId,
                    );
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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

class _FavoritesTab extends StatefulWidget {
  @override
  State<_FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<_FavoritesTab> {
  Stream<QuerySnapshot> _getFavoritesStream(String userId) {
    return FirebaseFirestore.instance
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('favorites')
        .snapshots();
  }

  Future<Business?> _getBusinessDetails(String businessId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection(AppConstants.colBusinesses)
              .doc(businessId)
              .get();

      if (!doc.exists) return null;
      return Business.fromMap(doc.data()!..['id'] = doc.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: Text('Please log in to view favorites'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _getFavoritesStream(authState.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
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
              children: const [
                Icon(Icons.favorite_border, size: 64),
                SizedBox(height: 16),
                Text('لا توجد صالونات في المفضلة'),
                SizedBox(height: 8),
                Text('ابحث عن صالون وأضفه إلى المفضلة'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}), // Refresh the stream
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return FutureBuilder<Business?>(
                future: _getBusinessDetails(doc.id),
                builder: (context, businessSnapshot) {
                  if (businessSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  if (!businessSnapshot.hasData ||
                      businessSnapshot.data == null) {
                    return const SizedBox(); // Skip if business not found
                  }

                  return _FavoriteBusinessCard(
                    business: businessSnapshot.data!,
                    onRemove: () {
                      context.read<CustomerCubit>().toggleFavoriteBusiness(
                        authState.userId,
                        doc.id,
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _FavoriteBusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback onRemove;

  const _FavoriteBusinessCard({required this.business, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              business.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
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
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: business.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                business.isActive ? 'مفتوح' : 'مغلق',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SalonServicesPage(business: business),
                      ),
                    );
                  },
                  icon: const Icon(Icons.store),
                  label: const Text('عرض الخدمات'),
                ),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  label: const Text('إزالة من المفضلة'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Always show the logout button at the bottom
        Widget logoutButton = Card(
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
        );

        if (state is CustomerError && state.message.contains('not found')) {
          // Show profile creation form if customer not found
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'أكمل ملفك الشخصي',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _CreateProfileForm(),
                  ),
                ),
                const SizedBox(height: 16),
                logoutButton,
              ],
            ),
          );
        }

        if (state is CustomerError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<CustomerCubit>().loadCustomer(
                        authState.userId,
                      );
                    }
                  },
                  child: const Text('إعادة المحاولة'),
                ),
                const SizedBox(height: 16),
                logoutButton,
              ],
            ),
          );
        }

        Customer? customer;
        if (state is CustomerProfileLoaded) {
          customer = state.customer;
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (customer != null) ...[
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(customer.name),
                      subtitle: Text(customer.phone),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            logoutButton,
          ],
        );
      },
    );
  }
}

class _CreateProfileForm extends StatefulWidget {
  @override
  State<_CreateProfileForm> createState() => _CreateProfileFormState();
}

class _CreateProfileFormState extends State<_CreateProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: state is! CustomerLoading,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  hintText: 'أدخل اسمك الكامل',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                enabled: state is! CustomerLoading,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '+966XXXXXXXXX',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:
                    state is CustomerLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            final authState = context.read<AuthCubit>().state;
                            if (authState is AuthAuthenticated) {
                              final customer = Customer(
                                id: authState.userId,
                                name: _nameController.text,
                                phone: _phoneController.text,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              context.read<CustomerCubit>().createCustomer(
                                customer,
                              );
                            }
                          }
                        },
                child:
                    state is CustomerLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('حفظ الملف الشخصي'),
              ),
            ],
          ),
        );
      },
    );
  }
}
