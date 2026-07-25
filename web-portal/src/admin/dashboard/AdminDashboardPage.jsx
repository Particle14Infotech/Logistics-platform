import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import KpiCard from '../../shared/components/KpiCard.jsx';
import FleetTicker from '../../shared/components/FleetTicker.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import { ADMIN_NAV } from '../adminNav.js';
import { ADMIN_KPIS, FLEET_VEHICLES, RECENT_ORDERS } from './mockData.js';

// Master dashboard: KPIs, active deliveries, revenue, driver utilization (SRS 3.3.1)
export default function AdminDashboardPage() {
  const orderColumns = [
    { key: 'id', label: 'Order', render: (r) => <span className="font-mono text-xs">{r.id}</span> },
    { key: 'customer', label: 'Customer' },
    { key: 'route', label: 'Route', render: (r) => <span className="text-mist">{r.route}</span> },
    { key: 'vehicleType', label: 'Vehicle', render: (r) => <span className="font-mono text-xs capitalize">{r.vehicleType.replace('_', ' ')}</span> },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    { key: 'price', label: 'Amount', render: (r) => <span className="font-mono">{r.price}</span> },
  ];

  return (
    <ConsoleShell
      navItems={ADMIN_NAV}
      brandSuffix="ADMIN"
      footerLabel="Ops Admin"
      loginPath="/admin/login"
      dateLabel="25 JUL 2026"
    >
      <div>
        <span className="eyebrow">Operations — today</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Overview</h1>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {ADMIN_KPIS.map((kpi) => (
          <KpiCard key={kpi.label} {...kpi} />
        ))}
      </div>

      <FleetTicker vehicles={FLEET_VEHICLES} />

      <div>
        <div className="flex items-center justify-between mb-3">
          <span className="eyebrow">Recent orders</span>
          <a href="/admin/orders" className="text-xs text-signal hover:underline">View all →</a>
        </div>
        <DataTable columns={orderColumns} rows={RECENT_ORDERS} />
      </div>
    </ConsoleShell>
  );
}
