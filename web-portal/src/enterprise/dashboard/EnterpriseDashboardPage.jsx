import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import KpiCard from '../../shared/components/KpiCard.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';
import { ENTERPRISE_KPIS, TOP_DESTINATIONS, RECENT_INVOICES } from './mockData.js';

// Enterprise dashboard: monthly spend, active shipments, top destinations (SRS 4.3)
export default function EnterpriseDashboardPage() {
  const invoiceColumns = [
    { key: 'id', label: 'Invoice', render: (r) => <span className="font-mono text-xs">{r.id}</span> },
    { key: 'period', label: 'Billing period' },
    { key: 'amount', label: 'Amount', render: (r) => <span className="font-mono">{r.amount}</span> },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    {
      key: 'action',
      label: '',
      render: () => <button className="text-xs text-signal hover:underline">Download PDF</button>,
    },
  ];

  return (
    <ConsoleShell
      navItems={ENTERPRISE_NAV}
      brandSuffix="ENTERPRISE"
      footerLabel="Vertex Pharma"
      loginPath="/enterprise/login"
      dateLabel="25 JUL 2026"
    >
      <div className="flex items-center justify-between">
        <div>
          <span className="eyebrow">Vertex Pharma account</span>
          <h1 className="font-display text-2xl font-semibold mt-1">Overview</h1>
        </div>
        <a
          href="/enterprise/bulk-booking"
          className="bg-signal text-ink text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 transition-all"
        >
          + New bulk booking
        </a>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {ENTERPRISE_KPIS.map((kpi) => (
          <KpiCard key={kpi.label} {...kpi} />
        ))}
      </div>

      <div className="grid lg:grid-cols-5 gap-6">
        {/* Top destinations - simple bar list, no chart lib needed for this shape */}
        <div className="lg:col-span-2 bg-panel border border-line rounded-lg p-4">
          <span className="eyebrow">Top destinations this month</span>
          <div className="mt-4 space-y-3">
            {TOP_DESTINATIONS.map((d) => (
              <div key={d.city}>
                <div className="flex justify-between text-sm mb-1">
                  <span>{d.city}</span>
                  <span className="font-mono text-mist">{d.orders} orders</span>
                </div>
                <div className="h-1.5 bg-panel2 rounded-full overflow-hidden">
                  <div className="h-full bg-signal rounded-full" style={{ width: `${d.share * 2.6}%` }} />
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="lg:col-span-3">
          <div className="flex items-center justify-between mb-3">
            <span className="eyebrow">Recent invoices</span>
            <a href="/enterprise/invoices" className="text-xs text-signal hover:underline">View all →</a>
          </div>
          <DataTable columns={invoiceColumns} rows={RECENT_INVOICES} />
        </div>
      </div>
    </ConsoleShell>
  );
}
