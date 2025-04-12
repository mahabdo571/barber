import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'صالون الحلاقة - حجز موعد',
//       theme: ThemeData(
//         useMaterial3: true,
//         fontFamily: 'Tajawal',
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.blue,
//           brightness: Brightness.light,
//         ),
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//           bodyLarge: TextStyle(fontSize: 16),
//           bodyMedium: TextStyle(fontSize: 14),
//         ),
//       ),
//       home:,
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _currentStep = 1;
  final CustomerInfo customerInfo = const CustomerInfo(
    name: 'عبدالله محمد',
    phone: '0512345678',
  );
  final BarberInfo barberInfo = BarberInfo(
    id: 'ahmed123',
    name: 'الحلاق أحمد',
    shopName: 'صالون أحمد الأنيق',
    services: [
      Service(id: 'svc001', name: 'قص شعر', price: 50, durationMinutes: 30),
      Service(id: 'svc002', name: 'حلاقة لحية', price: 30, durationMinutes: 20),
      Service(id: 'svc004', name: 'سيشوار', price: 25, durationMinutes: 15),
      Service(id: 'svc006', name: 'تنظيف بشرة', price: 80, durationMinutes: 45),
    ],
    availability: {
      "2024-07-20": [
        "09:00",
        "09:30",
        "10:30",
        "11:00",
        "11:30",
        "14:00",
        "15:30",
        "16:00",
      ],
      "2024-07-21": [
        "09:00",
        "10:00",
        "10:30",
        "11:30",
        "14:30",
        "15:00",
        "15:30",
        "16:30",
      ],
      "2024-07-23": [
        "09:30",
        "10:00",
        "11:00",
        "14:00",
        "15:00",
        "16:00",
        "16:30",
      ],
    },
  );

  Service? _selectedService;
  String? _selectedDate;
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('حجز موعد جديد'), centerTitle: true),
        body: Column(
          children: [
            _buildProgressSteps(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepIndicator(1, Icons.cut, 'اختيار الخدمة'),
          _buildStepIndicator(2, Icons.calendar_month, 'اختيار التاريخ'),
          _buildStepIndicator(3, Icons.access_time, 'اختيار الوقت'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, IconData icon, String label) {
    final isActive = _currentStep == stepNumber;
    final isCompleted = _currentStep > stepNumber;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isCompleted
                      ? colorScheme.primary
                      : isActive
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainer,
              border: Border.all(
                color:
                    isCompleted
                        ? colorScheme.primary
                        : isActive
                        ? colorScheme.outline
                        : colorScheme.outlineVariant,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color:
                  isCompleted
                      ? colorScheme.onPrimary
                      : isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  isCompleted || isActive
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildServiceSelectionStep();
      case 2:
        return _buildDateSelectionStep();
      case 3:
        return _buildTimeSelectionStep();
      case 4:
        return _buildConfirmationStep();
      default:
        return _buildServiceSelectionStep();
    }
  }

  Widget _buildServiceSelectionStep() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. اختر الخدمة المطلوبة:',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildServiceList(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed:
                    _selectedService != null
                        ? () => setState(() => _currentStep = 2)
                        : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('التالي'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: barberInfo.services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final service = barberInfo.services[index];
        return RadioListTile<Service>(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(service.name),
              Text(
                '${service.price} ر.س',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle:
              service.durationMinutes > 0
                  ? Text('المدة التقريبية: ${service.durationMinutes} دقيقة')
                  : null,
          value: service,
          groupValue: _selectedService,
          onChanged: (value) => setState(() => _selectedService = value),
        );
      },
    );
  }

  Widget _buildDateSelectionStep() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final availableDates =
        barberInfo.availability.keys
            .where((date) => barberInfo.availability[date]!.isNotEmpty)
            .map(DateTime.parse)
            .where(
              (date) => date.isAfter(
                DateTime.now().subtract(const Duration(days: 1)),
              ),
            )
            .toList()
          ..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. اختر التاريخ المناسب:',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text('الخدمة المختارة: ${_selectedService?.name ?? ''}'),
            const SizedBox(height: 16),
            if (availableDates.isEmpty)
              const Center(child: Text('لا توجد أيام متاحة للحجز حالياً'))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final date = availableDates[index];
                  final dayName = intl.DateFormat('EEEE', 'ar').format(date);
                  final dayMonth = intl.DateFormat('d MMM', 'ar').format(date);

                  return FilledButton.tonal(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) =>
                            _selectedDate == date.toIso8601String()
                                ? colorScheme.primaryContainer
                                : colorScheme.surface,
                      ),
                    ),
                    onPressed:
                        () => setState(
                          () => _selectedDate = date.toIso8601String(),
                        ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(dayMonth),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _currentStep = 1),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('السابق'),
                ),
                FilledButton.tonalIcon(
                  onPressed:
                      _selectedDate != null
                          ? () => setState(() => _currentStep = 3)
                          : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('التالي'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectionStep() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final availableTimes =
        _selectedDate != null
            ? barberInfo.availability[_selectedDate!] ?? []
            : [];
    final formattedDate =
        _selectedDate != null
            ? intl.DateFormat(
              'EEEE، d MMMM y',
              'ar',
            ).format(DateTime.parse(_selectedDate!))
            : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3. اختر الوقت المناسب:',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text('الخدمة: ${_selectedService?.name ?? ''}'),
            Text('التاريخ: $formattedDate'),
            const SizedBox(height: 16),
            if (availableTimes.isEmpty)
              const Center(child: Text('لا توجد أوقات متاحة في هذا اليوم'))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: availableTimes.length,
                itemBuilder: (context, index) {
                  final time = availableTimes[index];
                  final timeFormat = intl.DateFormat.jm('ar');
                  final formattedTime = timeFormat.format(
                    DateTime(
                      2024,
                      1,
                      1,
                      int.parse(time.split(':')[0]),
                      int.parse(time.split(':')[1]),
                    ),
                  );

                  return FilledButton.tonal(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) =>
                            _selectedTime == time
                                ? colorScheme.primaryContainer
                                : colorScheme.surface,
                      ),
                    ),
                    onPressed: () => setState(() => _selectedTime = time),
                    child: Text(formattedTime),
                  );
                },
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _currentStep = 2),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('السابق'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _selectedTime != null ? _confirmBooking : null,
                  icon: const Icon(Icons.check),
                  label: const Text('تأكيد الحجز'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiaryContainer,
                    foregroundColor: colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate =
        _selectedDate != null
            ? intl.DateFormat(
              'EEEE، d MMMM y',
              'ar',
            ).format(DateTime.parse(_selectedDate!))
            : '';
    final formattedTime =
        _selectedTime != null
            ? intl.DateFormat.jm('ar').format(
              DateTime(
                2024,
                1,
                1,
                int.parse(_selectedTime!.split(':')[0]),
                int.parse(_selectedTime!.split(':')[1]),
              ),
            )
            : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 60, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'تم تأكيد حجزك بنجاح!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: colorScheme.onSurface),
                children: [
                  const TextSpan(text: 'تم حجز موعدك لخدمة '),
                  TextSpan(
                    text: '${_selectedService?.name ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '\nمع '),
                  TextSpan(
                    text: barberInfo.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '\nيوم '),
                  TextSpan(
                    text: formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '\nالساعة '),
                  TextSpan(
                    text: formattedTime,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    /* Navigate to appointments */
                  },
                  child: const Text('عرض مواعيدي'),
                ),
                FilledButton.tonal(
                  onPressed:
                      () => setState(() {
                        _currentStep = 1;
                        _selectedService = null;
                        _selectedDate = null;
                        _selectedTime = null;
                      }),
                  child: const Text('حجز موعد آخر'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking() {
    // Implement actual booking logic
    setState(() => _currentStep = 4);
  }
}

@immutable
class CustomerInfo {
  final String name;
  final String phone;

  const CustomerInfo({required this.name, required this.phone});
}

@immutable
class BarberInfo {
  final String id;
  final String name;
  final String shopName;
  final List<Service> services;
  final Map<String, List<String>> availability;

  const BarberInfo({
    required this.id,
    required this.name,
    required this.shopName,
    required this.services,
    required this.availability,
  });
}

@immutable
class Service {
  final String id;
  final String name;
  final int price;
  final int durationMinutes;

  const Service({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Service && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
