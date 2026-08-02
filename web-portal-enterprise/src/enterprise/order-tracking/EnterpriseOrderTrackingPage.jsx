import { useEffect, useState, useCallback } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

const STATUS_OPTIONS = ['', 'pending', 'accepted', 'picked_up', 'in_transit', 'awaiting_payment', 'delivered', 'cancelled'];

export default function EnterpriseOrderTrackingPage() {
  // Lets the dashboard's KPI cards/chart bars link straight here
  // pre-filtered instead of just dumping the user on an unfiltered list.
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [orders, setOrders] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 });
  const [status, setStatus] = useState(searchParams.get('status') || '');
  const [dateFrom] = useState(searchParams.get('dateFrom') || '');
  const [dateTo] = useState(searchParams.get('dateTo') || '');
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchOrders = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/enterprise/orders', {
        params: { status: status || undefined, dateFrom: dateFrom || undefined, dateTo: dateTo || undefined, page, limit: 15 },
      });
      setOrders(data.data.orders);
      setPagination(data.data.pagination);
    } catch (err) {
      console.error('[EnterpriseOrderTrackingPage] failed to load orders', err);
      setError(err.response?.data?.message || 'Could not load orders.');
    } finally {
      setLoading(false);
    }
  }, [status, dateFrom, dateTo, page]);

  useEffect(() => { fetchOrders(); }, [fetchOrders]);
  useEffect(() => { setPage(1); }, [status]);

  const columns = [
    { key: 'id', label: 'Order', render: (r) => <span className="font-mono text-xs">{r._id.slice(-8).toUpperCase()}</span> },
    { key: 'route', label: 'Route', render: (r) => <span className="text-mist">{r.pickupLocation?.address} → {r.dropLocation?.address}</span> },
    { key: 'vehicleType', label: 'Vehicle', render: (r) => <span className="capitalize text-xs">{r.vehicleType.replace('_', ' ')}</span> },
    { key: 'driver', label: 'Driver', render: (r) => (r.driverId ? r.driverId.userId?.name ?? r.driverId.vehicleNumber : <span className="text-mist text-xs">Unassigned</span>) },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    {
      // Backend only sends these when relevant to the order's current
      // status (see enterprise.controller.js's listOrders) - there was
      // previously no way at all to hand these codes to the driver for a
      // shipment booked through this portal instead of the customer app.
      key: 'code',
      label: 'Code for driver',
      render: (r) =>
        r.startOtp ? (
          <span className="font-mono text-xs" title="Give this to the driver to start the trip">Start: {r.startOtp}</span>
        ) : r.deliveryOtp ? (
          <span className="font-mono text-xs" title="Give this to the driver to confirm delivery">Delivery: {r.deliveryOtp}</span>
        ) : (
          <span className="text-mist text-xs">—</span>
        ),
    },
    { key: 'price', label: 'Amount', render: (r) => <span className="font-mono">₹{r.price.toLocaleString('en-IN')}</span> },
  ];

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Shipments</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Order tracking</h1>
      </div>

      <div className="flex flex-wrap gap-3 items-center bg-panel border border-line rounded-lg p-3">
        <select value={status} onChange={(e) => setStatus(e.target.value)} className="bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors">
          {STATUS_OPTIONS.map((s) => <option key={s} value={s}>{s ? s.replace('_', ' ') : 'All statuses'}</option>)}
        </select>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading orders…</div>
      ) : (
        <>
          <DataTable columns={columns} rows={orders} keyField="_id" onRowClick={(row) => navigate(`/order-tracking/${row._id}`)} />
          <div className="flex items-center justify-between text-sm text-mist">
            <span>{pagination.total} order{pagination.total !== 1 ? 's' : ''} · page {pagination.page} of {Math.max(1, pagination.pages)}</span>
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
