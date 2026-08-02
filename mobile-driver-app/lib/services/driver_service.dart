import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/driver_profile_model.dart';
import '../models/trip_model.dart';

class EarningsSummary {
  final num totalEarnings;
  final int totalTrips;
  final num weekTotal;
  final int weekTrips;
  final num monthTotal;
  final int monthTrips;

  EarningsSummary({
    required this.totalEarnings,
    required this.totalTrips,
    required this.weekTotal,
    required this.weekTrips,
    required this.monthTotal,
    required this.monthTrips,
  });
}

class DriverService {
  final _dio = DioClient.instance;

  Future<DriverProfile?> getProfile() async {
    final response = await _dio.get('/driver/profile');
    final data = response.data['data']['driver'];
    if (data == null) return null;
    return DriverProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<DriverProfile> createProfile({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
    String? enterpriseInviteCode,
  }) async {
    final response = await _dio.post('/driver/profile', data: {
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      if (enterpriseInviteCode != null && enterpriseInviteCode.isNotEmpty) 'enterpriseInviteCode': enterpriseInviteCode,
    });
    return DriverProfile.fromJson(response.data['data']['driver'] as Map<String, dynamic>);
  }

  Future<void> setAvailability(bool isAvailable) async {
    await _dio.put('/driver/status', data: {'isAvailable': isAvailable});
  }

  // Face-verification KYC step, called right after createProfile during
  // vehicle setup. Uploads to local disk on the backend (see driver.
  // controller.js) - the resulting URL becomes Driver.documents.photoUrl,
  // which the Admin > Drivers KYC review grid already displays.
  // Generic KYC document upload - covers all 8 document types (see
  // core/constants/document_types.dart for the list). documentType matches
  // the backend's DOCUMENT_TYPE_MAP key ('photo', 'license', 'rc', etc.).
  Future<String> uploadDocument(String documentType, File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path, filename: '$documentType.jpg'),
    });
    final response = await _dio.post('/driver/documents/$documentType', data: formData);
    return response.data['data']['url'] as String;
  }

  Future<List<TripModel>> availableOrders() async {
    final response = await _dio.get('/driver/available-orders');
    final orders = response.data['data']['orders'] as List<dynamic>;
    return orders.map((o) => TripModel.fromJson(o as Map<String, dynamic>)).toList();
  }

  Future<void> acceptOrder(String bookingId) async {
    await _dio.post('/driver/accept/$bookingId');
  }

  Future<void> rejectOrder(String bookingId) async {
    await _dio.post('/driver/reject/$bookingId');
  }

  Future<List<TripModel>> listMyTrips({String? status}) async {
    final response = await _dio.get('/driver/orders', queryParameters: {if (status != null) 'status': status});
    final orders = response.data['data']['orders'] as List<dynamic>;
    return orders.map((o) => TripModel.fromJson(o as Map<String, dynamic>)).toList();
  }

  Future<TripModel> getTrip(String id) async {
    final response = await _dio.get('/driver/orders/$id');
    return TripModel.fromJson(response.data['data']['order'] as Map<String, dynamic>);
  }

  Future<TripModel> advanceTripStatus(String id, String status, {String? pickupCode, String? otp, bool manualConfirm = false}) async {
    final response = await _dio.put('/driver/orders/$id/status', data: {
      'status': status,
      if (pickupCode != null) 'pickupCode': pickupCode,
      if (otp != null) 'otp': otp,
      if (manualConfirm) 'manualConfirm': true,
    });
    return TripModel.fromJson(response.data['data']['order'] as Map<String, dynamic>);
  }

  Future<TripModel> confirmDelivery(String bookingId, String otp, {bool cashCollected = false}) async {
    final response = await _dio.post('/driver/pod/$bookingId', data: {'otp': otp, 'cashCollected': cashCollected});
    return TripModel.fromJson(response.data['data']['order'] as Map<String, dynamic>);
  }

  // Raw PDF bytes - caller saves to a temp file and shares/opens it, since
  // there's no browser to hand a download to on mobile. Same shared backend
  // endpoint the customer app uses (GET /booking/:id/invoice), reachable by
  // the driver only once they're the order's assigned driver.
  Future<List<int>> downloadInvoice(String bookingId) async {
    final response = await _dio.get<List<int>>(
      '/booking/$bookingId/invoice',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }

  // Only ewayBillNo is exposed to drivers - the rest of the waybill's
  // compliance fields are ops-staff territory (see backend/src/controllers/
  // booking.controller.js's updateWaybillDetails), this is just the one
  // field realistically theirs to add once they have the physical
  // paperwork at pickup.
  Future<void> addEwayBillNumber(String bookingId, String ewayBillNo) async {
    await _dio.put('/booking/$bookingId/waybill-details', data: {'ewayBillNo': ewayBillNo});
  }

  Future<EarningsSummary> getEarnings() async {
    final response = await _dio.get('/driver/earnings');
    final data = response.data['data'];
    return EarningsSummary(
      totalEarnings: data['totalEarnings'] as num,
      totalTrips: data['totalTrips'] as int,
      weekTotal: data['thisWeek']['total'] as num,
      weekTrips: data['thisWeek']['trips'] as int,
      monthTotal: data['thisMonth']['total'] as num,
      monthTrips: data['thisMonth']['trips'] as int,
    );
  }

  Future<WalletSummary> getWallet() async {
    final response = await _dio.get('/driver/wallet');
    final data = response.data['data'];
    return WalletSummary(
      balance: data['balance'] as num,
      transactions: (data['transactions'] as List)
          .map((t) => WalletTransaction.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<DriverProfile> updateBankDetails({
    required String accountNumber,
    required String ifsc,
    required String accountHolderName,
  }) async {
    final response = await _dio.put('/driver/bank-details', data: {
      'accountNumber': accountNumber,
      'ifsc': ifsc,
      'accountHolderName': accountHolderName,
    });
    return DriverProfile.fromJson(response.data['data']['driver'] as Map<String, dynamic>);
  }

  Future<DriverProfile> updateVehicle({
    required String vehicleType,
    required String vehicleNumber,
  }) async {
    final response = await _dio.put('/driver/vehicle', data: {
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
    });
    return DriverProfile.fromJson(response.data['data']['driver'] as Map<String, dynamic>);
  }
}

class WalletSummary {
  final num balance;
  final List<WalletTransaction> transactions;
  WalletSummary({required this.balance, required this.transactions});
}

class WalletTransaction {
  final String type;
  final num amount;
  final num balanceAfter;
  final String? note;
  final DateTime createdAt;

  WalletTransaction({
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.note,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      type: json['type'] as String,
      amount: json['amount'] as num,
      balanceAfter: json['balanceAfter'] as num,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
