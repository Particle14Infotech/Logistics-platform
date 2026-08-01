import { useEffect, useState, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

function ComplianceBadge({ needsAttention }) {
  return needsAttention > 0 ? (
    <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium bg-hold/10 text-hold">
      {needsAttention} need{needsAttention !== 1 ? '' : 's'} attention
    </span>
  ) : (
    <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium bg-go/10 text-go">All clear</span>
  );
}

export default function AdminFleetsPage() {
  const navigate = useNavigate();
  const [fleets, setFleets] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 });
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchFleets = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/fleets', { params: { search: search || undefined, page, limit: 15 } });
      setFleets(data.data.fleets);
      setPagination(data.data.pagination);
    } catch (err) {
      console.error('[AdminFleetsPage] failed to load fleets', err);
      setError(err.response?.data?.message || 'Could not load fleets. Is the backend running?');
    } finally {
      setLoading(false);
    }
  }, [search, page]);

  useEffect(() => {
    fetchFleets();
  }, [fetchFleets]);

  useEffect(() => {
    setPage(1);
  }, [search]);

  const columns = [
    { key: 'companyName', label: 'Fleet' },
    { key: 'owner', label: 'Owner', render: (r) => r.owner?.name ?? '—' },
    { key: 'phone', label: 'Phone', render: (r) => <span className="font-mono text-xs">{r.owner?.phone ?? '—'}</span> },
    { key: 'vehicleCount', label: 'Vehicles', render: (r) => r.vehicleCount },
    { key: 'compliance', label: 'Compliance', render: (r) => <ComplianceBadge needsAttention={r.needsAttention} /> },
  ];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Fleet</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Fleets</h1>
      </div>

      <div className="flex flex-wrap gap-3 items-center bg-panel border border-line rounded-lg p-3">
        <input
          type="text"
          placeholder="Search by company name…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="flex-1 min-w-[200px] bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
        />
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading fleets…</div>
      ) : (
        <>
          <DataTable columns={columns} rows={fleets} keyField="_id" onRowClick={(fleet) => navigate(`/fleets/${fleet._id}`)} />
          <div className="flex items-center justify-between text-sm text-mist">
            <span>
              {pagination.total} fleet{pagination.total !== 1 ? 's' : ''} · page {pagination.page} of {Math.max(1, pagination.pages)}
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
