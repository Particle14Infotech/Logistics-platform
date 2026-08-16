import { useEffect, useState, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { downloadFile, downloadFileFromUrl } from '../../shared/utils/downloadFile.js';
import { ADMIN_NAV } from '../adminNav.js';

// field = key on Driver.documents (what the API response uses), type =
// the :documentType route param backend/src/constants/driverDocumentTypes.js
// maps back to that same field - needed here since the update endpoint is
// keyed by the short param, not the schema field name.
const DOCUMENT_FIELDS = [
  { field: 'licenseUrl', type: 'license', label: 'Driving License (Front)' },
  { field: 'licenseBackUrl', type: 'license_back', label: 'Driving License (Back)' },
  { field: 'rcUrl', type: 'rc', label: 'Vehicle RC (Front)' },
  { field: 'rcBackUrl', type: 'rc_back', label: 'Vehicle RC (Back)' },
  { field: 'aadhaarUrl', type: 'aadhaar', label: 'Aadhaar Card (Front)' },
  { field: 'aadhaarBackUrl', type: 'aadhaar_back', label: 'Aadhaar Card (Back)' },
  { field: 'photoUrl', type: 'photo', label: 'Photo ID' },
  { field: 'insuranceUrl', type: 'insurance', label: 'Insurance' },
  { field: 'permitUrl', type: 'permit', label: 'Permit' },
  { field: 'pollutionCertUrl', type: 'pollution', label: 'Pollution certificate' },
  { field: 'panCardUrl', type: 'pan', label: 'PAN card' },
  { field: 'chequeUrl', type: 'cheque', label: 'Cancelled Cheque' },
];

// Uploaded documents (e.g. a driver's selfie from the mobile app) are stored
// as relative paths like '/uploads/xyz.jpg', served by the backend, not this
// web app - so they need the backend's origin prepended. Seed/demo documents
// are already-absolute https:// URLs and pass through unchanged.
const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1';
const BACKEND_ORIGIN = API_BASE.replace(/\/api\/v1\/?$/, '');
function resolveDocUrl(url) {
  return url.startsWith('/') ? `${BACKEND_ORIGIN}${url}` : url;
}

const WALLET_TYPE_LABELS = {
  trip_earning: 'Trip fare',
  cancellation_compensation: 'Cancellation compensation',
  payout: 'Payout',
  adjustment: 'Adjustment',
};

export default function AdminDriverDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [driver, setDriver] = useState(null);
  const [stats, setStats] = useState(null);
  const [wallet, setWallet] = useState(null);
  const [report, setReport] = useState(null);
  const [reportError, setReportError] = useState('');
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [payingOut, setPayingOut] = useState(false);
  const [downloadingReport, setDownloadingReport] = useState(false);
  const [error, setError] = useState('');
  const [actionError, setActionError] = useState('');
  // Live catalog - used both to show a real category name for the current
  // vehicleType and to populate the edit picker below.
  const [categories, setCategories] = useState([]);
  const [editingVehicle, setEditingVehicle] = useState(false);
  const [vehicleForm, setVehicleForm] = useState({ vehicleType: '', vehicleNumber: '' });
  const [savingVehicle, setSavingVehicle] = useState(false);
  const [vehicleError, setVehicleError] = useState('');

  useEffect(() => {
    axiosClient.get('/admin/vehicle-categories').then(({ data }) => setCategories(data.data.categories)).catch((err) => {
      console.error('[AdminDriverDetailPage] failed to load vehicle categories', err);
    });
  }, []);

  // Keyed by documentType (e.g. 'license') rather than one shared boolean -
  // uploading a replacement for one document shouldn't disable every other
  // document's own upload/replace button while it's in flight.
  const [uploadingDoc, setUploadingDoc] = useState(null);
  const [docError, setDocError] = useState('');

  const fetchDriver = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const [{ data }, { data: walletData }] = await Promise.all([
        axiosClient.get(`/admin/drivers/${id}`),
        axiosClient.get(`/admin/drivers/${id}/wallet`),
      ]);
      setDriver(data.data.driver);
      setStats(data.data.stats);
      setWallet(walletData.data);
    } catch (err) {
      console.error('[AdminDriverDetailPage] failed to load driver', err);
      setError(err.response?.data?.message || 'Could not load this driver.');
    } finally {
      setLoading(false);
    }
  }, [id]);

  // Full trip + financial history (every order, every wallet transaction) -
  // deliberately a separate call from fetchDriver above, since the wallet
  // widget only ever needed the last 10 transactions and this can be a much
  // larger payload for a long-tenured driver. Loaded eagerly anyway (not
  // behind a click) so "everything about this driver" is on the page by
  // default, matching the ask - the PDF button just exports the same data.
  const fetchReport = useCallback(async () => {
    setReportError('');
    try {
      const { data } = await axiosClient.get(`/admin/drivers/${id}/report`);
      setReport(data.data);
    } catch (err) {
      console.error('[AdminDriverDetailPage] failed to load report', err);
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
      await downloadFile(`/admin/drivers/${id}/report/pdf`, `${name}-report.pdf`);
    } catch (err) {
      console.error('[AdminDriverDetailPage] report PDF download failed', err);
      setReportError(err.response?.data?.message || 'Could not download the report.');
    } finally {
      setDownloadingReport(false);
    }
  };

  const processPayout = async () => {
    if (!window.confirm(`Mark ₹${wallet?.balance ?? 0} as paid out to this driver? Only do this after actually transferring the money via their bank details.`)) return;
    setPayingOut(true);
    setActionError('');
    try {
      await axiosClient.post(`/admin/drivers/${id}/payout`);
      await fetchDriver();
    } catch (err) {
      console.error('[AdminDriverDetailPage] payout failed', err);
      setActionError(err.response?.data?.message || 'Could not process payout.');
    } finally {
      setPayingOut(false);
    }
  };

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

  // Lets ops correct a driver's registered vehicle from the portal - e.g.
  // the driver picked the wrong category at signup, or their category was
  // since renamed/deleted by another admin. Same PUT /admin/drivers/:id
  // endpoint updateStatus above uses, just with different fields - doesn't
  // reset isApproved (see that endpoint's own comment for why).
  const startEditVehicle = () => {
    setVehicleForm({ vehicleType: driver.vehicleType, vehicleNumber: driver.vehicleNumber });
    setVehicleError('');
    setEditingVehicle(true);
  };

  const saveVehicle = async () => {
    setSavingVehicle(true);
    setVehicleError('');
    try {
      await axiosClient.put(`/admin/drivers/${id}`, vehicleForm);
      setEditingVehicle(false);
      await fetchDriver();
    } catch (err) {
      console.error('[AdminDriverDetailPage] vehicle update failed', err);
      setVehicleError(err.response?.data?.message || 'Could not update this vehicle.');
    } finally {
      setSavingVehicle(false);
    }
  };

  // Uploads/replaces one KYC document - same endpoint and behavior whether
  // the slot was previously empty or already had a file, so "Upload" and
  // "Replace" below are just different labels on the same handler.
  const handleDocumentFile = async (documentType, file) => {
    if (!file) return;
    setUploadingDoc(documentType);
    setDocError('');
    try {
      const formData = new FormData();
      formData.append('file', file);
      await axiosClient.put(`/admin/drivers/${id}/documents/${documentType}`, formData);
      await fetchDriver();
    } catch (err) {
      console.error('[AdminDriverDetailPage] document upload failed', err);
      setDocError(err.response?.data?.message || 'Could not upload that document.');
    } finally {
      setUploadingDoc(null);
    }
  };

  const handleDownloadDoc = async (doc) => {
    setDocError('');
    try {
      const ext = driver.documents[doc.field].split('.').pop().split('?')[0];
      const name = (driver.userId?.name || 'driver').replace(/[^a-z0-9]+/gi, '-').toLowerCase();
      await downloadFileFromUrl(resolveDocUrl(driver.documents[doc.field]), `${name}-${doc.type}.${ext}`);
    } catch (err) {
      console.error('[AdminDriverDetailPage] document download failed', err);
      setDocError('Could not download that document.');
    }
  };

  const documentEntries = driver ? DOCUMENT_FIELDS.filter((d) => driver.documents?.[d.field]) : [];
  const missingDocuments = driver ? DOCUMENT_FIELDS.filter((d) => !driver.documents?.[d.field]) : [];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
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
              <div className="flex items-center justify-between">
                <span className="eyebrow">Vehicle</span>
                {!editingVehicle && (
                  <button onClick={startEditVehicle} className="text-signal text-xs hover:underline">Edit</button>
                )}
              </div>
              {editingVehicle ? (
                <div className="space-y-2 mt-2">
                  <div>
                    <span className="eyebrow block mb-1">Number</span>
                    <input
                      type="text"
                      value={vehicleForm.vehicleNumber}
                      onChange={(e) => setVehicleForm((f) => ({ ...f, vehicleNumber: e.target.value }))}
                      className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors"
                    />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">Category</span>
                    <select
                      value={vehicleForm.vehicleType}
                      onChange={(e) => setVehicleForm((f) => ({ ...f, vehicleType: e.target.value }))}
                      className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
                    >
                      {!categories.some((c) => c.vehicleType === driver.vehicleType) && (
                        <option value={driver.vehicleType}>{driver.vehicleType} (current - not in active catalog)</option>
                      )}
                      {Object.entries(
                        categories.reduce((groups, c) => {
                          (groups[c.bodyType] ??= []).push(c);
                          return groups;
                        }, {})
                      ).map(([bodyType, group]) => (
                        <optgroup key={bodyType} label={bodyType} className="capitalize">
                          {group.map((c) => (
                            <option key={c.vehicleType} value={c.vehicleType}>{c.name}{c.lengthFt ? ` • ${c.lengthFt}ft` : ''}</option>
                          ))}
                        </optgroup>
                      ))}
                    </select>
                  </div>
                  {vehicleError && <p className="text-xs text-stop">{vehicleError}</p>}
                  <div className="flex gap-2 pt-1">
                    <button
                      onClick={saveVehicle}
                      disabled={savingVehicle}
                      className="bg-signal text-white text-xs font-medium rounded-md px-3 py-1.5 hover:brightness-110 disabled:opacity-40 transition-all"
                    >
                      {savingVehicle ? 'Saving…' : 'Save'}
                    </button>
                    <button
                      onClick={() => setEditingVehicle(false)}
                      disabled={savingVehicle}
                      className="border border-line text-xs rounded-md px-3 py-1.5 hover:border-signal transition-colors"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              ) : (
                <div className="text-sm space-y-1.5 mt-2">
                  <div className="flex justify-between"><span className="text-mist">Number</span><span className="font-mono">{driver.vehicleNumber}</span></div>
                  <div className="flex justify-between"><span className="text-mist">Type</span><span className="capitalize">{categories.find((c) => c.vehicleType === driver.vehicleType)?.name ?? driver.vehicleType.replace(/_/g, ' ')}</span></div>
                  <div className="flex justify-between"><span className="text-mist">License no.</span><span className="font-mono">{driver.licenseNumber}</span></div>
                </div>
              )}
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

          {wallet && (
            <div className="bg-panel border border-line rounded-lg p-4">
              <div className="flex items-center justify-between flex-wrap gap-2">
                <div>
                  <span className="eyebrow">Wallet</span>
                  <div className="text-2xl font-display font-semibold mt-1">₹{wallet.balance}</div>
                </div>
                <button
                  onClick={processPayout}
                  disabled={payingOut || !(wallet.balance > 0)}
                  className="bg-go/10 text-go text-sm font-medium rounded-md px-4 py-2 hover:bg-go/20 disabled:opacity-40 transition-colors"
                >
                  {payingOut ? 'Processing…' : 'Mark as paid out'}
                </button>
              </div>
              {wallet.transactions.length > 0 && (
                <div className="mt-4 space-y-1.5">
                  {wallet.transactions.slice(0, 10).map((t) => (
                    <div key={t._id} className="flex justify-between text-sm py-1.5 border-b border-line last:border-0">
                      <div>
                        <div>{WALLET_TYPE_LABELS[t.type] ?? t.type}</div>
                        <div className="text-xs text-mist">{new Date(t.createdAt).toLocaleDateString('en-IN')}{t.note ? ` · ${t.note}` : ''}</div>
                      </div>
                      <span className={t.amount >= 0 ? 'text-go' : 'text-stop'}>
                        {t.amount >= 0 ? '+' : '-'}₹{Math.abs(t.amount)}
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          <div className="bg-panel border border-line rounded-lg p-4">
            <div className="flex items-center justify-between">
              <span className="eyebrow">KYC documents</span>
              <span className="text-xs text-mist">View, download, or replace any document below.</span>
            </div>
            {docError && <p className="text-xs text-stop mt-2">{docError}</p>}
            <div className="grid sm:grid-cols-2 gap-2 mt-3">
              {documentEntries.map((doc) => (
                <div
                  key={doc.field}
                  className="flex items-center justify-between gap-2 px-3 py-2.5 border border-line rounded-md text-sm"
                >
                  <span className="truncate">{doc.label}</span>
                  <div className="flex items-center gap-3 shrink-0">
                    <a
                      href={resolveDocUrl(driver.documents[doc.field])}
                      target="_blank"
                      rel="noreferrer"
                      className="text-signal text-xs hover:underline"
                    >
                      View
                    </a>
                    <button onClick={() => handleDownloadDoc(doc)} className="text-signal text-xs hover:underline">
                      Download
                    </button>
                    <label className="text-xs text-mist hover:text-signal cursor-pointer transition-colors">
                      {uploadingDoc === doc.type ? 'Uploading…' : 'Replace'}
                      <input
                        type="file"
                        accept="image/*"
                        className="hidden"
                        disabled={uploadingDoc === doc.type}
                        onChange={(e) => {
                          const file = e.target.files?.[0];
                          e.target.value = '';
                          handleDocumentFile(doc.type, file);
                        }}
                      />
                    </label>
                  </div>
                </div>
              ))}
              {missingDocuments.map((doc) => (
                <div
                  key={doc.field}
                  className="flex items-center justify-between gap-2 px-3 py-2.5 border border-dashed border-line rounded-md text-sm"
                >
                  <span className="truncate text-mist">{doc.label}</span>
                  <label className="text-xs text-signal hover:underline cursor-pointer shrink-0">
                    {uploadingDoc === doc.type ? 'Uploading…' : 'Upload'}
                    <input
                      type="file"
                      accept="image/*"
                      className="hidden"
                      disabled={uploadingDoc === doc.type}
                      onChange={(e) => {
                        const file = e.target.files?.[0];
                        e.target.value = '';
                        handleDocumentFile(doc.type, file);
                      }}
                    />
                  </label>
                </div>
              ))}
            </div>
            {documentEntries.length === 0 && (
              <p className="text-xs text-mist mt-3">No documents uploaded yet — this driver cannot be approved until KYC is complete.</p>
            )}
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
                    onRowClick={(row) => navigate(`/orders/${row._id}`)}
                    columns={[
                      { key: 'date', label: 'Date', render: (o) => new Date(o.createdAt).toLocaleDateString('en-IN') },
                      { key: 'id', label: 'Order', render: (o) => <span className="font-mono">{o._id.slice(-8).toUpperCase()}</span> },
                      { key: 'route', label: 'Route', render: (o) => `${o.pickupLocation?.address ?? '—'} → ${o.dropLocation?.address ?? '—'}` },
                      { key: 'status', label: 'Status', render: (o) => <StatusBadge status={o.status} /> },
                      { key: 'price', label: 'Price', render: (o) => `₹${o.price}` },
                      { key: 'payment', label: 'Payment', render: (o) => (o.paymentMethod === 'cod' ? 'COD' : 'Online') },
                      { key: 'customer', label: 'Customer', render: (o) => o.enterpriseId?.companyName ?? o.customerId?.name ?? '—' },
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
