import 'package:barber/cubit/favorit_cubit/favorit_cubit_cubit.dart';
import 'package:barber/helper/app_router.dart';
import 'package:barber/helper/help_metod.dart';
import 'package:barber/view/provider/services/services_page.dart';
import 'package:barber/widget/customer/favorit_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ListFavoritBloc extends StatelessWidget {
  const ListFavoritBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritCubitCubit, FavoritCubitState>(
      builder: (context, state) {
        if (state is FavoritSuccess) {
          final model = state.favorits;

          return ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: model.length,
            itemBuilder: (context, index) {
              final person = model[index];
              return Dismissible(
                key: Key(person.phone),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${person.name} تم حذفه')),
                  );
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: Colors.red,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    context.go(
                      '${AppRouter.servicesRoute}/${model[index].uid}',
                    );

                   // gotoPage_push(context, ServicesPage(uid: model[index].uid));
                  },
                  child: FavoritListCard(provider: model[index]),
                ),
              );
            },
          );
        } else if (state is FavoritLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is FavoritFailure) {
          return Center(child: Text('خطأ ${state.error}'));
        } else {
          return SizedBox(height: 1);
        }
      },
    );
  }
}
