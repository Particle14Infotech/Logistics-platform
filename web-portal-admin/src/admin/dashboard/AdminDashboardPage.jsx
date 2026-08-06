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

const tickStyle = { fill: '#64748B', fontSize: 11, fontFamily: 'Inter, sans-serif' };
const tooltipStyle = { borderRadius: 8, border: '1px solid #E2E8F0', fontSize: 12 };

// Status colors are the same ones StatusBadge uses elsewhere in the app -
// reused here as the fixed meaning of each order status, not as arbitrary
// series identity (the dataviz reserved-status-color rule cuts the other
// way: never repurpose a status color for an unrelated series).
const STATUS_BAR_COLOR = {
  pending: '#FAB219',
  accepted: '#673AB7',
  picked_up: '#673AB7',
  in_transit: '#673AB7',
  awaiting_payment: '#FAB219',
  delivered: '#0CA30C',
  cancelled: '#D03B3B',
};

const todayIso = () => new Date().toISOString().slice(0, 10);

// Backend's dateTo filter is an inclusive $lte against midnight of that
// date string, not end-of-day - so a same-day range (dateFrom=X&dateTo=X)
// would match almost nothing, since virtually every order that day was
// created after X's own midnight. The next calendar day as the upper bound
// is what actually captures "all of day X".
const nextDayIso = (dateStr) => {
  const d = new Date(dateStr);
  d.setDate(d.getDate() + 1);
  return d.toISOString().slice(0, 10);
};

