import 'package:barber/feature/users/cubit/user_search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/user_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المفضلة")),
      body: BlocBuilder<UserSearchCubit, UserSearchState>(
        builder: (context, state) {
          if (state is UserSearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserSearchError) {
            return Center(child: Text("خطأ: ${state.message}"));
          } else if (state is FavoritesListLoadedSuccessfully) {
            if (state.list.isEmpty) {
              return const Center(child: Text("لا يوجد مفضلات"));
            } else {
              return ListView.builder(
                itemCount: state.list.length,
                itemBuilder: (context, index) {
                  return UserCard(user: state.list[index]);
                },
              );
            }
          } else {
            return const Center(child: Text("لا يوجد مفضلات"));
          }
        },
      ),
    );
  }
}
