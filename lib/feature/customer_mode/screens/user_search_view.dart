import 'package:barber/feature/customer_mode/widgets/user_card.dart';
import 'package:barber/feature/users/cubit/user_search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';


class UserSearchView extends StatefulWidget {
  const UserSearchView({super.key});

  @override
  State<UserSearchView> createState() => _UserSearchViewState();
}

class _UserSearchViewState extends State<UserSearchView> {
  final TextEditingController _uidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("البحث عن مستخدم")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _uidController,
              decoration: const InputDecoration(
                labelText: 'رقم المستخدم',
                prefixIcon: Icon(LucideIcons.search),
              ),
            ),
          
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<UserSearchCubit>().searchUser(
                      _uidController.text.trim(),
                      'company'
                    );
              },
              icon: const Icon(LucideIcons.searchCheck),
              label: const Text("بحث"),
            ),
            const SizedBox(height: 16),
            BlocBuilder<UserSearchCubit, UserSearchState>(
              builder: (context, state) {
                if (state is UserSearchLoading) {
                  return const CircularProgressIndicator();
                } else if (state is UserSearchSuccess) {
                  return UserCard(user: state.user);
                } else if (state is UserSearchEmpty) {
                  return const Text("لا يوجد مستخدم بهذا الرقم والدور.");
                } else if (state is UserSearchError) {
                  return Text("خطأ: ${state.message}");
                }
                return const SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }
}
