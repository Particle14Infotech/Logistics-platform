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

  Future<TripModel> advanceTripStatus(String id, String status, {String? note, String? otp}) async {
    final response = await _dio.put('/driver/orders/$id/status', data: {
      'status': status,
      if (note != null) 'note': note,
      if (otp != null) 'otp': otp,
    });
    return TripModel.fromJson(response.data['data']['order'] as Map<String, dynamic>);
  }

  Future<TripModel> confirmDelivery(String bookingId, String otp) async {
    final response = await _dio.post('/driver/pod/$bookingId', data: {'otp': otp});
    return TripModel.fromJson(response.data['data']['order'] as Map<String, dynamic>);
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
}
