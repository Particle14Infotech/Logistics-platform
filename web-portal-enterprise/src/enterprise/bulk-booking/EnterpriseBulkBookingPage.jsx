import { useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import PlacesAutocompleteInput from '../../shared/components/PlacesAutocompleteInput.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { useAuthStore } from '../../shared/store/authStore.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

const VEHICLE_OPTIONS = ['bike', 'auto', 'mini_truck', 'medium_truck', 'large_truck'];
const emptyRow = () => ({ pickupAddress: '', dropAddress: '', vehicleType: 'mini_truck', goodsType: '', weightKg: '' });

export default function EnterpriseBulkBookingPage() {
  const [rows, setRows] = useState([emptyRow(), emptyRow(), emptyRow()]);
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState('');
  const user = useAuthStore((s) => s.user);
  // Viewer role can see everything else (tracking/invoices) but not create
  // bulk bookings - only meaningful for enterprise_user, enterprise_admin
  // is never a viewer.
  const isViewer = user?.role === 'enterprise_user' && user?.enterpriseRole === 'viewer';

  const updateRow = (index, field, value) => {
    setRows((prev) => prev.map((r, i) => (i === index ? { ...r, [field]: value } : r)));
  };

  const addRow = () => setRows((prev) => [...prev, emptyRow()]);
  const removeRow = (index) => setRows((prev) => prev.filter((_, i) => i !== index));

  const handleSubmit = async () => {
    setSubmitting(true);
    setError('');
    setResult(null);
    try {
      const validRows = rows.filter((r) => r.pickupAddress && r.dropAddress);
      if (validRows.length === 0) {
        setError('Fill in at least one row with a pickup and drop address.');
        setSubmitting(false);
        return;
      }
      const { data } = await axiosClient.post('/enterprise/bulk-booking', { rows: validRows });
      setResult(data.data);
      if (data.data.failed === 0) setRows([emptyRow(), emptyRow(), emptyRow()]);
    } catch (err) {
      console.error('[EnterpriseBulkBookingPage] submit failed', err);
      setError(err.response?.data?.message || 'Could not submit bulk booking.');
    } finally {
      setSubmitting(false);
    }
  };

  if (isViewer) {
    return (
      <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
        <div>
          <span className="eyebrow">Booking</span>
          <h1 className="font-display text-2xl font-semibold mt-1">Bulk booking</h1>
        </div>
        <div className="border border-line bg-panel text-mist text-sm rounded-lg p-6 text-center">
          Your account has Viewer access - only Managers can create bulk bookings. Ask your admin to change your role under Team & roles if you need this.
        </div>
      </ConsoleShell>
    );
  }

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Booking</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Bulk booking</h1>
        <p className="text-mist text-sm mt-1">Add multiple shipments in one submission. Each row becomes a separate order.</p>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {result && (
        <div className={`border rounded-lg p-4 text-sm ${result.failed > 0 ? 'border-hold/30 bg-hold/10 text-hold' : 'border-go/30 bg-go/10 text-go'}`}>
          <p className="font-medium">{result.created} booking(s) created, {result.failed} failed.</p>
          {result.errors?.length > 0 && (
            <ul className="mt-2 space-y-1 text-xs">
              {result.errors.map((e, i) => <li key={i}>Row {e.row}: {e.reason}</li>)}
            </ul>
          )}
        </div>
      )}

      <div className="space-y-3">
        {rows.map((row, i) => (
          <div key={i} className="bg-panel border border-line rounded-lg p-3 grid md:grid-cols-6 gap-2 items-center">
            <PlacesAutocompleteInput
              placeholder="Pickup address"
              value={row.pickupAddress}
              onChange={(v) => updateRow(i, 'pickupAddress', v)}
              onPlaceSelected={(details) => {
                updateRow(i, 'pickupLat', details.lat);
                updateRow(i, 'pickupLng', details.lng);
              }}
              containerClassName="md:col-span-1"
              className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
            />
            <PlacesAutocompleteInput
              placeholder="Drop address"
              value={row.dropAddress}
              onChange={(v) => updateRow(i, 'dropAddress', v)}
              onPlaceSelected={(details) => {
                updateRow(i, 'dropLat', details.lat);
                updateRow(i, 'dropLng', details.lng);
              }}
              containerClassName="md:col-span-1"
              className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
            />
            <select
              value={row.vehicleType}
              onChange={(e) => updateRow(i, 'vehicleType', e.target.value)}
              className="bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
            >
              {VEHICLE_OPTIONS.map((v) => <option key={v} value={v}>{v.replace('_', ' ')}</option>)}
            </select>
            <input
              placeholder="Goods type"
              value={row.goodsType}
              onChange={(e) => updateRow(i, 'goodsType', e.target.value)}
              className="bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
            />
            <input
              type="number"
              placeholder="Weight (kg)"
              value={row.weightKg}
              onChange={(e) => updateRow(i, 'weightKg', e.target.value)}
              className="bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
            />
            <button onClick={() => removeRow(i)} className="text-xs text-mist hover:text-stop transition-colors">Remove row</button>
          </div>
        ))}
      </div>

      <div className="flex gap-3">
        <button onClick={addRow} className="text-sm border border-line rounded-md px-4 py-2 hover:border-signal transition-colors">
          + Add row
        </button>
        <button
          onClick={handleSubmit}
          disabled={submitting}
          className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
        >
          {submitting ? 'Submitting…' : 'Submit bulk booking'}
        </button>
      </div>
    </ConsoleShell>
  );
}
