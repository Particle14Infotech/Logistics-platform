import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_model.dart';
import '../services/booking_service.dart';

class BookingDraft {
  final LocationModel? pickup;
  final LocationModel? drop;
  final String? vehicleType;
  final String goodsType;
  final double? weightKg;
  final bool isFragile;
  final bool insuranceOpted;
  final FareEstimate? estimate;

  const BookingDraft({
    this.pickup,
    this.drop,
    this.vehicleType,
    this.goodsType = '',
    this.weightKg,
    this.isFragile = false,
    this.insuranceOpted = false,
    this.estimate,
  });

  BookingDraft copyWith({
    LocationModel? pickup,
    LocationModel? drop,
    String? vehicleType,
    String? goodsType,
    double? weightKg,
    bool? isFragile,
    bool? insuranceOpted,
    FareEstimate? estimate,
  }) {
    return BookingDraft(
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      vehicleType: vehicleType ?? this.vehicleType,
      goodsType: goodsType ?? this.goodsType,
      weightKg: weightKg ?? this.weightKg,
      isFragile: isFragile ?? this.isFragile,
      insuranceOpted: insuranceOpted ?? this.insuranceOpted,
      estimate: estimate ?? this.estimate,
    );
  }
}

class BookingDraftNotifier extends StateNotifier<BookingDraft> {
  BookingDraftNotifier() : super(const BookingDraft());

  void setLocations({required LocationModel pickup, required LocationModel drop}) {
    state = state.copyWith(pickup: pickup, drop: drop);
  }

  void setVehicleType(String vehicleType) {
    state = state.copyWith(vehicleType: vehicleType);
  }

  void setLoadDetails({required String goodsType, double? weightKg, bool isFragile = false, bool insuranceOpted = false}) {
    state = state.copyWith(
      goodsType: goodsType,
      weightKg: weightKg,
      isFragile: isFragile,
      insuranceOpted: insuranceOpted,
    );
  }

  void setEstimate(FareEstimate estimate) {
    state = state.copyWith(estimate: estimate);
  }

  // Called after a booking is successfully created, so the next booking starts clean.
  void reset() {
    state = const BookingDraft();
  }
}

final bookingDraftProvider = StateNotifierProvider<BookingDraftNotifier, BookingDraft>(
  (ref) => BookingDraftNotifier(),
);

final bookingServiceProvider = Provider<BookingService>((ref) => BookingService());
