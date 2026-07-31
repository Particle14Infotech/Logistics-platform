import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

// Drivers who registered with this enterprise's invite code (Driver.
// enterpriseId) - a dedicated private fleet, not the public marketplace.
// Mirrors EnterpriseApiKeysPage.jsx's fetch/regenerate pattern, but the
// code itself isn't secret (unlike the API key) - it's meant to be handed
// to drivers, so it's always shown in full.
export default function EnterpriseDriversPage() {
  const [inviteCode, setInviteCode] = useState(null);
  const [drivers, setDrivers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [regenerating, setRegenerating] = useState(false);
  const [error, setError] = useState('');
  const [copied, setCopied] = useState(false);

  const fetchAll = async () => {
    setLoading(true);
    setError('');
    try {
      const [codeRes, driversRes] = await Promise.all([
        axiosClient.get('/enterprise/driver-invite-code'),
        axiosClient.get('/enterprise/drivers'),
      ]);
      setInviteCode(codeRes.data.data.driverInviteCode);
      setDrivers(driversRes.data.data.drivers);
    } catch (err) {
      console.error('[EnterpriseDriversPage] failed to load', err);
      setError(err.response?.data?.message || 'Could not load your fleet.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchAll(); }, []);

  const handleRegenerate = async () => {
    if (!window.confirm('Drivers who have not yet registered with the current code will need the new one. Already-linked drivers are unaffected. Continue?')) return;
    setRegenerating(true);
    setError('');
    try {
      const { data } = await axiosClient.post('/enterprise/driver-invite-code/regenerate');
      setInviteCode(data.data.driverInviteCode);
    } catch (err) {
      console.error('[EnterpriseDriversPage] regenerate failed', err);
      setError(err.response?.data?.message || 'Could not regenerate the invite code.');
    } finally {
      setRegenerating(false);
    }
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(inviteCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  const driverColumns = [
    { key: 'name', label: 'Driver', render: (r) => r.userId?.name ?? '—' },
    { key: 'phone', label: 'Phone', render: (r) => r.userId?.phone ?? '—' },
    { key: 'vehicleType', label: 'Vehicle', render: (r) => <span className="capitalize">{r.vehicleType.replace('_', ' ')}</span> },
    { key: 'vehicleNumber', label: 'Plate', render: (r) => <span className="font-mono text-xs">{r.vehicleNumber}</span> },
    {
      key: 'status',
      label: 'Status',
      render: (r) => (
        <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${r.isApproved ? 'bg-go/10 text-go' : 'bg-hold/10 text-hold'}`}>
          {r.isApproved ? 'Approved' : 'Pending KYC'}
        </span>
      ),
    },
  ];

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Fleet</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Your drivers</h1>
        <p className="text-mist text-sm mt-1">
          Share the code below with your own drivers when they register in the driver app. Once linked, your bulk-booking
          shipments go only to this fleet - not the public marketplace.
        </p>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading…</div>
      ) : (
        <>
          <div className="bg-panel border border-line rounded-xl shadow-sm p-4 flex items-center justify-between flex-wrap gap-3">
            <div>
              <span className="eyebrow block mb-1">Driver invite code</span>
              <code className="text-lg font-mono font-semibold">{inviteCode}</code>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={handleCopy}
                className="text-xs px-3 py-2 border border-line rounded-md hover:border-signal transition-colors whitespace-nowrap"
              >
                {copied ? 'Copied ✓' : 'Copy code'}
              </button>
              <button
                onClick={handleRegenerate}
                disabled={regenerating}
                className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
              >
                {regenerating ? 'Regenerating…' : 'Regenerate code'}
              </button>
            </div>
          </div>

          <div>
            <span className="eyebrow">{drivers.length} driver{drivers.length === 1 ? '' : 's'} linked</span>
            <div className="mt-2">
              <DataTable columns={driverColumns} rows={drivers} keyField="_id" />
            </div>
          </div>
        </>
      )}
    </ConsoleShell>
  );
}
