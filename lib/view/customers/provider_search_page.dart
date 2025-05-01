import 'package:barber/cubit/auth/auth_cubit.dart';
import 'package:barber/cubit/auth/auth_state.dart';
import 'package:barber/cubit/provider_search_cubit/provider_search_cubit.dart';
import 'package:barber/cubit/provider_search_cubit/provider_search_state.dart';
import 'package:barber/helper/qr_scan_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page to search providers by phone & add to favorites
class ProviderSearchPage extends StatefulWidget {
  @override
  State<ProviderSearchPage> createState() => _ProviderSearchPageState();
}

class _ProviderSearchPageState extends State<ProviderSearchPage> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final currntUser = (authCubit.state as Authenticated).authUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text('البحث عن مزود خدمة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () async {
              // Placeholder for future QR scan
              final result = await scanQRCode(context);
              if (result != null) {
                _phoneController.text = result;
                context.read<ProviderSearchCubit>().searchProvider(result);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Phone input + search button
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '0566123456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    context.read<ProviderSearchCubit>().searchProvider(
                      _phoneController.text.trim(),
                    );
                    context.read<ProviderSearchCubit>().checkItsInFavorites(
                      currntUser.uid,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            // Search results & add button
            BlocConsumer<ProviderSearchCubit, ProviderSearchState>(
              listener: (context, state) {
                if (state.addedToFavorites) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تمت الإضافة إلى المفضلة')),
                  );
                }
              },
              builder: (context, state) {
                switch (state.status) {
                  case ProviderSearchStatus.loading:
                    return CircularProgressIndicator();
                  case ProviderSearchStatus.error:
                    return Text('خطأ: ${state.errorMessage}');
                  case ProviderSearchStatus.notFound:
                    return Text('لم يتم العثور على مزود خدمة');
                  case ProviderSearchStatus.ItsInFavorites:
                    return Text(' هذا المزود تم اضافته للمفضلة مسبقا');
                  case ProviderSearchStatus.success:
                    final provider = state.provider!;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(provider.name),
                        subtitle: Text(provider.phone),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context
                                .read<ProviderSearchCubit>()
                                .addProviderToFavorites(currntUser.uid);
                            _phoneController.text = '';
                          },
                          child: Text('أضف للمفضلة'),
                        ),
                      ),
                    );
                  default:
                    return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
