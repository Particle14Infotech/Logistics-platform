import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

export default function EnterpriseApiKeysPage() {
  const [maskedKey, setMaskedKey] = useState(null);
  const [hasKey, setHasKey] = useState(false);
  const [freshKey, setFreshKey] = useState(''); // shown only right after regeneration
  const [loading, setLoading] = useState(true);
  const [regenerating, setRegenerating] = useState(false);
  const [error, setError] = useState('');
  const [copied, setCopied] = useState(false);

  const fetchKey = async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/enterprise/api-key');
      setMaskedKey(data.data.apiKey);
      setHasKey(data.data.hasKey);
    } catch (err) {
      console.error('[EnterpriseApiKeysPage] failed to load api key', err);
      setError(err.response?.data?.message || 'Could not load API key status.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchKey(); }, []);

  const handleRegenerate = async () => {
    if (hasKey && !window.confirm('This will invalidate the existing key immediately. Continue?')) return;
    setRegenerating(true);
    setError('');
    try {
      const { data } = await axiosClient.post('/enterprise/api-key/regenerate');
      setFreshKey(data.data.apiKey);
      await fetchKey();
    } catch (err) {
      console.error('[EnterpriseApiKeysPage] regenerate failed', err);
      setError(err.response?.data?.message || 'Could not regenerate API key.');
    } finally {
      setRegenerating(false);
    }
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(freshKey);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/enterprise/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Integrations</span>
        <h1 className="font-display text-2xl font-semibold mt-1">API access</h1>
        <p className="text-mist text-sm mt-1">Use this key to integrate bulk booking and order tracking directly from your systems.</p>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {freshKey && (
        <div className="border border-hold/30 bg-hold/10 rounded-lg p-4 space-y-2">
          <p className="text-hold text-sm font-medium">Copy this key now — it will not be shown again.</p>
          <div className="flex items-center gap-2">
            <code className="flex-1 bg-ink border border-line rounded-md px-3 py-2 text-xs font-mono break-all">{freshKey}</code>
            <button onClick={handleCopy} className="text-xs px-3 py-2 border border-line rounded-md hover:border-signal transition-colors whitespace-nowrap">
              {copied ? 'Copied ✓' : 'Copy'}
            </button>
          </div>
        </div>
      )}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading…</div>
      ) : (
        <div className="bg-panel border border-line rounded-lg p-4 flex items-center justify-between flex-wrap gap-3">
          <div>
            <span className="eyebrow block mb-1">Current key</span>
            {hasKey ? (
              <code className="text-sm font-mono">{maskedKey}</code>
            ) : (
              <span className="text-sm text-mist">No API key generated yet.</span>
            )}
          </div>
          <button
            onClick={handleRegenerate}
            disabled={regenerating}
            className="bg-signal text-ink text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
          >
            {regenerating ? 'Generating…' : hasKey ? 'Regenerate key' : 'Generate key'}
          </button>
        </div>
      )}
    </ConsoleShell>
  );
}
