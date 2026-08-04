import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

const VEHICLE_LABELS = {
  bike: 'Bike',
  auto: 'Auto',
  mini_truck: 'Mini Truck',
  medium_truck: 'Medium Truck',
  large_truck: 'Large Truck',
};

function PricingRow({ config, onSave }) {
  const [form, setForm] = useState({
    baseFare: config.baseFare,
    perKmRate: config.perKmRate,
    perKgRate: config.perKgRate ?? 0,
    surgeMultiplier: config.surgeMultiplier,
    isSurgeActive: config.isSurgeActive,
    advanceRequired: config.advanceRequired ?? false,
    advanceMode: config.advanceMode ?? 'percentage',
    advanceValue: config.advanceValue ?? 30,
    maxWeightKg: config.maxWeightKg ?? 0,
  });
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  const dirty = JSON.stringify(form) !== JSON.stringify({
    baseFare: config.baseFare, perKmRate: config.perKmRate, perKgRate: config.perKgRate ?? 0,
    surgeMultiplier: config.surgeMultiplier, isSurgeActive: config.isSurgeActive,
    advanceRequired: config.advanceRequired ?? false, advanceMode: config.advanceMode ?? 'percentage',
    advanceValue: config.advanceValue ?? 30, maxWeightKg: config.maxWeightKg ?? 0,
  });

  const handleSave = async () => {
    setSaving(true);
    setSaved(false);
    try {
      await onSave(config.vehicleType, form);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } finally {
      setSaving(false);
    }
  };

  const numInput = (key, step = 1) => (
    <input
      type="number"
      step={step}
      value={form[key]}
      onChange={(e) => setForm((f) => ({ ...f, [key]: parseFloat(e.target.value) || 0 }))}
      className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors"
    />
  );

  return (
    <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
      <div className="grid md:grid-cols-7 gap-3 items-end">
        <div>
          <span className="eyebrow block mb-1">Vehicle</span>
          <span className="text-sm font-medium">{VEHICLE_LABELS[config.vehicleType]}</span>
        </div>
        <div>
          <span className="eyebrow block mb-1">Base fare (₹)</span>
          {numInput('baseFare')}
        </div>
        <div>
          <span className="eyebrow block mb-1">Per km (₹)</span>
          {numInput('perKmRate')}
        </div>
        <div>
          <span className="eyebrow block mb-1">Per kg (₹)</span>
          {numInput('perKgRate', 0.1)}
        </div>
        <div>
          <span className="eyebrow block mb-1">Max weight (kg)</span>
          {numInput('maxWeightKg')}
        </div>
        <div>
          <span className="eyebrow block mb-1">Surge ×</span>
          <div className="flex items-center gap-2">
            {numInput('surgeMultiplier', 0.1)}
            <label className="flex items-center gap-1 text-xs text-mist whitespace-nowrap">
              <input
                type="checkbox"
                checked={form.isSurgeActive}
                onChange={(e) => setForm((f) => ({ ...f, isSurgeActive: e.target.checked }))}
              />
              Active
            </label>
          </div>
        </div>
        <div>
          <button
            onClick={handleSave}
            disabled={!dirty || saving}
            className="w-full bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-40 transition-all"
          >
            {saving ? 'Saving…' : saved ? 'Saved ✓' : 'Save'}
          </button>
        </div>
      </div>

      <div className="border-t border-line pt-3 grid md:grid-cols-4 gap-3 items-end">
        <div>
          <label className="flex items-center gap-2 text-xs text-mist whitespace-nowrap">
            <input
              type="checkbox"
              checked={form.advanceRequired}
              onChange={(e) => setForm((f) => ({ ...f, advanceRequired: e.target.checked }))}
            />
            Requires advance payment
          </label>
        </div>
        {form.advanceRequired && (
          <>
            <div>
              <span className="eyebrow block mb-1">Mode</span>
              <select
                value={form.advanceMode}
                onChange={(e) => setForm((f) => ({ ...f, advanceMode: e.target.value }))}
                className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
              >
                <option value="percentage">Percentage</option>
                <option value="fixed">Fixed amount</option>
              </select>
            </div>
            <div>
              <span className="eyebrow block mb-1">{form.advanceMode === 'fixed' ? 'Amount (₹)' : 'Percentage (%)'}</span>
              {numInput('advanceValue', form.advanceMode === 'fixed' ? 1 : 0.5)}
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default function AdminPricingPage() {
  const [pricing, setPricing] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchPricing = async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/admin/pricing');
      setPricing(data.data.pricing);
    } catch (err) {
      console.error('[AdminPricingPage] failed to load pricing', err);
      setError(err.response?.data?.message || 'Could not load pricing config.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPricing();
  }, []);

  const handleSave = async (vehicleType, form) => {
    try {
      await axiosClient.put('/admin/pricing', { vehicleType, ...form });
      await fetchPricing();
    } catch (err) {
      console.error('[AdminPricingPage] failed to save pricing', err);
      setError(err.response?.data?.message || 'Could not save pricing.');
    }
  };

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Revenue</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Pricing engine</h1>
        <p className="text-mist text-sm mt-1">Base fare, distance rate, weight rate, max load weight, surge control, and advance-payment rules per vehicle type.</p>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading pricing…</div>
      ) : (
        <div className="space-y-3">
          {pricing.map((config) => (
            <PricingRow key={config.vehicleType} config={config} onSave={handleSave} />
          ))}
        </div>
      )}
    </ConsoleShell>
  );
}
