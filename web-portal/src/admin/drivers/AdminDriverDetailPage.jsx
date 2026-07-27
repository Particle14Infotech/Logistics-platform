import { useEffect, useState, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

const DOCUMENT_LABELS = {
  licenseUrl: 'Driving license',
  rcUrl: 'Vehicle RC',
  aadhaarUrl: 'Aadhaar card',
  photoUrl: 'Photo ID',
  insuranceUrl: 'Insurance',
  permitUrl: 'Permit',
  pollutionCertUrl: 'Pollution certificate',
  panCardUrl: 'PAN card',
};

// Uploaded documents (e.g. a driver's selfie from the mobile app) are stored
// as relative paths like '/uploads/xyz.jpg', served by the backend, not this
// web app - so they need the backend's origin prepended. Seed/demo documents
// are already-absolute https:// URLs and pass through unchanged.
const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1';
const BACKEND_ORIGIN = API_BASE.replace(/\/api\/v1\/?$/, '');
function resolveDocUrl(url) {
  return url.startsWith('/') ? `${BACKEND_ORIGIN}${url}` : url;
}

export default function AdminDriverDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [driver, setDriver] = useState(null);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState('');
  const [actionError, setActionError] = useState('');

  const fetchDriver = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get(`/admin/drivers/${id}`);
      setDriver(data.data.driver);
      setStats(data.data.stats);
    } catch (err) {
      console.error('[AdminDriverDetailPage] failed to load driver', err);
      setError(err.response?.data?.message || 'Could not load this driver.');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchDriver();
  }, [fetchDriver]);

  const updateStatus = async (payload) => {
    setUpdating(true);
    setActionError('');
    try {
      await axiosClient.put(`/admin/drivers/${id}`, payload);
      await fetchDriver();
    } catch (err) {
      console.error('[AdminDriverDetailPage] update failed', err);
      setActionError(err.response?.data?.message || 'Could not update driver status.');
    } finally {
      setUpdating(false);
    }
  };

  const documentEntries = driver ? Object.entries(DOCUMENT_LABELS).filter(([key]) => driver.documents?.[key]) : [];
  const missingDocuments = driver ? Object.entries(DOCUMENT_LABELS).filter(([key]) => !driver.documents?.[key]) : [];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/admin/login" dateLabel="25 JUL 2026">
      <button onClick={() => navigate('/admin/drivers')} className="text-sm text-mist hover:text-signal transition-colors">
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
            <div className="flex gap-2">
              {driver.isApproved ? (
                <span className="inline-flex items-center px-3 py-1.5 rounded-md text-xs font-mono font-medium bg-go/10 text-go">Approved</span>
              ) : (
                <span className="inline-flex items-center px-3 py-1.5 rounded-md text-xs font-mono font-medium bg-hold/10 text-hold">Pending review</span>
              )}
              {driver.userId?.isBlocked && (
                <span className="inline-flex items-center px-3 py-1.5 rounded-md text-xs font-mono font-medium bg-stop/10 text-stop">Blocked</span>
              )}
            </div>
          </div>

          {actionError && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-3">{actionError}</div>}

          {/* Action bar */}
          <div className="flex flex-wrap gap-2 bg-panel border border-line rounded-lg p-3">
            {!driver.isApproved && (
              <button
                onClick={() => updateStatus({ isApproved: true })}
                disabled={updating}
                className="bg-go/10 text-go text-sm font-medium rounded-md px-4 py-2 hover:bg-go/20 disabled:opacity-50 transition-colors"
              >
                Approve driver
              </button>
            )}
            {driver.isApproved && (
              <button
                onClick={() => updateStatus({ isApproved: false })}
                disabled={updating}
                className="bg-hold/10 text-hold text-sm font-medium rounded-md px-4 py-2 hover:bg-hold/20 disabled:opacity-50 transition-colors"
              >
                Revoke approval
              </button>
            )}
            {driver.userId?.isBlocked ? (
              <button
                onClick={() => updateStatus({ isBlocked: false })}
                disabled={updating}
                className="border border-line text-sm rounded-md px-4 py-2 hover:border-signal transition-colors"
              >
                Unblock account
              </button>
            ) : (
              <button
                onClick={() => updateStatus({ isBlocked: true })}
                disabled={updating}
                className="bg-stop/10 text-stop text-sm font-medium rounded-md px-4 py-2 hover:bg-stop/20 disabled:opacity-50 transition-colors"
              >
                Block account
              </button>
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
                <div className="flex justify-between"><span className="text-mist">Rating</span><span>{driver.rating?.toFixed(1) ?? '—'} ★</span></div>
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

          <div className="bg-panel border border-line rounded-lg p-4">
            <span className="eyebrow">KYC documents</span>
            <div className="grid sm:grid-cols-2 gap-2 mt-3">
              {documentEntries.map(([key, label]) => (
                <a
                  key={key}
                  href={resolveDocUrl(driver.documents[key])}
                  target="_blank"
                  rel="noreferrer"
                  className="flex items-center justify-between px-3 py-2.5 border border-line rounded-md hover:border-signal transition-colors text-sm"
                >
                  <span>{label}</span>
                  <span className="text-signal text-xs">View →</span>
                </a>
              ))}
              {missingDocuments.map(([key, label]) => (
                <div key={key} className="flex items-center justify-between px-3 py-2.5 border border-dashed border-line rounded-md text-sm opacity-50">
                  <span>{label}</span>
                  <span className="text-xs text-mist">Not uploaded</span>
                </div>
              ))}
            </div>
            {documentEntries.length === 0 && (
              <p className="text-xs text-mist mt-3">No documents uploaded yet — this driver cannot be approved until KYC is complete.</p>
            )}
          </div>
        </>
      )}
    </ConsoleShell>
  );
}
