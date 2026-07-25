import { useEffect, useState, useCallback } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

const STATUS_OPTIONS = ['', 'created', 'captured', 'failed', 'refunded'];

export default function AdminPaymentsPage() {
  const [payments, setPayments] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 });
  const [status, setStatus] = useState('');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [refundingId, setRefundingId] = useState(null);

  const fetchPayments = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/payments', {
        params: { status: status || undefined, search: search || undefined, page, limit: 15 },
      });
      setPayments(data.data.payments);
      setPagination(data.data.pagination);
    } catch (err) {
      console.error('[AdminPaymentsPage] failed to load payments', err);
      setError(err.response?.data?.message || 'Could not load payments.');
    } finally {
      setLoading(false);
    }
  }, [status, search, page]);

  useEffect(() => {
    fetchPayments();
  }, [fetchPayments]);

  useEffect(() => {
    setPage(1);
  }, [status, search]);

  const handleRefund = async (paymentId) => {
    setRefundingId(paymentId);
    try {
      await axiosClient.put(`/admin/payments/${paymentId}/refund`);
      await fetchPayments();
    } catch (err) {
      console.error('[AdminPaymentsPage] refund failed', err);
      setError(err.response?.data?.message || 'Could not process refund.');
    } finally {
      setRefundingId(null);
    }
  };

  const columns = [
    { key: 'id', label: 'Payment', render: (r) => <span className="font-mono text-xs">{r.razorpayPaymentId ?? r._id.slice(-8)}</span> },
    { key: 'customer', label: 'Customer', render: (r) => r.userId?.name ?? '—' },
    { key: 'route', label: 'Order', render: (r) => (r.orderId ? <span className="text-mist">{r.orderId.pickupLocation?.address} → {r.orderId.dropLocation?.address}</span> : '—') },
    { key: 'amount', label: 'Amount', render: (r) => <span className="font-mono">₹{(r.amount / 100).toLocaleString('en-IN')}</span> },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    {
      key: 'action',
      label: '',
      render: (r) =>
        r.status === 'captured' ? (
          <button
            onClick={() => handleRefund(r._id)}
            disabled={refundingId === r._id}
            className="text-xs text-stop hover:underline disabled:opacity-50"
          >
            {refundingId === r._id ? 'Refunding…' : 'Refund'}
          </button>
        ) : (
          <span className="text-xs text-mist">—</span>
        ),
    },
  ];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/admin/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Revenue</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Payments</h1>
      </div>

      <div className="flex flex-wrap gap-3 items-center bg-panel border border-line rounded-lg p-3">
        <input
          type="text"
          placeholder="Search by customer name…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="flex-1 min-w-[200px] bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
        />
        <select
          value={status}
          onChange={(e) => setStatus(e.target.value)}
          className="bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
        >
          {STATUS_OPTIONS.map((s) => (
            <option key={s} value={s}>{s || 'All statuses'}</option>
          ))}
        </select>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading payments…</div>
      ) : (
        <>
          <DataTable columns={columns} rows={payments} keyField="_id" />
          <div className="flex items-center justify-between text-sm text-mist">
            <span>{pagination.total} payment{pagination.total !== 1 ? 's' : ''} · page {pagination.page} of {Math.max(1, pagination.pages)}</span>
            <div className="flex gap-2">
              <button disabled={page <= 1} onClick={() => setPage((p) => Math.max(1, p - 1))} className="px-3 py-1.5 border border-line rounded-md disabled:opacity-40 hover:border-signal transition-colors">← Prev</button>
              <button disabled={page >= pagination.pages} onClick={() => setPage((p) => p + 1)} className="px-3 py-1.5 border border-line rounded-md disabled:opacity-40 hover:border-signal transition-colors">Next →</button>
            </div>
          </div>
        </>
      )}
    </ConsoleShell>
  );
}
