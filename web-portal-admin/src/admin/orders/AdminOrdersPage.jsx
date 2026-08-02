import { useEffect, useState, useCallback } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

const STATUS_OPTIONS = ['', 'pending', 'accepted', 'picked_up', 'in_transit', 'awaiting_payment', 'delivered', 'cancelled'];
const VEHICLE_OPTIONS = ['', 'bike', 'auto', 'mini_truck', 'medium_truck', 'large_truck'];

export default function AdminOrdersPage() {
  const navigate = useNavigate();
  // Lets the dashboard's KPI cards/chart bars link straight here pre-filtered
  // (e.g. /orders?status=delivered&dateFrom=2026-07-31) instead of just
  // dumping the admin on an unfiltered list they have to redo by hand.
  const [searchParams] = useSearchParams();
  const [orders, setOrders] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 });
  const [status, setStatus] = useState(searchParams.get('status') || '');
  const [vehicleType, setVehicleType] = useState('');
  const [search, setSearch] = useState('');
  const [dateFrom] = useState(searchParams.get('dateFrom') || '');
  const [dateTo] = useState(searchParams.get('dateTo') || '');
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchOrders = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/orders', {
        params: {
          status: status || undefined,
          vehicleType: vehicleType || undefined,
          search: search || undefined,
          dateFrom: dateFrom || undefined,
          dateTo: dateTo || undefined,
          page,
          limit: 15,
        },
      });
      setOrders(data.data.orders);
      setPagination(data.data.pagination);
    } catch (err) {
      console.error('[AdminOrdersPage] failed to load orders', err);
      setError(err.response?.data?.message || 'Could not load orders. Is the backend running?');
    } finally {
      setLoading(false);
    }
  }, [status, vehicleType, search, dateFrom, dateTo, page]);

  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  // Reset to page 1 whenever a filter changes (not when page itself changes)
  useEffect(() => {
    setPage(1);
  }, [status, vehicleType, search]);

  const columns = [
    { key: 'id', label: 'Order', render: (r) => <span className="font-mono text-xs">{r._id.slice(-8).toUpperCase()}</span> },
    {
      key: 'customer',
      label: 'Customer',
      // Enterprise-placed orders (bulk booking) should read as the company
      // that ordered them, not whichever individual enterprise user's
      // account happened to submit it - and it's the only name guaranteed
      // to be set, since a plain customer account's own name is optional
      // and can be blank until they fill in their profile.
      render: (r) => r.enterpriseId?.companyName ?? r.customerId?.name ?? '—',
    },
    {
      key: 'route',
      label: 'Route',
      render: (r) => (
        <span className="text-mist">
          {r.pickupLocation?.address ?? '—'} → {r.dropLocation?.address ?? '—'}
        </span>
      ),
    },
    { key: 'vehicleType', label: 'Vehicle', render: (r) => <span className="font-mono text-xs capitalize">{r.vehicleType.replace('_', ' ')}</span> },
    {
      key: 'driver',
      label: 'Driver',
      render: (r) => (r.driverId ? <span className="font-mono text-xs">{r.driverId.vehicleNumber}</span> : <span className="text-mist text-xs">Unassigned</span>),
    },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    { key: 'price', label: 'Amount', render: (r) => <span className="font-mono">₹{r.price.toLocaleString('en-IN')}</span> },
  ];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Operations</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Orders</h1>
      </div>

      {/* Filter bar */}
      <div className="flex flex-wrap gap-3 items-center bg-panel border border-line rounded-lg p-3">
        <input
          type="text"
          placeholder="Search route or goods type…"
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
            <option key={s} value={s}>
              {s ? s.replace('_', ' ') : 'All statuses'}
            </option>
          ))}
        </select>
        <select
          value={vehicleType}
          onChange={(e) => setVehicleType(e.target.value)}
          className="bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
        >
          {VEHICLE_OPTIONS.map((v) => (
            <option key={v} value={v}>
              {v ? v.replace('_', ' ') : 'All vehicles'}
            </option>
          ))}
        </select>
        {(status || vehicleType || search) && (
          <button
            onClick={() => {
              setStatus('');
              setVehicleType('');
              setSearch('');
            }}
            className="text-xs text-mist hover:text-signal transition-colors"
          >
            Clear filters
          </button>
        )}
      </div>

      {error && (
        <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>
      )}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading orders…</div>
      ) : (
        <>
          <DataTable columns={columns} rows={orders} keyField="_id" onRowClick={(order) => navigate(`/orders/${order._id}`)} />

          <div className="flex items-center justify-between text-sm text-mist">
            <span>
              {pagination.total} order{pagination.total !== 1 ? 's' : ''} · page {pagination.page} of {Math.max(1, pagination.pages)}
            </span>
            <div className="flex gap-2">
              <button
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                className="px-3 py-1.5 border border-line rounded-md disabled:opacity-40 hover:border-signal transition-colors"
              >
                ← Prev
              </button>
              <button
                disabled={page >= pagination.pages}
                onClick={() => setPage((p) => p + 1)}
                className="px-3 py-1.5 border border-line rounded-md disabled:opacity-40 hover:border-signal transition-colors"
              >
                Next →
              </button>
            </div>
          </div>
        </>
      )}
    </ConsoleShell>
  );
}
