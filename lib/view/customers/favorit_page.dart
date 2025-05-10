import '../../Implementation/customers/fierstore_favorit_repository.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../cubit/favorit_cubit/favorit_cubit_cubit.dart';
import '../../widget/customer/list_favorit_bloc.dart';
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
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
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
          authState is Authenticated ? ListFavoritBloc() : SizedBox(),
        ],
      ),
    );
  }
}
