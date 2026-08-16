import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

export default function EnterpriseContractsPage() {
  // Live catalog (not the old hardcoded 5-value list) - /booking/... since
  // this page is reached with an enterprise JWT, not an admin one; already
  // filtered to isActive server-side.
  const [categories, setCategories] = useState([]);
  const [contractPricing, setContractPricing] = useState({});
  const [drafts, setDrafts] = useState({});
  const [loading, setLoading] = useState(true);
  const [savingKey, setSavingKey] = useState(null);
  const [error, setError] = useState('');

  const fetchPricing = async () => {
    setLoading(true);
    setError('');
    try {
      const [{ data: catData }, { data: contractData }] = await Promise.all([
        axiosClient.get('/booking/vehicle-categories'),
        axiosClient.get('/enterprise/contract-pricing'),
      ]);
      setCategories(catData.data.categories);
      setContractPricing(contractData.data.contractPricing);
      const d = {};
      catData.data.categories.forEach((c) => { d[c.vehicleType] = contractData.data.contractPricing[c.vehicleType]?.discountPercent ?? 0; });
      setDrafts(d);
    } catch (err) {
      console.error('[EnterpriseContractsPage] failed to load contract pricing', err);
      setError(err.response?.data?.message || 'Could not load contract pricing.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchPricing(); }, []);

  const handleSave = async (vehicleType) => {
    setSavingKey(vehicleType);
    try {
      await axiosClient.put('/enterprise/contract-pricing', { vehicleType, discountPercent: drafts[vehicleType] });
      await fetchPricing();
    } catch (err) {
      console.error('[EnterpriseContractsPage] save failed', err);
      setError(err.response?.data?.message || 'Could not save discount.');
    } finally {
      setSavingKey(null);
    }
  };

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Billing</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Contract pricing</h1>
        <p className="text-mist text-sm mt-1">Negotiated discount applied on top of standard rates for each vehicle type.</p>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading contract rates…</div>
      ) : (
        <div className="space-y-3">
          {categories.map((c) => {
            const v = c.vehicleType;
            const applied = contractPricing[v]?.discountPercent ?? 0;
            const dirty = drafts[v] !== applied;
            return (
              <div key={v} className="bg-panel border border-line rounded-lg p-4 flex items-center gap-4">
                <span className="text-sm font-medium w-40">{c.name}{c.lengthFt ? ` • ${c.lengthFt}ft` : ''}</span>
                <div className="flex items-center gap-2 flex-1">
                  <input
                    type="number"
                    min={0}
                    max={100}
                    value={drafts[v]}
                    onChange={(e) => setDrafts((d) => ({ ...d, [v]: parseFloat(e.target.value) || 0 }))}
                    className="w-24 bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors"
                  />
                  <span className="text-mist text-sm">% discount</span>
                  {applied > 0 && <span className="text-xs text-go font-mono ml-2">Currently applied: {applied}%</span>}
                </div>
                <button
                  onClick={() => handleSave(v)}
                  disabled={!dirty || savingKey === v}
                  className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-40 transition-all"
                >
                  {savingKey === v ? 'Saving…' : 'Save'}
                </button>
              </div>
            );
          })}
        </div>
      )}
    </ConsoleShell>
  );
}
