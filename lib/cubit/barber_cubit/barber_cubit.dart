// blocs/barber/barber_cubit.dart

import 'package:barber/constants.dart';
import 'package:barber/models/barber_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'barber_state.dart';

class BarberCubit extends Cubit<BarberState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BarberCubit() : super(BarberInitial());

  Future<void> addBarber(Users barber) async {
    try {
      emit(BarberLoading());

      await _firestore
          .collection('Users')
          .doc(kUid.toString())
          .set(barber.toJson());

      emit(BarberSuccess());
    } catch (e) {
      emit(BarberFailure(e.toString()));
    }
  }
}
