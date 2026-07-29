import { useEffect, useState, useCallback } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

const STATUS_OPTIONS = ['', 'open', 'investigating', 'resolved', 'rejected'];

function DisputeCard({ dispute, onResolve }) {
  const [note, setNote] = useState(dispute.resolutionNote ?? '');
  const [saving, setSaving] = useState(false);
  const isClosed = ['resolved', 'rejected'].includes(dispute.status);

  const act = async (status) => {
    setSaving(true);
    try {
      await onResolve(dispute._id, status, note);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
      <div className="flex items-start justify-between flex-wrap gap-2">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="font-mono text-xs text-mist">{dispute._id.slice(-8).toUpperCase()}</span>
            <StatusBadge status={dispute.status} />
            <span className="text-xs px-2 py-0.5 rounded bg-panel2 text-mist capitalize">{dispute.category}</span>
          </div>
          <p className="text-sm">{dispute.description}</p>
        </div>
        <div className="text-xs text-mist text-right shrink-0">
          <div>{dispute.raisedBy?.name ?? 'Unknown'} ({dispute.raisedByRole})</div>
          <div>{new Date(dispute.createdAt).toLocaleDateString('en-IN')}</div>
        </div>
      </div>

      {dispute.orderId && (
        <div className="text-xs text-mist border-t border-line pt-2">
          Order: {dispute.orderId.pickupLocation?.address} → {dispute.orderId.dropLocation?.address} · ₹{dispute.orderId.price?.toLocaleString('en-IN')}
        </div>
      )}

      {!isClosed && (
        <div className="border-t border-line pt-3 space-y-2">
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="Resolution note (what was decided / refund issued / etc.)"
            rows={2}
            className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors resize-none"
          />
          <div className="flex gap-2">
            {dispute.status === 'open' && (
              <button onClick={() => act('investigating')} disabled={saving} className="text-xs px-3 py-1.5 border border-line rounded-md hover:border-signal transition-colors disabled:opacity-50">
                Mark investigating
              </button>
            )}
            <button onClick={() => act('resolved')} disabled={saving} className="text-xs px-3 py-1.5 bg-go/10 text-go rounded-md hover:bg-go/20 transition-colors disabled:opacity-50">
              Resolve
            </button>
            <button onClick={() => act('rejected')} disabled={saving} className="text-xs px-3 py-1.5 bg-stop/10 text-stop rounded-md hover:bg-stop/20 transition-colors disabled:opacity-50">
              Reject
            </button>
          </div>
        </div>
      )}
      {isClosed && dispute.resolutionNote && (
        <div className="border-t border-line pt-2 text-xs text-mist">
          <span className="text-paper/80">Resolution:</span> {dispute.resolutionNote}
        </div>
      )}
    </div>
  );
}

export default function AdminDisputesPage() {
  const [disputes, setDisputes] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 });
  const [status, setStatus] = useState('');
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchDisputes = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/disputes', { params: { status: status || undefined, page, limit: 10 } });
      setDisputes(data.data.disputes);
      setPagination(data.data.pagination);
    } catch (err) {
      console.error('[AdminDisputesPage] failed to load disputes', err);
      setError(err.response?.data?.message || 'Could not load disputes.');
    } finally {
      setLoading(false);
    }
  }, [status, page]);

  useEffect(() => {
    fetchDisputes();
  }, [fetchDisputes]);

  useEffect(() => {
    setPage(1);
  }, [status]);

  const handleResolve = async (id, newStatus, note) => {
    try {
      await axiosClient.put(`/admin/disputes/${id}/resolve`, { status: newStatus, resolutionNote: note });
      await fetchDisputes();
    } catch (err) {
      console.error('[AdminDisputesPage] resolve failed', err);
      setError(err.response?.data?.message || 'Could not update dispute.');
    }
  };

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Support</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Disputes</h1>
      </div>

      <div className="flex flex-wrap gap-3 items-center bg-panel border border-line rounded-lg p-3">
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
        <div className="text-center py-16 text-mist text-sm">Loading disputes…</div>
      ) : disputes.length === 0 ? (
        <div className="text-center py-16 text-mist text-sm border border-line rounded-lg">No disputes found.</div>
      ) : (
        <>
          <div className="space-y-3">
            {disputes.map((d) => (
              <DisputeCard key={d._id} dispute={d} onResolve={handleResolve} />
            ))}
          </div>
          <div className="flex items-center justify-between text-sm text-mist">
            <span>{pagination.total} dispute{pagination.total !== 1 ? 's' : ''} · page {pagination.page} of {Math.max(1, pagination.pages)}</span>
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
