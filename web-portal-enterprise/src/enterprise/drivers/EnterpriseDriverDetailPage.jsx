import { useEffect, useState, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { downloadFile } from '../../shared/utils/downloadFile.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

const WALLET_TYPE_LABELS = {
  trip_earning: 'Trip fare',
  cancellation_compensation: 'Cancellation compensation',
  payout: 'Payout',
  adjustment: 'Adjustment',
};

// Everything about one of this enterprise's own fleet drivers - profile,
// every trip, every wallet transaction - plus a one-click PDF export.
// Driver.controller.js's availableOrders already restricts a dedicated
// fleet driver to only ever accepting this same enterprise's own orders, so
// the report the backend returns here is inherently already scoped right;
// no extra filtering needed on this page. No approve/block/payout actions
// here (unlike AdminDriverDetailPage.jsx) - KYC approval and payouts stay
// admin-only, this is a read + export view.
export default function EnterpriseDriverDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [driver, setDriver] = useState(null);
  const [stats, setStats] = useState(null);
  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [reportError, setReportError] = useState('');
  const [downloadingReport, setDownloadingReport] = useState(false);

  const fetchDriver = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get(`/enterprise/drivers/${id}`);
      setDriver(data.data.driver);
      setStats(data.data.stats);
    } catch (err) {
      console.error('[EnterpriseDriverDetailPage] failed to load driver', err);
      setError(err.response?.data?.message || 'Could not load this driver.');
    } finally {
      setLoading(false);
    }
  }, [id]);

  const fetchReport = useCallback(async () => {
    setReportError('');
    try {
      const { data } = await axiosClient.get(`/enterprise/drivers/${id}/report`);
      setReport(data.data);
    } catch (err) {
      console.error('[EnterpriseDriverDetailPage] failed to load report', err);
      setReportError(err.response?.data?.message || 'Could not load the full driver report.');
    }
  }, [id]);

  useEffect(() => {
    fetchDriver();
    fetchReport();
  }, [fetchDriver, fetchReport]);

  const downloadReport = async () => {
    setDownloadingReport(true);
    setReportError('');
    try {
      const name = (driver?.userId?.name || 'driver').replace(/[^a-z0-9]+/gi, '-').toLowerCase();
      await downloadFile(`/enterprise/drivers/${id}/report/pdf`, `${name}-report.pdf`);
    } catch (err) {
      console.error('[EnterpriseDriverDetailPage] report PDF download failed', err);
      setReportError(err.response?.data?.message || 'Could not download the report.');
    } finally {
      setDownloadingReport(false);
    }
  };

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <button onClick={() => navigate('/drivers')} className="text-sm text-mist hover:text-signal transition-colors">
        ← Back to drivers
      </button>

      {loading && <div className="text-center py-16 text-mist text-sm">Loading driver…</div>}
      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {driver && (
        <>
          <div className="flex items-start justify-between flex-wrap gap-3">
            <div>
              <span className="eyebrow">Driver</span>
              <h1 className="font-display text-2xl font-semibold mt-1">{driver.userId?.name ?? 'Unnamed driver'}</h1>
              <p className="text-mist text-sm font-mono mt-1">{driver.userId?.phone}</p>
            </div>
            {driver.isApproved ? (
              <span className="inline-flex items-center px-3 py-1.5 rounded-md text-xs font-mono font-medium bg-go/10 text-go">Approved</span>
            ) : (
              <span className="inline-flex items-center px-3 py-1.5 rounded-md text-xs font-mono font-medium bg-hold/10 text-hold">Pending KYC review</span>
            )}
          </div>

          <div className="grid md:grid-cols-3 gap-4">
            <div className="bg-panel border border-line rounded-lg p-4">
              <span className="eyebrow">Vehicle</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Number</span><span className="font-mono">{driver.vehicleNumber}</span></div>
                <div className="flex justify-between"><span className="text-mist">Type</span><span className="capitalize">{driver.vehicleType.replace('_', ' ')}</span></div>
                <div className="flex justify-between"><span className="text-mist">License no.</span><span className="font-mono">{driver.licenseNumber}</span></div>
              </div>
            </div>

            <div className="bg-panel border border-line rounded-lg p-4">
              <span className="eyebrow">Performance</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Rating</span><span>{driver.ratingCount ? `${driver.rating?.toFixed(1)} ★ (${driver.ratingCount})` : 'No ratings yet'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Total orders</span><span>{stats?.totalOrders ?? 0}</span></div>
                <div className="flex justify-between"><span className="text-mist">Delivered</span><span>{stats?.deliveredOrders ?? 0}</span></div>
              </div>
            </div>

            <div className="bg-panel border border-line rounded-lg p-4">
              <span className="eyebrow">Contact</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Phone</span><span className="font-mono">{driver.userId?.phone ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Email</span><span>{driver.userId?.email ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Joined</span><span>{driver.userId?.createdAt ? new Date(driver.userId.createdAt).toLocaleDateString('en-IN') : '—'}</span></div>
              </div>
            </div>
          </div>

          <div className="bg-panel border border-line rounded-lg p-4 space-y-4">
            <div className="flex items-center justify-between flex-wrap gap-3">
              <div>
                <span className="eyebrow">Full driver report</span>
                <p className="text-xs text-mist mt-1">Every trip and every wallet transaction for this driver, in one place.</p>
              </div>
              <button
                onClick={downloadReport}
                disabled={downloadingReport}
                className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
              >
                {downloadingReport ? 'Preparing…' : 'Download full report (PDF)'}
              </button>
            </div>

            {reportError && <p className="text-xs text-stop">{reportError}</p>}

            {report && (
              <>
                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
                  {[
                    ['Total trips', report.summary.totalTrips],
                    ['Delivered', report.summary.deliveredTrips],
                    ['Cancelled', report.summary.cancelledTrips],
                    ['Distance', `${report.summary.totalDistanceKm} km`],
                    ['Earnings credited', `₹${report.summary.totalEarnings}`],
                    ['Paid out', `₹${report.summary.totalPayouts}`],
                  ].map(([label, value]) => (
                    <div key={label} className="border border-line rounded-md px-3 py-2.5">
                      <div className="text-xs text-mist">{label}</div>
                      <div className="text-lg font-display font-semibold mt-0.5">{value}</div>
                    </div>
                  ))}
                </div>

                <div>
                  <span className="eyebrow block mb-2">Trips ({report.orders.length})</span>
                  <DataTable
                    keyField="_id"
                    rows={report.orders}
                    onRowClick={(row) => navigate(`/order-tracking/${row._id}`)}
                    columns={[
                      { key: 'date', label: 'Date', render: (o) => new Date(o.createdAt).toLocaleDateString('en-IN') },
                      { key: 'id', label: 'Order', render: (o) => <span className="font-mono">{o._id.slice(-8).toUpperCase()}</span> },
                      { key: 'route', label: 'Route', render: (o) => `${o.pickupLocation?.address ?? '—'} → ${o.dropLocation?.address ?? '—'}` },
                      { key: 'status', label: 'Status', render: (o) => <StatusBadge status={o.status} /> },
                      { key: 'price', label: 'Price', render: (o) => `₹${o.price}` },
                      { key: 'payment', label: 'Payment', render: (o) => (o.paymentMethod === 'cod' ? 'COD' : 'Online') },
                    ]}
                  />
                </div>

                <div>
                  <span className="eyebrow block mb-2">Wallet transactions ({report.walletTransactions.length})</span>
                  <DataTable
                    keyField="_id"
                    rows={report.walletTransactions}
                    columns={[
                      { key: 'date', label: 'Date', render: (t) => new Date(t.createdAt).toLocaleDateString('en-IN') },
                      { key: 'type', label: 'Type', render: (t) => WALLET_TYPE_LABELS[t.type] ?? t.type },
                      {
                        key: 'amount',
                        label: 'Amount',
                        render: (t) => (
                          <span className={t.amount >= 0 ? 'text-go' : 'text-stop'}>
                            {t.amount >= 0 ? '+' : '-'}₹{Math.abs(t.amount)}
                          </span>
                        ),
                      },
                      { key: 'balanceAfter', label: 'Balance after', render: (t) => `₹${t.balanceAfter}` },
                      { key: 'note', label: 'Note', render: (t) => t.note ?? '—' },
                    ]}
                  />
                </div>
              </>
            )}
          </div>
        </>
      )}
    </ConsoleShell>
  );
}
