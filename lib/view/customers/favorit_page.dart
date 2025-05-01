import 'package:barber/Implementation/customers/fierstore_favorit_repository.dart';
import 'package:barber/cubit/favorit_cubit/favorit_cubit_cubit.dart';
import 'package:barber/models/favorit_repository.dart';
import 'package:barber/widget/customer/favorit_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritListPage extends StatefulWidget {
  const FavoritListPage({Key? key}) : super(key: key);

  @override
  _FavoritListPageState createState() => _FavoritListPageState();
}

class _FavoritListPageState extends State<FavoritListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              FavoritCubitCubit(repository: FierstoreFavoritRepository())
                ..loadFavoritByCoustomerId(),
      child: Scaffold(
        appBar: AppBar(title: const Text('قائمة الأشخاص'), centerTitle: true),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            BlocBuilder<FavoritCubitCubit, FavoritCubitState>(
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
                              Text(
                                'حذف',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        child: FavoritListCard(provider: model[index]),
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
            ),
          ],
        ),
      ),
    );
  }
}
