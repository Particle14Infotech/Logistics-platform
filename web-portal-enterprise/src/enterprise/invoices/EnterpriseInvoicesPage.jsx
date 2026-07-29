import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import DataTable from '../../shared/components/DataTable.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { downloadFile } from '../../shared/utils/downloadFile.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

export default function EnterpriseInvoicesPage() {
  const [invoices, setInvoices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [downloadingId, setDownloadingId] = useState(null);

  useEffect(() => {
    async function load() {
      setLoading(true);
      setError('');
      try {
        const { data } = await axiosClient.get('/enterprise/invoices');
        setInvoices(data.data.invoices);
      } catch (err) {
        console.error('[EnterpriseInvoicesPage] failed to load invoices', err);
        setError(err.response?.data?.message || 'Could not load invoices.');
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  const handleDownload = async (invoiceId) => {
    setDownloadingId(invoiceId);
    try {
      await downloadFile(`/invoices/${invoiceId}/pdf`, `invoice-${invoiceId.slice(-8)}.pdf`);
    } catch (err) {
      console.error('[EnterpriseInvoicesPage] download failed', err);
      setError('Could not download this invoice.');
    } finally {
      setDownloadingId(null);
    }
  };

  const columns = [
    { key: 'id', label: 'Invoice', render: (r) => <span className="font-mono text-xs">INV-{r._id.slice(-8).toUpperCase()}</span> },
    { key: 'period', label: 'Billing period', render: (r) => `${new Date(r.periodStart).toLocaleDateString('en-IN')} - ${new Date(r.periodEnd).toLocaleDateString('en-IN')}` },
    { key: 'orders', label: 'Shipments', render: (r) => r.orderIds?.length ?? 0 },
    { key: 'subtotal', label: 'Subtotal', render: (r) => <span className="font-mono">₹{r.subtotal.toLocaleString('en-IN')}</span> },
    { key: 'gst', label: 'GST (18%)', render: (r) => <span className="font-mono">₹{r.gstAmount.toLocaleString('en-IN')}</span> },
    { key: 'total', label: 'Total', render: (r) => <span className="font-mono font-medium">₹{r.totalAmount.toLocaleString('en-IN')}</span> },
    { key: 'status', label: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    {
      key: 'action',
      label: '',
      render: (r) => (
        <button
          onClick={() => handleDownload(r._id)}
          disabled={downloadingId === r._id}
          className="text-xs text-signal hover:underline disabled:opacity-50"
        >
          {downloadingId === r._id ? 'Downloading…' : 'Download PDF'}
        </button>
      ),
    },
  ];

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Billing</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Invoices</h1>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading invoices…</div>
      ) : (
        <DataTable columns={columns} rows={invoices} keyField="_id" />
      )}
    </ConsoleShell>
  );
}
