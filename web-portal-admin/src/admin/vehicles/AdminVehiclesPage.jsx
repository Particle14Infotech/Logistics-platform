import { useEffect, useState, useCallback } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

export default function AdminVehiclesPage() {
  const [vehicles, setVehicles] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 });
  const [vehicleType, setVehicleType] = useState('');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  // Live catalog (not the old hardcoded 5-value list) - used both for the
  // filter dropdown's options and to show a real category name instead of
  // a raw slug->spaces transform in the table.
  const [categories, setCategories] = useState([]);
  const categoryByType = new Map(categories.map((c) => [c.vehicleType, c]));

  useEffect(() => {
    axiosClient.get('/admin/vehicle-categories').then(({ data }) => setCategories(data.data.categories)).catch((err) => {
      console.error('[AdminVehiclesPage] failed to load vehicle categories', err);
    });
  }, []);

  const fetchVehicles = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/vehicles', {
        params: { vehicleType: vehicleType || undefined, search: search || undefined, page, limit: 15 },
      });
      setVehicles(data.data.vehicles);
      setPagination(data.data.pagination);
    } catch (err) {
      console.error('[AdminVehiclesPage] failed to load vehicles', err);
      setError(err.response?.data?.message || 'Could not load vehicles.');
    } finally {
      setLoading(false);
    }
  }, [vehicleType, search, page]);

  useEffect(() => {
    fetchVehicles();
  }, [fetchVehicles]);

  useEffect(() => {
    setPage(1);
  }, [vehicleType, search]);

  const columns = [
    { key: 'vehicleNumber', label: 'Vehicle', render: (r) => <span className="font-mono text-xs">{r.vehicleNumber}</span> },
    { key: 'vehicleType', label: 'Type', render: (r) => <span className="capitalize text-xs">{categoryByType.get(r.vehicleType)?.name ?? r.vehicleType.replace('_', ' ')}</span> },
    { key: 'owner', label: 'Owner', render: (r) => r.owner?.name ?? '—' },
    {
      key: 'availability',
      label: 'Availability',
      render: (r) =>
        r.isAvailable ? (
          <span className="inline-flex items-center gap-1 text-xs font-mono text-go"><span className="w-1.5 h-1.5 rounded-full bg-go" />Online</span>
        ) : (
          <span className="inline-flex items-center gap-1 text-xs font-mono text-mist"><span className="w-1.5 h-1.5 rounded-full bg-mist" />Offline</span>
        ),
    },
    {
      key: 'compliance',
      label: 'Compliance',
      render: (r) =>
        r.needsAttention ? (
          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium bg-stop/10 text-stop" title={r.missingCompliance.join(', ')}>
            Needs attention
          </span>
        ) : (
          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium bg-go/10 text-go">All documents current</span>
        ),
    },
  ];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Fleet</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Vehicles</h1>
        <p className="text-mist text-sm mt-1">Inventory derived from registered drivers. Each driver operates one vehicle.</p>
      </div>

      <div className="flex flex-wrap gap-3 items-center bg-panel border border-line rounded-lg p-3">
        <input
          type="text"
          placeholder="Search by vehicle number…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="flex-1 min-w-[200px] bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
        />
        <select
          value={vehicleType}
          onChange={(e) => setVehicleType(e.target.value)}
          className="bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
        >
          <option value="">All vehicle types</option>
          {categories.map((c) => (
            <option key={c.vehicleType} value={c.vehicleType}>{c.name}{c.lengthFt ? ` • ${c.lengthFt}ft` : ''}</option>
          ))}
        </select>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading vehicles…</div>
      ) : (
        <>
          <DataTable columns={columns} rows={vehicles} keyField="_id" />
          <div className="flex items-center justify-between text-sm text-mist">
            <span>{pagination.total} vehicle{pagination.total !== 1 ? 's' : ''} · page {pagination.page} of {Math.max(1, pagination.pages)}</span>
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
