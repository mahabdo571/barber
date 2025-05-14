import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/storage_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/business/data/repositories/business_repository_impl.dart';
import '../../features/business/domain/repositories/business_repository.dart';
import '../../features/business/presentation/cubit/business_cubit.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/presentation/cubit/customer_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator(SharedPreferences prefs) async {
  // Core
  getIt.registerLazySingleton<StorageService>(() => StorageServiceImpl(prefs));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<BusinessRepository>(
    () => BusinessRepositoryImpl(),
  );

  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(),
  );

  // Cubits
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt()));

  getIt.registerFactory<BusinessCubit>(() => BusinessCubit(getIt()));

  getIt.registerFactory<CustomerCubit>(() => CustomerCubit(getIt()));
}
