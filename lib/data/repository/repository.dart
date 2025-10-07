import 'package:foodapp/data/model/Authen.dart';
import 'package:foodapp/data/model/F.A.Q.dart';
import 'package:foodapp/data/model/helper.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/model/Policy.dart';
import 'package:foodapp/data/model/payment_response.dart';
import 'package:foodapp/data/model/request.dart';
import 'package:foodapp/data/model/requestdetail.dart';

import '../model/TimeOff.dart';
import '../model/location.dart';
import '../model/service.dart';
import 'package:foodapp/data/source/source.dart';

abstract interface class Repository {
  Future<List<Helper>?> loadCleanerData();

  Future<List<Location>?> loadLocation();

  Future<List<Services>?> loadServices();

  Future<List<Customer>?> loadCustomer(String token);

  Future<Customer?> loadCustomerInfo(String phone, String token);

  Future<void> updateCustomer(Customer customer, String token);

  Future<List<Requests>?> loadRequest(String token);

  Future<List<Requests>?> loadCustomerRequest(String phone, String token);

  Future<List<Policy>?> loadPolicy();

  Future<List<FAQ>?> loadFAQ();

  Future<List<RequestDetail>?> loadRequestDetail(String token);

  Future<List<RequestDetail>?> loadRequestDetailId(
      List<String> id, String token);

  Future<List<TimeOff>?> loadTimeOff();

  Future<void> sendRequest(Requests requests, String token);

  Future<void> canceledRequest(String id, String token);

  Future<void> payRequest(String id, String token);

  Future<void> doneConfirmRequest(String id, String token);

  Future<void> sendMessage(String phone);

  Future<Map<String, dynamic>?> calculateCost(
      String service, String startTime, String endTime, String startDate);

  Future<void> sendCustomerRegisterRequest(Customer customer);

  Future<void> loginCustomer(String phone, String password);

  Future<void> registerCustomer(String phone, String password, String fullName,
      String email, Addresses addresses);

  Future<void> postReview(String requestId, String review, bool isLoseThings,
      bool isBreakThings, int rating, String token);

  Future<void> registerDeviceToken(String phone, String deviceToken);

  Future<PaymentResponse?> getPaymentLink(String requestId);
}

class DefaultRepository implements Repository {
  final remoteDataSource = RemoteDataSource();

  @override
  Future<List<Helper>?> loadCleanerData() async {
    return await remoteDataSource.loadCleanerData();
  }

  @override
  Future<List<Location>?> loadLocation() async {
    return await remoteDataSource.loadLocationData();
  }

  @override
  Future<List<Customer>?> loadCustomer(String token) async {
    return await remoteDataSource.loadCustomerData(token);
  }

  @override
  Future<Customer?> loadCustomerInfo(String phone, String token) async {
    return await remoteDataSource.loadCustomerInfo(phone, token);
  }

  @override
  Future<void> updateCustomer(Customer customer, String token) async {
    await remoteDataSource.updateCustomerInfo(customer, token);
  }

  @override
  Future<List<Services>?> loadServices() async {
    return await remoteDataSource.loadServicesData();
  }

  @override
  Future<List<Requests>?> loadRequest(String token) async {
    return await remoteDataSource.loadRequestData(token);
  }

  @override
  Future<List<Requests>?> loadCustomerRequest(
      String phone, String token) async {
    return await remoteDataSource.loadCustomerRequest(phone, token);
  }

  @override
  Future<List<RequestDetail>?> loadRequestDetail(String token) async {
    return await remoteDataSource.loadRequestDetailData(token);
  }

  @override
  Future<void> sendRequest(Requests request, String token) async {
    await remoteDataSource.sendRequests(request, token);
  }

  @override
  Future<List<TimeOff>?> loadTimeOff() async {
    return await remoteDataSource.loadTimeOffData();
  }

  @override
  Future<void> sendMessage(String phone) async {
    return await remoteDataSource.sendMessage(phone);
  }

  @override
  Future<List<Policy>?> loadPolicy() async {
    return await remoteDataSource.loadPolicy();
  }

  @override
  Future<List<FAQ>?> loadFAQ() async {
    return await remoteDataSource.loadFAQ();
  }

  @override
  Future<void> canceledRequest(String id, String token) async {
    return await remoteDataSource.cancelRequest(id, token);
  }

  @override
  Future<void> payRequest(String id, String token) async {
    return await remoteDataSource.paymentRequest(id, token);
  }

  @override
  Future<void> doneConfirmRequest(String id, String token) async {
    return await remoteDataSource.paymentRequest(id, token);
  }

  @override
  Future<Map<String, dynamic>?> calculateCost(String service, String startTime,
      String endTime, String startDate) async {
    return await remoteDataSource.calculateCost(
        service, startTime, endTime, startDate);
  }

  @override
  Future<List<RequestDetail>?> loadRequestDetailId(
      List<String> id, String token) async {
    return await remoteDataSource.loadRequestDetailId(id, token);
  }

  @override
  Future<void> sendCustomerRegisterRequest(Customer customer) async {
    return await remoteDataSource.sendCustomerRegisterRequest(customer);
  }

  @override
  Future<Authen?> loginCustomer(String phone, String password) {
    return remoteDataSource.loginCustomer(phone, password);
  }

  @override
  Future<Authen?> registerCustomer(String phone, String password,
      String fullName, String email, Addresses addresses) {
    return remoteDataSource.registerCustomer(
        phone, password, fullName, email, addresses);
  }

  @override
  Future<void> postReview(String requestId, String review, bool isLoseThings, bool isBreakThings, int rating, String token) async{
    return await remoteDataSource.postReview(requestId, review, isLoseThings, isBreakThings, rating, token);
  }

  @override
  Future<void> registerDeviceToken(String phone, String deviceToken) async{
    return await remoteDataSource.registerDeviceToken(phone, deviceToken);
  }

  @override
  Future<PaymentResponse?> getPaymentLink(String requestId) async{
    return await remoteDataSource.getPaymentLink(requestId);
  }
}
