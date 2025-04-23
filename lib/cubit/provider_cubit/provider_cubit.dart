// blocs/barber/barber_cubit.dart

import 'package:barber/constants.dart';
import 'package:barber/models/provider_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'provider_state.dart';

class ProviderCubit extends Cubit<ProviderState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProviderCubit() : super(ProviderInitial());

  Future<void> addBarber(ProviderModel barber) async {
    try {
      emit(ProviderLoading());

      await _firestore
          .collection('Users')
          .doc(kUid.toString())
          .set(barber.toJson());

      emit(ProviderSuccess());
    } catch (e) {
      emit(ProviderFailure(e.toString()));
    }
  }
}