// Orders and revenue are different units/scales, so they're two single-hue
// charts rather than one dual-axis chart - a dual y-axis chart is the #1
// chart-reading mistake (the two scales silently mislead on relative size).
// onBarClick, when given, makes each day's bar a real link to that day's
// orders instead of pure display.
function TrendChart({ title, data, dataKey, color, formatValue, onBarClick }) {
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
            <Bar
              dataKey={dataKey}
              fill={color}
              radius={[4, 4, 0, 0]}
              maxBarSize={28}
              cursor={onBarClick ? 'pointer' : undefined}
              onClick={onBarClick ? (entry) => onBarClick(entry) : undefined}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

// Status breakdown chart - shared by the "live right now" and "today"
// variants below, just fed different data/title. onBarClick navigates to
// the matching filtered Orders list instead of leaving the chart inert.
function StatusBreakdownChart({ title, data, onBarClick }) {
  return (
    <div className="bg-panel border border-line rounded-xl shadow-sm p-4">
      <span className="eyebrow">{title}</span>
      <div className="h-56 mt-3">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} layout="vertical" margin={{ top: 4, right: 16, left: 4, bottom: 0 }}>
            <CartesianGrid horizontal={false} stroke="#E2E8F0" />
            <XAxis type="number" hide />
            <YAxis dataKey="label" type="category" axisLine={false} tickLine={false} width={100} tick={{ fill: '#0F172A', fontSize: 12 }} />
            <Tooltip cursor={{ fill: '#F1F5F9' }} formatter={(value) => [value, 'Orders']} contentStyle={tooltipStyle} />
            <Bar
              dataKey="count"
              radius={[0, 4, 4, 0]}
              maxBarSize={18}
              cursor={onBarClick ? 'pointer' : undefined}
              onClick={onBarClick ? (entry) => onBarClick(entry) : undefined}
            >
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
// onBarClick navigates to Drivers filtered to that vehicle type.
function FleetCompositionChart({ data, onBarClick }) {
  return (
    <div className="bg-panel border border-line rounded-xl shadow-sm p-4">
      <span className="eyebrow">Fleet by vehicle type</span>
      <div className="h-56 mt-3">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 4, right: 4, left: 4, bottom: 0 }}>
            <CartesianGrid vertical={false} stroke="#E2E8F0" />
            <XAxis dataKey="label" axisLine={false} tickLine={false} tick={tickStyle} interval={0} angle={-20} textAnchor="end" height={40} />
            <Tooltip cursor={{ fill: '#F1F5F9' }} formatter={(value) => [value, 'Drivers']} contentStyle={tooltipStyle} />
            <Bar
              dataKey="count"
              fill="#1BAF7A"
              radius={[4, 4, 0, 0]}
              maxBarSize={36}
              cursor={onBarClick ? 'pointer' : undefined}
              onClick={onBarClick ? (entry) => onBarClick(entry) : undefined}
            />
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
  const [fleetVehicles, setFleetVehicles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    // silent: true skips the loading spinner / error banner on background
    // refreshes, so the periodic poll below doesn't flash the whole
    // dashboard on every tick - only the very first load shows those.
    async function load({ silent = false } = {}) {
      if (!silent) setLoading(true);
      if (!silent) setError('');
      try {
        const [analyticsRes, ordersRes, fleetRes] = await Promise.all([
          axiosClient.get('/admin/analytics'),
          axiosClient.get('/admin/orders', { params: { limit: 6 } }),
          axiosClient.get('/admin/fleet-live'),
        ]);
        if (cancelled) return;
        setAnalytics(analyticsRes.data.data);
        setRecentOrders(ordersRes.data.data.orders);
        setFleetVehicles(fleetRes.data.data.vehicles);
      } catch (err) {
        console.error('[AdminDashboardPage] failed to load dashboard data', err);
        if (!cancelled && !silent) setError(err.response?.data?.message || 'Could not load dashboard data. Is the backend running?');
      } finally {
        if (!cancelled && !silent) setLoading(false);
      }
    }
    load();
    // Revenue/active-orders/active-trips previously only ever loaded once on
    // mount - an admin had to manually reload the page to see anything
    // change. Polling keeps it live without needing a websocket wired in.
    const interval = setInterval(() => load({ silent: true }), 20000);
    return () => {
      cancelled = true;
      clearInterval(interval);
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

  // Every KPI/chart click below lands on a real, pre-filtered destination -
  // these used to be pure display with nothing wired to onClick at all.
  const liveKpis = analytics
    ? [
        // Status lists here have to match analytics()'s own $in filters
        // exactly (see admin.controller.js) - these used to link to just
        // one status out of the set being counted (or, for Active orders,
        // no filter at all), so the count shown and what you'd actually
        // see after clicking disagreed.
        { label: 'Active orders', value: analytics.activeOrders.toLocaleString('en-IN'), onClick: () => navigate('/orders?status=pending,accepted,picked_up,in_transit,awaiting_payment') },
        { label: 'Active trips', value: analytics.activeTrips.toLocaleString('en-IN'), onClick: () => navigate('/orders?status=accepted,picked_up,in_transit,awaiting_payment') },
        { label: 'Drivers online', value: analytics.activeDrivers.toLocaleString('en-IN'), onClick: () => navigate('/drivers?isAvailable=true') },
        { label: 'Total drivers', value: analytics.totalDrivers.toLocaleString('en-IN'), onClick: () => navigate('/drivers') },
      ]
    : [];

  const todayKpis = analytics
    ? [
        { label: 'Orders today', value: analytics.ordersToday.toLocaleString('en-IN'), onClick: () => navigate(`/orders?dateFrom=${todayIso()}`) },
        { label: 'Revenue today', value: `₹${(analytics.revenueToday / 100000).toFixed(1)}L`, onClick: () => navigate('/payments') },
        { label: 'Delivery success', value: analytics.deliverySuccessRate, unit: '%', onClick: () => navigate(`/orders?status=delivered&dateFrom=${todayIso()}`) },
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
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-2">
              {todayKpis.map((kpi) => (
                <KpiCard key={kpi.label} {...kpi} />
              ))}
            </div>
          </div>
        </>
      )}

      {!loading && analytics?.ordersByStatus && analytics?.todayOrdersByStatus && (
        <div className="grid md:grid-cols-2 gap-4">
          <StatusBreakdownChart
            title="Orders by status — live"
            data={analytics.ordersByStatus}
            onBarClick={(entry) => navigate(`/orders?status=${entry.status}`)}
          />
          <StatusBreakdownChart
            title="Today's orders by status"
            data={analytics.todayOrdersByStatus}
            onBarClick={(entry) => navigate(`/orders?status=${entry.status}&dateFrom=${todayIso()}`)}
          />
        </div>
      )}

      {!loading && analytics?.fleetByVehicleType && (
        <FleetCompositionChart
          data={analytics.fleetByVehicleType}
          onBarClick={(entry) => navigate(`/drivers?vehicleType=${entry.type}`)}
        />
      )}

      {!loading && analytics?.last7Days && (
        <div className="grid md:grid-cols-2 gap-4">
          <TrendChart
            title="Orders — last 7 days"
            data={analytics.last7Days}
            dataKey="orders"
            color="#673AB7"
            onBarClick={(entry) => navigate(`/orders?dateFrom=${entry.date}&dateTo=${nextDayIso(entry.date)}`)}
          />
          <TrendChart
            title="Revenue — last 7 days"
            data={analytics.last7Days}
            dataKey="revenue"
            color="#EB6834"
            formatValue={(v) => `₹${v.toLocaleString('en-IN')}`}
            onBarClick={(entry) => navigate(`/payments`)}
          />
        </div>
      )}

      <FleetTicker vehicles={fleetVehicles} />

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
