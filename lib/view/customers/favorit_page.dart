import 'package:barber/Implementation/customers/fierstore_favorit_repository.dart';
import 'package:barber/cubit/favorit_cubit/favorit_cubit_cubit.dart';
import 'package:barber/widget/customer/list_favorit_bloc.dart';
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
        appBar: AppBar(title: const Text('المفضلة'), centerTitle: true),
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
            ListFavoritBloc(),
          ],
        ),
      ),
    );
  }
}
