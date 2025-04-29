// blocs/barber/barber_cubit.dart

import 'package:barber/constants.dart';
import 'package:barber/cubit/auth/auth_cubit.dart';
import 'package:barber/cubit/auth/auth_state.dart';
import 'package:barber/models/provider_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'profile_provider_state.dart';

class ProfileProviderCubit extends Cubit<ProfileProviderState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authCubit = GetIt.I<AuthCubit>();
  ProfileProviderCubit() : super(ProfileProviderInitial());

  Future<void> addBarber(ProviderModel barber) async {
        final uid = (_authCubit.state as Authenticated).authUser!.uid;

    try {
      emit(ProfileProviderLoading());

      await _firestore
          .collection(kDBUser)
          .doc(uid)
          .set(barber.toJson());

      emit(ProfileProviderSuccess());
    } catch (e) {
      emit(ProfileProviderFailure(e.toString()));
    }
  }
}
