import { useEffect, useState, useCallback } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

const STATUS_OPTIONS = ['', 'pending', 'approved'];

function EnterpriseCard({ enterprise, onSetActive }) {
  const [saving, setSaving] = useState(false);

  const act = async (isActive) => {
    setSaving(true);
    try {
      await onSetActive(enterprise._id, isActive);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
      <div className="flex items-start justify-between flex-wrap gap-2">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="font-medium text-sm">{enterprise.companyName}</span>
            <StatusBadge status={enterprise.isActive ? 'approved' : 'pending'} />
            {enterprise.gstin && <span className="text-xs px-2 py-0.5 rounded bg-panel2 text-mist font-mono">{enterprise.gstin}</span>}
          </div>
          <p className="text-xs text-mist">
            {enterprise.adminUserId?.name ?? 'Unknown contact'} · {enterprise.adminUserId?.email ?? '—'}
          </p>
        </div>
        <div className="text-xs text-mist text-right shrink-0">
          <div>Signed up {new Date(enterprise.createdAt).toLocaleDateString('en-IN')}</div>
        </div>
      </div>

      <div className="border-t border-line pt-3 flex gap-2">
        {!enterprise.isActive ? (
          <button onClick={() => act(true)} disabled={saving} className="text-xs px-3 py-1.5 bg-go/10 text-go rounded-md hover:bg-go/20 transition-colors disabled:opacity-50">
            Approve
          </button>
        ) : (
          <button onClick={() => act(false)} disabled={saving} className="text-xs px-3 py-1.5 bg-stop/10 text-stop rounded-md hover:bg-stop/20 transition-colors disabled:opacity-50">
            Suspend
          </button>
        )}
      </div>
    </div>
  );
}

export default function AdminEnterprisesPage() {
  const [enterprises, setEnterprises] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 });
  const [status, setStatus] = useState('');
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchEnterprises = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/enterprises', { params: { status: status || undefined, page, limit: 10 } });
      setEnterprises(data.data.enterprises);
      setPagination(data.data.pagination);
    } catch (err) {
      console.error('[AdminEnterprisesPage] failed to load enterprises', err);
      setError(err.response?.data?.message || 'Could not load enterprises.');
    } finally {
      setLoading(false);
    }
  }, [status, page]);

  useEffect(() => {
    fetchEnterprises();
  }, [fetchEnterprises]);

  useEffect(() => {
    setPage(1);
  }, [status]);

  const handleSetActive = async (id, isActive) => {
    try {
      await axiosClient.put(`/admin/enterprises/${id}/status`, { isActive });
      await fetchEnterprises();
    } catch (err) {
      console.error('[AdminEnterprisesPage] status update failed', err);
      setError(err.response?.data?.message || 'Could not update enterprise status.');
    }
  };

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Accounts</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Enterprises</h1>
      </div>

      <div className="flex flex-wrap gap-3 items-center bg-panel border border-line rounded-lg p-3">
        <select
          value={status}
          onChange={(e) => setStatus(e.target.value)}
          className="bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
        >
          {STATUS_OPTIONS.map((s) => (
            <option key={s} value={s}>{s ? s[0].toUpperCase() + s.slice(1) : 'All statuses'}</option>
          ))}
        </select>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading enterprises…</div>
      ) : enterprises.length === 0 ? (
        <div className="text-center py-16 text-mist text-sm border border-line rounded-lg">No enterprises found.</div>
      ) : (
        <>
          <div className="space-y-3">
            {enterprises.map((e) => (
              <EnterpriseCard key={e._id} enterprise={e} onSetActive={handleSetActive} />
            ))}
          </div>
          <div className="flex items-center justify-between text-sm text-mist">
            <span>{pagination.total} enterprise{pagination.total !== 1 ? 's' : ''} · page {pagination.page} of {Math.max(1, pagination.pages)}</span>
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
