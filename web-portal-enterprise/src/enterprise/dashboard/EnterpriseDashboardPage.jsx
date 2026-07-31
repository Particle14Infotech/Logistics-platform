import { useEffect, useState } from 'react';
import { Bar, BarChart, CartesianGrid, Cell, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import KpiCard from '../../shared/components/KpiCard.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { downloadFile } from '../../shared/utils/downloadFile.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

const tooltipStyle = { borderRadius: 8, border: '1px solid #E2E8F0', fontSize: 12 };
const axisTick = { fill: '#64748B', fontSize: 11, fontFamily: 'Inter, sans-serif' };

// Same status-color convention as StatusBadge/admin console - reused as the
// fixed meaning of each shipment status, not as arbitrary series identity.
const STATUS_BAR_COLOR = {
  pending: '#FAB219',
  accepted: '#2A78D6',
  picked_up: '#2A78D6',
  in_transit: '#2A78D6',
  delivered: '#0CA30C',
  cancelled: '#D03B3B',
};

// Enterprise dashboard: monthly spend, active shipments, top destinations (SRS 4.3)
export default function EnterpriseDashboardPage() {
  const [summary, setSummary] = useState(null);
  const [recentInvoices, setRecentInvoices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    async function load() {
      setLoading(true);
      setError('');
      try {
        const [dashRes, invoicesRes] = await Promise.all([
          axiosClient.get('/enterprise/dashboard'),
          axiosClient.get('/enterprise/invoices'),
        ]);
        if (cancelled) return;
        setSummary(dashRes.data.data);
        setRecentInvoices(invoicesRes.data.data.invoices.slice(0, 4));
      } catch (err) {
        console.error('[EnterpriseDashboardPage] failed to load dashboard', err);
        if (!cancelled) setError(err.response?.data?.message || 'Could not load dashboard data.');
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    load();
    return () => { cancelled = true; };
  }, []);

  const invoiceColumns = [
    { key: 'id', label: 'Invoice', render: (r) => <span className="font-mono text-xs">INV-{r._id.slice(-8).toUpperCase()}</span> },
    { key: 'period', label: 'Billing period', render: (r) => `${new Date(r.periodStart).toLocaleDateString('en-IN', { month: 'short', year: 'numeric' })}` },
    { key: 'amount', label: 'Amount', render: (r) => <span className="font-mono">₹{r.totalAmount.toLocaleString('en-IN')}</span> },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    {
      key: 'action',
      label: '',
      render: (r) => (
        <button
          onClick={() => downloadFile(`/invoices/${r._id}/pdf`, `invoice-${r._id.slice(-8)}.pdf`)}
          className="text-xs text-signal hover:underline"
        >
          Download PDF
        </button>
      ),
    },
  ];

  const kpis = summary
    ? [
        { label: 'Monthly spend', value: `₹${(summary.monthlySpend / 100000).toFixed(2)}L` },
        { label: 'Active shipments', value: summary.activeShipments },
        { label: 'Pending invoices', value: summary.pendingInvoices },
      ]
    : [];

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <div className="flex items-center justify-between">
        <div>
          <span className="eyebrow">{summary?.companyName ?? 'Enterprise'} account</span>
          <h1 className="font-display text-2xl font-semibold mt-1">Overview</h1>
        </div>
        <a href="/bulk-booking" className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 transition-all">
          + New bulk booking
        </a>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="grid grid-cols-3 gap-4">
          {[0, 1, 2].map((i) => <div key={i} className="bg-panel border border-line rounded-xl shadow-sm p-4 h-24 animate-pulse" />)}
        </div>
      ) : (
        <div className="grid grid-cols-3 gap-4">
          {kpis.map((kpi) => <KpiCard key={kpi.label} {...kpi} mono={false} />)}
        </div>
      )}

      {!loading && (summary?.spendTrend || summary?.shipmentsByStatus) && (
        <div className="grid md:grid-cols-2 gap-4">
          {summary?.spendTrend && (
            <div className="bg-panel border border-line rounded-xl shadow-sm p-4">
              <span className="eyebrow">Monthly spend — last 6 months</span>
              <div className="h-56 mt-3">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={summary.spendTrend} margin={{ top: 4, right: 12, left: 4, bottom: 0 }}>
                    <CartesianGrid vertical={false} stroke="#E2E8F0" />
                    <XAxis dataKey="label" axisLine={false} tickLine={false} tick={axisTick} />
                    <YAxis axisLine={false} tickLine={false} tick={axisTick} width={40} tickFormatter={(v) => `${(v / 1000).toFixed(0)}k`} />
                    <Tooltip
                      cursor={{ stroke: '#E2E8F0' }}
                      formatter={(value) => [`₹${value.toLocaleString('en-IN')}`, 'Spend']}
                      contentStyle={tooltipStyle}
                    />
                    <Line type="monotone" dataKey="spend" stroke="#2A78D6" strokeWidth={2} dot={{ r: 4, fill: '#2A78D6' }} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {summary?.shipmentsByStatus && (
            <div className="bg-panel border border-line rounded-xl shadow-sm p-4">
              <span className="eyebrow">Shipments by status — live</span>
              <div className="h-56 mt-3">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={summary.shipmentsByStatus} layout="vertical" margin={{ top: 4, right: 16, left: 4, bottom: 0 }}>
                    <CartesianGrid horizontal={false} stroke="#E2E8F0" />
                    <XAxis type="number" hide />
                    <YAxis
                      dataKey="label"
                      type="category"
                      axisLine={false}
                      tickLine={false}
                      width={110}
                      tick={{ fill: '#0F172A', fontSize: 12 }}
                    />
                    <Tooltip cursor={{ fill: '#F1F5F9' }} formatter={(value) => [value, 'Shipments']} contentStyle={tooltipStyle} />
                    <Bar dataKey="count" radius={[0, 4, 4, 0]} maxBarSize={18}>
                      {summary.shipmentsByStatus.map((entry) => (
                        <Cell key={entry.status} fill={STATUS_BAR_COLOR[entry.status] ?? '#64748B'} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}
        </div>
      )}

      <div className="grid lg:grid-cols-5 gap-6">
        <div className="lg:col-span-2 bg-panel border border-line rounded-xl shadow-sm p-4">
          <span className="eyebrow">Top destinations</span>
          {(summary?.topDestinations ?? []).length === 0 ? (
            <p className="text-xs text-mist mt-4">No shipment history yet.</p>
          ) : (
            <div className="h-56 mt-3">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  data={summary.topDestinations}
                  layout="vertical"
                  margin={{ top: 4, right: 12, left: 4, bottom: 0 }}
                >
                  <CartesianGrid horizontal={false} stroke="#E2E8F0" />
                  <XAxis type="number" hide />
                  <YAxis
                    dataKey="city"
                    type="category"
                    axisLine={false}
                    tickLine={false}
                    width={90}
                    tick={{ fill: '#0F172A', fontSize: 12 }}
                  />
                  <Tooltip cursor={{ fill: '#F1F5F9' }} formatter={(value) => [`${value} orders`, '']} contentStyle={tooltipStyle} />
                  <Bar dataKey="orders" fill="#2A78D6" radius={[0, 4, 4, 0]} maxBarSize={18} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        <div className="lg:col-span-3">
          <div className="flex items-center justify-between mb-3">
            <span className="eyebrow">Recent invoices</span>
            <a href="/invoices" className="text-xs text-signal hover:underline">View all →</a>
          </div>
          <DataTable columns={invoiceColumns} rows={recentInvoices} keyField="_id" />
        </div>
      </div>
    </ConsoleShell>
  );
}
