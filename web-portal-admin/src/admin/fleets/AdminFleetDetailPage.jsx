import { useEffect, useState, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

export default function AdminFleetDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [fleet, setFleet] = useState(null);
  const [vehicles, setVehicles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchFleet = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get(`/admin/fleets/${id}`);
      setFleet(data.data.fleet);
      setVehicles(data.data.vehicles);
    } catch (err) {
      console.error('[AdminFleetDetailPage] failed to load fleet', err);
      setError(err.response?.data?.message || 'Could not load this fleet.');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchFleet();
  }, [fetchFleet]);

  const columns = [
    { key: 'driver', label: 'Driver', render: (r) => r.driver?.name ?? '—' },
    { key: 'phone', label: 'Phone', render: (r) => <span className="font-mono text-xs">{r.driver?.phone ?? '—'}</span> },
    { key: 'vehicleNumber', label: 'Vehicle', render: (r) => <span className="font-mono text-xs">{r.vehicleNumber}</span> },
    { key: 'vehicleType', label: 'Type', render: (r) => <span className="capitalize text-xs">{r.vehicleType.replace('_', ' ')}</span> },
    {
      key: 'kyc',
      label: 'KYC docs',
      render: (r) => (
        <span className={r.missingCompliance.length > 0 ? 'text-hold' : 'text-go'}>
          {r.documentsUploaded}/{r.documentsTotal}
        </span>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      render: (r) =>
        r.isApproved ? (
          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium bg-go/10 text-go">Approved</span>
        ) : (
          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-mono font-medium bg-hold/10 text-hold">Pending review</span>
        ),
    },
  ];

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <button onClick={() => navigate('/fleets')} className="text-sm text-mist hover:text-signal transition-colors">
        ← Back to fleets
      </button>

      {loading && <div className="text-center py-16 text-mist text-sm">Loading fleet…</div>}
      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {fleet && (
        <>
          <div>
            <span className="eyebrow">Fleet</span>
            <h1 className="font-display text-2xl font-semibold mt-1">{fleet.companyName}</h1>
          </div>

          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-panel border border-line rounded-lg p-4">
              <span className="eyebrow">Owner</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Name</span><span>{fleet.ownerId?.name ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Phone</span><span className="font-mono">{fleet.ownerId?.phone ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Email</span><span>{fleet.ownerId?.email ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Joined</span><span>{fleet.ownerId?.createdAt ? new Date(fleet.ownerId.createdAt).toLocaleDateString('en-IN') : '—'}</span></div>
              </div>
            </div>

            <div className="bg-panel border border-line rounded-lg p-4">
              <span className="eyebrow">Summary</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Vehicles</span><span>{vehicles.length}</span></div>
                <div className="flex justify-between"><span className="text-mist">Approved</span><span>{vehicles.filter((v) => v.isApproved).length}</span></div>
                <div className="flex justify-between"><span className="text-mist">Needs attention</span><span>{vehicles.filter((v) => v.missingCompliance.length > 0).length}</span></div>
              </div>
            </div>
          </div>

          <div>
            <span className="eyebrow">Vehicles &amp; drivers</span>
            <div className="mt-2">
              <DataTable columns={columns} rows={vehicles} keyField="_id" onRowClick={(v) => navigate(`/drivers/${v._id}`)} />
            </div>
          </div>
        </>
      )}
    </ConsoleShell>
  );
}
