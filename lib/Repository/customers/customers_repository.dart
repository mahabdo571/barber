import 'package:barber/models/customers_model.dart';

abstract class CustomersRepository {
  Future<CustomerModel> getCustomerById(String customerId);
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
}
