import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

const TABS = [
  { key: 'banners', label: 'Promo banners' },
  { key: 'faqs', label: 'FAQs' },
  { key: 'announcements', label: 'Announcements' },
];

function BannersTab() {
  const [banners, setBanners] = useState([]);
  const [form, setForm] = useState({ title: '', imageUrl: '', linkUrl: '' });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchBanners = async () => {
    setLoading(true);
    try {
      const { data } = await axiosClient.get('/admin/banners');
      setBanners(data.data.banners);
    } catch (err) {
      console.error('[AdminContentPage] failed to load banners', err);
      setError(err.response?.data?.message || 'Could not load banners.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchBanners(); }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    setError('');
    try {
      await axiosClient.post('/admin/banners', form);
      setForm({ title: '', imageUrl: '', linkUrl: '' });
      await fetchBanners();
    } catch (err) {
      setError(err.response?.data?.message || 'Could not create banner.');
    }
  };

  const toggleActive = async (banner) => {
    await axiosClient.put(`/admin/banners/${banner._id}`, { isActive: !banner.isActive });
    await fetchBanners();
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this banner?')) return;
    await axiosClient.delete(`/admin/banners/${id}`);
    await fetchBanners();
  };

  return (
    <div className="space-y-4">
      <form onSubmit={handleCreate} className="bg-panel border border-line rounded-lg p-4 grid md:grid-cols-4 gap-3 items-end">
        <div>
          <span className="eyebrow block mb-1">Title</span>
          <input required value={form.title} onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
        </div>
        <div>
          <span className="eyebrow block mb-1">Image URL</span>
          <input required value={form.imageUrl} onChange={(e) => setForm((f) => ({ ...f, imageUrl: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
        </div>
        <div>
          <span className="eyebrow block mb-1">Link URL (optional)</span>
          <input value={form.linkUrl} onChange={(e) => setForm((f) => ({ ...f, linkUrl: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
        </div>
        <button type="submit" className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 transition-all">Add banner</button>
      </form>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-3">{error}</div>}

      {loading ? (
        <div className="text-center py-12 text-mist text-sm">Loading banners…</div>
      ) : (
        <div className="space-y-2">
          {banners.map((b) => (
            <div key={b._id} className="bg-panel border border-line rounded-lg p-3 flex items-center justify-between gap-3">
              <div>
                <div className="text-sm font-medium">{b.title}</div>
                <div className="text-xs text-mist font-mono break-all">{b.imageUrl}</div>
              </div>
              <div className="flex items-center gap-3 shrink-0">
                <button onClick={() => toggleActive(b)} className={`text-xs px-2 py-1 rounded font-mono ${b.isActive ? 'bg-go/10 text-go' : 'bg-mist/10 text-mist'}`}>
                  {b.isActive ? 'Active' : 'Inactive'}
                </button>
                <button onClick={() => handleDelete(b._id)} className="text-xs text-stop hover:underline">Delete</button>
              </div>
            </div>
          ))}
          {banners.length === 0 && <div className="text-center py-8 text-mist text-sm border border-dashed border-line rounded-lg">No banners yet.</div>}
        </div>
      )}
    </div>
  );
}

function FaqsTab() {
  const [faqs, setFaqs] = useState([]);
  const [form, setForm] = useState({ question: '', answer: '', category: 'general' });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchFaqs = async () => {
    setLoading(true);
    try {
      const { data } = await axiosClient.get('/admin/faqs');
      setFaqs(data.data.faqs);
    } catch (err) {
      console.error('[AdminContentPage] failed to load FAQs', err);
      setError(err.response?.data?.message || 'Could not load FAQs.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchFaqs(); }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    setError('');
    try {
      await axiosClient.post('/admin/faqs', form);
      setForm({ question: '', answer: '', category: 'general' });
      await fetchFaqs();
    } catch (err) {
      setError(err.response?.data?.message || 'Could not create FAQ.');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this FAQ?')) return;
    await axiosClient.delete(`/admin/faqs/${id}`);
    await fetchFaqs();
  };

  return (
    <div className="space-y-4">
      <form onSubmit={handleCreate} className="bg-panel border border-line rounded-lg p-4 space-y-3">
        <input required placeholder="Question" value={form.question} onChange={(e) => setForm((f) => ({ ...f, question: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
        <textarea required placeholder="Answer" rows={2} value={form.answer} onChange={(e) => setForm((f) => ({ ...f, answer: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm resize-none focus:border-signal focus:outline-none transition-colors" />
        <div className="flex justify-end">
          <button type="submit" className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 transition-all">Add FAQ</button>
        </div>
      </form>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-3">{error}</div>}

      {loading ? (
        <div className="text-center py-12 text-mist text-sm">Loading FAQs…</div>
      ) : (
        <div className="space-y-2">
          {faqs.map((f) => (
            <div key={f._id} className="bg-panel border border-line rounded-lg p-3">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <div className="text-sm font-medium">{f.question}</div>
                  <div className="text-xs text-mist mt-1">{f.answer}</div>
                </div>
                <button onClick={() => handleDelete(f._id)} className="text-xs text-stop hover:underline shrink-0">Delete</button>
              </div>
            </div>
          ))}
          {faqs.length === 0 && <div className="text-center py-8 text-mist text-sm border border-dashed border-line rounded-lg">No FAQs yet.</div>}
        </div>
      )}
    </div>
  );
}

function AnnouncementsTab() {
  const [notifications, setNotifications] = useState([]);
  const [form, setForm] = useState({ title: '', body: '', audience: 'all' });
  const [sending, setSending] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const fetchNotifications = async () => {
    setLoading(true);
    try {
      const { data } = await axiosClient.get('/admin/notifications');
      setNotifications(data.data.notifications);
    } catch (err) {
      console.error('[AdminContentPage] failed to load notifications', err);
      setError(err.response?.data?.message || 'Could not load announcement history.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchNotifications(); }, []);

  const handleSend = async (e) => {
    e.preventDefault();
    setSending(true);
    setError('');
    setSuccess('');
    try {
      const { data } = await axiosClient.post('/admin/notifications', form);
      setSuccess(data.message);
      setForm({ title: '', body: '', audience: 'all' });
      await fetchNotifications();
    } catch (err) {
      setError(err.response?.data?.message || 'Could not send announcement.');
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="space-y-4">
      <div className="border border-hold/30 bg-hold/10 text-hold text-xs rounded-lg p-3">
        Announcements are always recorded here and delivered to each recipient's in-app notification inbox. Push delivery to devices additionally requires Firebase to be configured on the backend — if it isn't, recipients will still see the announcement next time they open the app.
      </div>

      <form onSubmit={handleSend} className="bg-panel border border-line rounded-lg p-4 space-y-3">
        <input required placeholder="Title" value={form.title} onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
        <textarea required placeholder="Message body" rows={2} value={form.body} onChange={(e) => setForm((f) => ({ ...f, body: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm resize-none focus:border-signal focus:outline-none transition-colors" />
        <div className="flex items-center justify-between">
          <select value={form.audience} onChange={(e) => setForm((f) => ({ ...f, audience: e.target.value }))} className="bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors">
            <option value="all">All users</option>
            <option value="customer">Customers only</option>
            <option value="driver">Drivers only</option>
          </select>
          <button type="submit" disabled={sending} className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all">
            {sending ? 'Sending…' : 'Send announcement'}
          </button>
        </div>
      </form>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-3">{error}</div>}
      {success && <div className="border border-go/30 bg-go/10 text-go text-sm rounded-lg p-3">{success}</div>}

      {loading ? (
        <div className="text-center py-12 text-mist text-sm">Loading history…</div>
      ) : (
        <div className="space-y-2">
          {notifications.map((n) => (
            <div key={n._id} className="bg-panel border border-line rounded-lg p-3 flex items-start justify-between gap-3">
              <div>
                <div className="text-sm font-medium">{n.title}</div>
                <div className="text-xs text-mist mt-0.5">{n.body}</div>
                <div className="text-xs text-mist mt-1">{n.recipientCount} recipient(s) · {n.audience} · {new Date(n.createdAt).toLocaleString('en-IN')}</div>
              </div>
              <StatusBadge status={n.status === 'queued' ? 'sent' : n.status} />
            </div>
          ))}
          {notifications.length === 0 && <div className="text-center py-8 text-mist text-sm border border-dashed border-line rounded-lg">No announcements sent yet.</div>}
        </div>
      )}
    </div>
  );
}

export default function AdminContentPage() {
  const [tab, setTab] = useState('banners');

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Marketing</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Content</h1>
      </div>

      <div className="flex gap-2 border-b border-line">
        {TABS.map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={`px-4 py-2 text-sm border-b-2 -mb-px transition-colors ${
              tab === t.key ? 'border-signal text-signal' : 'border-transparent text-mist hover:text-paper'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'banners' && <BannersTab />}
      {tab === 'faqs' && <FaqsTab />}
      {tab === 'announcements' && <AnnouncementsTab />}
    </ConsoleShell>
  );
}
