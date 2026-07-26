import 'package:flutter/material.dart';

class VehicleTypeInfo {
  final String value;
  final String label;
  final String description;
  final IconData icon;

  const VehicleTypeInfo({required this.value, required this.label, required this.description, required this.icon});
}

const List<VehicleTypeInfo> kVehicleTypes = [
  VehicleTypeInfo(value: 'bike', label: 'Bike', description: 'Small parcels, documents', icon: Icons.two_wheeler),
  VehicleTypeInfo(value: 'auto', label: 'Auto', description: 'Up to 250 kg', icon: Icons.electric_rickshaw),
  VehicleTypeInfo(value: 'mini_truck', label: 'Mini Truck', description: 'Up to 750 kg', icon: Icons.local_shipping_outlined),
  VehicleTypeInfo(value: 'medium_truck', label: 'Medium Truck', description: 'Up to 2,500 kg', icon: Icons.local_shipping),
  VehicleTypeInfo(value: 'large_truck', label: 'Large Truck', description: 'Up to 10,000 kg', icon: Icons.fire_truck),
];
