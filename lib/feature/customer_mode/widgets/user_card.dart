
import 'package:barber/feature/users/cubit/user_search_cubit.dart';
import 'package:barber/feature/users/models/store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserCard extends StatelessWidget {
  final StoreModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.store),
                const SizedBox(width: 8),
                Text(
                  user.storeName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.mapPin),
                const SizedBox(width: 8),
                Text(user.location),
              ],
            ),
            const SizedBox(height: 8),
            Text("ملاحظات: ${user.notes}"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: () {
                    context.read<UserSearchCubit>().addFavorite(user.uid);
                }, icon: const Icon(LucideIcons.star)),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.layoutList),
                  label: const Text("عرض الخدمات"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
