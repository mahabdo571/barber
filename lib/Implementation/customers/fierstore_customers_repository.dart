import 'package:barber/Repository/customers/customers_repository.dart';
import 'package:barber/models/customers_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants.dart';
import '../../models/service_model.dart';

/// Implementation: Firestore
class FierstoreCustomersRepository implements CustomersRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FierstoreCustomersRepository({FirebaseFirestore? firestore, String? userId})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _userId = userId ?? FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _customerColl =>
      _firestore.collection(kDBUser);

  @override
  Future<CustomerModel> getCustomerById(String customerId) async {
    // Fetch the document snapshot
    final docSnapshot = await _customerColl.doc(customerId).get();

    // Extract data as a map
    final data = docSnapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Customer with id $customerId not found');
    }

    // Map the data to your model (assuming you have a fromMap constructor)
    return CustomerModel.fromJson(data, customerId);
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
  await _customerColl
          .doc(kUid.toString())
          .set(customer.toJson());
  
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await _customerColl.doc(customer.id).update(customer.toJson());
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await _customerColl.doc(customerId).delete();
  }
}
