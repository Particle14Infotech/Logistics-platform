import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Bar, BarChart, CartesianGrid, Cell, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import KpiCard from '../../shared/components/KpiCard.jsx';
import FleetTicker from '../../shared/components/FleetTicker.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';
import { FLEET_VEHICLES } from './mockData.js';

const tickStyle = { fill: '#64748B', fontSize: 11, fontFamily: 'Inter, sans-serif' };
const tooltipStyle = { borderRadius: 8, border: '1px solid #E2E8F0', fontSize: 12 };

// Status colors are the same ones StatusBadge uses elsewhere in the app -
// reused here as the fixed meaning of each order status, not as arbitrary
// series identity (the dataviz reserved-status-color rule cuts the other
// way: never repurpose a status color for an unrelated series).
const STATUS_BAR_COLOR = {
  pending: '#FAB219',
  accepted: '#2A78D6',
  picked_up: '#2A78D6',
  in_transit: '#2A78D6',
  delivered: '#0CA30C',
  cancelled: '#D03B3B',
};

// Orders and revenue are different units/scales, so they're two single-hue
// charts rather than one dual-axis chart - a dual y-axis chart is the #1
// chart-reading mistake (the two scales silently mislead on relative size).
function TrendChart({ title, data, dataKey, color, formatValue }) {
  return (
    <div className="bg-panel border border-line rounded-xl shadow-sm p-4">
      <span className="eyebrow">{title}</span>
      <div className="h-48 mt-3">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 4, right: 4, left: 4, bottom: 0 }}>
            <CartesianGrid vertical={false} stroke="#E2E8F0" />
            <XAxis dataKey="label" axisLine={false} tickLine={false} tick={tickStyle} />
            <Tooltip
              cursor={{ fill: '#F1F5F9' }}
              formatter={(value) => [formatValue ? formatValue(value) : value, title]}
              contentStyle={tooltipStyle}
            />
            <Bar dataKey={dataKey} fill={color} radius={[4, 4, 0, 0]} maxBarSize={28} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

// Live pipeline snapshot - how many shipments sit in each status right now.
function OrderStatusChart({ data }) {
  return (
    <div className="bg-panel border border-line rounded-xl shadow-sm p-4">
      <span className="eyebrow">Orders by status — live</span>
      <div className="h-56 mt-3">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} layout="vertical" margin={{ top: 4, right: 16, left: 4, bottom: 0 }}>
            <CartesianGrid horizontal={false} stroke="#E2E8F0" />
            <XAxis type="number" hide />
            <YAxis dataKey="label" type="category" axisLine={false} tickLine={false} width={100} tick={{ fill: '#0F172A', fontSize: 12 }} />
            <Tooltip cursor={{ fill: '#F1F5F9' }} formatter={(value) => [value, 'Orders']} contentStyle={tooltipStyle} />
            <Bar dataKey="count" radius={[0, 4, 4, 0]} maxBarSize={18}>
              {data.map((entry) => (
                <Cell key={entry.status} fill={STATUS_BAR_COLOR[entry.status] ?? '#64748B'} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

// Fleet composition - how many approved drivers/vehicles of each type.
function FleetCompositionChart({ data }) {
  return (
    <div className="bg-panel border border-line rounded-xl shadow-sm p-4">
      <span className="eyebrow">Fleet by vehicle type</span>
      <div className="h-56 mt-3">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 4, right: 4, left: 4, bottom: 0 }}>
            <CartesianGrid vertical={false} stroke="#E2E8F0" />
            <XAxis dataKey="label" axisLine={false} tickLine={false} tick={tickStyle} interval={0} angle={-20} textAnchor="end" height={40} />
            <Tooltip cursor={{ fill: '#F1F5F9' }} formatter={(value) => [value, 'Drivers']} contentStyle={tooltipStyle} />
            <Bar dataKey="count" fill="#1BAF7A" radius={[4, 4, 0, 0]} maxBarSize={36} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

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
    { key: 'vehicleType', label: 'Vehicle', render: (r) => <span className="text-xs capitalize">{r.vehicleType.replace('_', ' ')}</span> },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    { key: 'price', label: 'Amount', render: (r) => <span className="font-mono">₹{r.price.toLocaleString('en-IN')}</span> },
  ];

  const todayKpis = analytics
    ? [
        { label: 'Orders today', value: analytics.ordersToday.toLocaleString('en-IN') },
        { label: 'Revenue today', value: `₹${(analytics.revenueToday / 100000).toFixed(1)}L` },
        { label: 'Delivery success', value: analytics.deliverySuccessRate, unit: '%' },
      ]
    : [];

  const liveKpis = analytics
    ? [
        { label: 'Active orders', value: analytics.activeOrders.toLocaleString('en-IN') },
        { label: 'Active trips', value: analytics.activeTrips.toLocaleString('en-IN') },
        { label: 'Drivers online', value: analytics.activeDrivers.toLocaleString('en-IN') },
        { label: 'Total drivers', value: analytics.totalDrivers.toLocaleString('en-IN') },
      ]
    : [];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Operations overview</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Fleet & shipments</h1>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[0, 1, 2, 3].map((i) => (
            <div key={i} className="bg-panel border border-line rounded-xl shadow-sm p-4 h-24 animate-pulse" />
          ))}
        </div>
      ) : (
        <>
          <div>
            <span className="eyebrow">Right now</span>
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mt-2">
              {liveKpis.map((kpi) => (
                <KpiCard key={kpi.label} {...kpi} />
              ))}
            </div>
          </div>
          <div>
            <span className="eyebrow">Today</span>
            <div className="grid grid-cols-3 gap-4 mt-2">
              {todayKpis.map((kpi) => (
                <KpiCard key={kpi.label} {...kpi} />
              ))}
            </div>
          </div>
        </>
      )}

      {!loading && analytics?.ordersByStatus && analytics?.fleetByVehicleType && (
        <div className="grid md:grid-cols-2 gap-4">
          <OrderStatusChart data={analytics.ordersByStatus} />
          <FleetCompositionChart data={analytics.fleetByVehicleType} />
        </div>
      )}

      {!loading && analytics?.last7Days && (
        <div className="grid md:grid-cols-2 gap-4">
          <TrendChart title="Orders — last 7 days" data={analytics.last7Days} dataKey="orders" color="#2A78D6" />
          <TrendChart
            title="Revenue — last 7 days"
            data={analytics.last7Days}
            dataKey="revenue"
            color="#EB6834"
            formatValue={(v) => `₹${v.toLocaleString('en-IN')}`}
          />
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
