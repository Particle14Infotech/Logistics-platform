import 'package:flutter/material.dart';

class VehicleTypeInfo {
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final int maxWeightKg;

  const VehicleTypeInfo({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.maxWeightKg,
  });
}

// Keep in sync with backend/src/config/vehicleCapacity.js - that's the
// server-side source of truth this only mirrors for instant client-side
// feedback before the booking/estimate API call.
const List<VehicleTypeInfo> kVehicleTypes = [
  VehicleTypeInfo(value: 'bike', label: 'Bike', description: 'Small parcels, documents', icon: Icons.two_wheeler, maxWeightKg: 20),
  VehicleTypeInfo(value: 'auto', label: 'Auto', description: 'Up to 250 kg', icon: Icons.electric_rickshaw, maxWeightKg: 250),
  VehicleTypeInfo(value: 'mini_truck', label: 'Mini Truck', description: 'Up to 750 kg', icon: Icons.local_shipping_outlined, maxWeightKg: 750),
  VehicleTypeInfo(value: 'medium_truck', label: 'Medium Truck', description: 'Up to 2,500 kg', icon: Icons.local_shipping, maxWeightKg: 2500),
  VehicleTypeInfo(value: 'large_truck', label: 'Large Truck', description: 'Up to 10,000 kg', icon: Icons.fire_truck, maxWeightKg: 10000),
];
