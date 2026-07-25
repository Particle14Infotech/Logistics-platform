// Mock data for wiring up the UI before the analytics/orders APIs are live.
// Replace with axiosClient calls to /admin/analytics and /admin/orders.

export const ADMIN_KPIS = [
  { label: 'Orders today', value: '1,284', trend: 8.2 },
  { label: 'Revenue today', value: '₹18.4L', trend: 5.1 },
  { label: 'Active drivers', value: '312', trend: -2.4 },
  { label: 'Delivery success', value: '96.4', unit: '%', trend: 0.6 },
];

export const FLEET_VEHICLES = [
  { plate: 'DL 01 AB 4521', route: 'Delhi → Gurugram', state: 'in_transit', eta: '12 min' },
  { plate: 'MH 04 CD 7789', route: 'Pune Depot', state: 'idle', eta: '—' },
  { plate: 'KA 03 EF 1290', route: 'Bengaluru → Hosur', state: 'loading', eta: '4 min' },
  { plate: 'TN 09 GH 3345', route: 'Chennai → Vellore', state: 'in_transit', eta: '38 min' },
  { plate: 'UP 32 IJ 8871', route: 'Noida → Agra', state: 'in_transit', eta: '1h 05m' },
  { plate: 'GJ 01 KL 5620', route: 'Ahmedabad Depot', state: 'delivered', eta: 'Done' },
  { plate: 'RJ 14 MN 2298', route: 'Jaipur → Kota', state: 'in_transit', eta: '52 min' },
  { plate: 'WB 06 OP 9034', route: 'Kolkata → Durgapur', state: 'idle', eta: '—' },
];

export const RECENT_ORDERS = [
  { id: 'ORD-88213', route: 'Delhi → Gurugram', vehicleType: 'mini_truck', status: 'in_transit', price: '₹1,240', customer: 'Rohan Textiles' },
  { id: 'ORD-88212', route: 'Pune → Mumbai', vehicleType: 'medium_truck', status: 'accepted', price: '₹6,850', customer: 'Vertex Pharma' },
  { id: 'ORD-88211', route: 'Bengaluru → Hosur', vehicleType: 'auto', status: 'delivered', price: '₹420', customer: 'Local Grocers Co.' },
  { id: 'ORD-88210', route: 'Chennai → Vellore', vehicleType: 'large_truck', status: 'in_transit', price: '₹12,300', customer: 'Anand Steel Works' },
  { id: 'ORD-88209', route: 'Noida → Agra', vehicleType: 'medium_truck', status: 'pending', price: '₹4,100', customer: 'Kavya Electronics' },
  { id: 'ORD-88208', route: 'Jaipur → Kota', vehicleType: 'mini_truck', status: 'cancelled', price: '₹2,050', customer: 'Desert Foods Pvt Ltd' },
];
