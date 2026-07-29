import { useEffect, useState, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

const VEHICLE_OPTIONS = ['', 'bike', 'auto', 'mini_truck', 'medium_truck', 'large_truck'];

function ApprovalBadge({ isApproved }) {
  return isApproved ? (
    <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium bg-go/10 text-go">Approved</span>
  ) : (
    <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium bg-hold/10 text-hold">Pending review</span>
  );
}

function OnlineBadge({ isAvailable }) {
  return isAvailable ? (
    <span className="inline-flex items-center gap-1 text-xs font-mono text-go"><span className="w-1.5 h-1.5 rounded-full bg-go" />Online</span>
  ) : (
    <span className="inline-flex items-center gap-1 text-xs font-mono text-mist"><span className="w-1.5 h-1.5 rounded-full bg-mist" />Offline</span>
  );
}

export default function AdminDriversPage() {
  const navigate = useNavigate();
  const [drivers, setDrivers] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 });
  const [approvalFilter, setApprovalFilter] = useState(''); // '', 'true', 'false'
  const [vehicleType, setVehicleType] = useState('');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchDrivers = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/drivers', {
        params: {
          isApproved: approvalFilter || undefined,
          vehicleType: vehicleType || undefined,
          search: search || undefined,
          page,
          limit: 15,
        },
      });
      setDrivers(data.data.drivers);
      setPagination(data.data.pagination);
    } catch (err) {
      console.error('[AdminDriversPage] failed to load drivers', err);
      setError(err.response?.data?.message || 'Could not load drivers. Is the backend running?');
    } finally {
      setLoading(false);
    }
  }, [approvalFilter, vehicleType, search, page]);

  useEffect(() => {
    fetchDrivers();
  }, [fetchDrivers]);

  useEffect(() => {
    setPage(1);
  }, [approvalFilter, vehicleType, search]);

  const columns = [
    { key: 'name', label: 'Driver', render: (r) => r.userId?.name ?? '—' },
    { key: 'phone', label: 'Phone', render: (r) => <span className="font-mono text-xs">{r.userId?.phone ?? '—'}</span> },
    { key: 'vehicle', label: 'Vehicle', render: (r) => <span className="font-mono text-xs">{r.vehicleNumber}</span> },
    { key: 'vehicleType', label: 'Type', render: (r) => <span className="capitalize text-xs">{r.vehicleType.replace('_', ' ')}</span> },
    { key: 'rating', label: 'Rating', render: (r) => <span>{r.rating?.toFixed(1) ?? '—'} ★</span> },
    { key: 'approval', label: 'KYC status', render: (r) => <ApprovalBadge isApproved={r.isApproved} /> },
    { key: 'online', label: 'Availability', render: (r) => <OnlineBadge isAvailable={r.isAvailable} /> },
  ];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Fleet</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Drivers</h1>
      </div>

      <div className="flex flex-wrap gap-3 items-center bg-panel border border-line rounded-lg p-3">
        <input
          type="text"
          placeholder="Search by driver name…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="flex-1 min-w-[200px] bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
        />
        <select
          value={approvalFilter}
          onChange={(e) => setApprovalFilter(e.target.value)}
          className="bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
        >
          <option value="">All KYC statuses</option>
          <option value="true">Approved</option>
          <option value="false">Pending review</option>
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
        {(approvalFilter || vehicleType || search) && (
          <button
            onClick={() => {
              setApprovalFilter('');
              setVehicleType('');
              setSearch('');
            }}
            className="text-xs text-mist hover:text-signal transition-colors"
          >
            Clear filters
          </button>
        )}
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading drivers…</div>
      ) : (
        <>
          <DataTable columns={columns} rows={drivers} keyField="_id" onRowClick={(driver) => navigate(`/drivers/${driver._id}`)} />
          <div className="flex items-center justify-between text-sm text-mist">
            <span>
              {pagination.total} driver{pagination.total !== 1 ? 's' : ''} · page {pagination.page} of {Math.max(1, pagination.pages)}
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
