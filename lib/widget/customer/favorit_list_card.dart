import 'package:barber/models/favorit_model.dart';
import 'package:barber/models/provider_model.dart';

import 'package:flutter/material.dart';

class FavoritListCard extends StatelessWidget {
  final FavoritModel provider;

  const FavoritListCard({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        title: Text(provider.name),
        subtitle: Text(provider.phone),
        trailing: Icon(
          Icons.circle,
          size: 12,
          color: true ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
