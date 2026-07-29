import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import KpiCard from '../../shared/components/KpiCard.jsx';
import FleetTicker from '../../shared/components/FleetTicker.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';
import { FLEET_VEHICLES } from './mockData.js';

// Master dashboard: KPIs, active deliveries, revenue, driver utilization (SRS 3.3.1)
// KPIs + recent orders are live from the backend. The fleet ticker is still
// mock data - it needs the Socket.IO tracking feed (sockets/tracking.socket.js)
// wired into the frontend, which is a separate piece of work from the REST
// Orders module built here.
export default function AdminDashboardPage() {
  const navigate = useNavigate();
  const [analytics, setAnalytics] = useState(null);
  const [recentOrders, setRecentOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    async function load() {
      setLoading(true);
      setError('');
      try {
        const [analyticsRes, ordersRes] = await Promise.all([
          axiosClient.get('/admin/analytics'),
          axiosClient.get('/admin/orders', { params: { limit: 6 } }),
        ]);
        if (cancelled) return;
        setAnalytics(analyticsRes.data.data);
        setRecentOrders(ordersRes.data.data.orders);
      } catch (err) {
        console.error('[AdminDashboardPage] failed to load dashboard data', err);
        if (!cancelled) setError(err.response?.data?.message || 'Could not load dashboard data. Is the backend running?');
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const orderColumns = [
    { key: 'id', label: 'Order', render: (r) => <span className="font-mono text-xs">{r._id.slice(-8).toUpperCase()}</span> },
    { key: 'customer', label: 'Customer', render: (r) => r.customerId?.name ?? '—' },
    {
      key: 'route',
      label: 'Route',
      render: (r) => <span className="text-mist">{r.pickupLocation?.address ?? '—'} → {r.dropLocation?.address ?? '—'}</span>,
    },
    { key: 'vehicleType', label: 'Vehicle', render: (r) => <span className="font-mono text-xs capitalize">{r.vehicleType.replace('_', ' ')}</span> },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    { key: 'price', label: 'Amount', render: (r) => <span className="font-mono">₹{r.price.toLocaleString('en-IN')}</span> },
  ];

  const kpis = analytics
    ? [
        { label: 'Orders today', value: analytics.ordersToday.toLocaleString('en-IN') },
        { label: 'Revenue today', value: `₹${(analytics.revenueToday / 100000).toFixed(1)}L` },
        { label: 'Active drivers', value: analytics.activeDrivers.toLocaleString('en-IN') },
        { label: 'Delivery success', value: analytics.deliverySuccessRate, unit: '%' },
      ]
    : [];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Operations — today</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Overview</h1>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[0, 1, 2, 3].map((i) => (
            <div key={i} className="bg-panel border border-line rounded-lg p-4 h-24 animate-pulse" />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {kpis.map((kpi) => (
            <KpiCard key={kpi.label} {...kpi} />
          ))}
        </div>
      )}

      <FleetTicker vehicles={FLEET_VEHICLES} />

      <div>
        <div className="flex items-center justify-between mb-3">
          <span className="eyebrow">Recent orders</span>
          <a href="/orders" className="text-xs text-signal hover:underline">View all →</a>
        </div>
        {loading ? (
          <div className="text-center py-16 text-mist text-sm border border-line rounded-lg">Loading orders…</div>
        ) : (
          <DataTable columns={orderColumns} rows={recentOrders} keyField="_id" onRowClick={(order) => navigate(`/orders/${order._id}`)} />
        )}
      </div>
    </ConsoleShell>
  );
}
