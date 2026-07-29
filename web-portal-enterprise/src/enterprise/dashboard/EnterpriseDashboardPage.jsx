import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import KpiCard from '../../shared/components/KpiCard.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { downloadFile } from '../../shared/utils/downloadFile.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

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
        <a href="/bulk-booking" className="bg-signal text-ink text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 transition-all">
          + New bulk booking
        </a>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="grid grid-cols-3 gap-4">
          {[0, 1, 2].map((i) => <div key={i} className="bg-panel border border-line rounded-lg p-4 h-24 animate-pulse" />)}
        </div>
      ) : (
        <div className="grid grid-cols-3 gap-4">
          {kpis.map((kpi) => <KpiCard key={kpi.label} {...kpi} mono={false} />)}
        </div>
      )}

      <div className="grid lg:grid-cols-5 gap-6">
        <div className="lg:col-span-2 bg-panel border border-line rounded-lg p-4">
          <span className="eyebrow">Top destinations</span>
          <div className="mt-4 space-y-3">
            {(summary?.topDestinations ?? []).map((d) => (
              <div key={d.city}>
                <div className="flex justify-between text-sm mb-1">
                  <span>{d.city}</span>
                  <span className="font-mono text-mist">{d.orders} orders</span>
                </div>
                <div className="h-1.5 bg-panel2 rounded-full overflow-hidden">
                  <div className="h-full bg-signal rounded-full" style={{ width: `${d.share}%` }} />
                </div>
              </div>
            ))}
            {(!summary?.topDestinations || summary.topDestinations.length === 0) && (
              <p className="text-xs text-mist">No shipment history yet.</p>
            )}
          </div>
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
