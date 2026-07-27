import 'package:flutter/material.dart';

class VehicleTypeInfo {
  final String value;
  final String label;
  final IconData icon;

  const VehicleTypeInfo({required this.value, required this.label, required this.icon});
}

const List<VehicleTypeInfo> kVehicleTypes = [
  VehicleTypeInfo(value: 'bike', label: 'Bike', icon: Icons.two_wheeler),
  VehicleTypeInfo(value: 'auto', label: 'Auto', icon: Icons.electric_rickshaw),
  VehicleTypeInfo(value: 'mini_truck', label: 'Mini Truck', icon: Icons.local_shipping_outlined),
  VehicleTypeInfo(value: 'medium_truck', label: 'Medium Truck', icon: Icons.local_shipping),
  VehicleTypeInfo(value: 'large_truck', label: 'Large Truck', icon: Icons.fire_truck),
];

IconData vehicleIcon(String vehicleType) => kVehicleTypes
    .firstWhere((v) => v.value == vehicleType, orElse: () => kVehicleTypes[2])
    .icon;
