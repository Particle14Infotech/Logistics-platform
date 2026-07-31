import { useEffect, useState } from 'react';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

export default function EnterpriseUsersPage() {
  const [admin, setAdmin] = useState(null);
  const [subUsers, setSubUsers] = useState([]);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [inviting, setInviting] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [inviteError, setInviteError] = useState('');
  const [inviteSuccess, setInviteSuccess] = useState('');

  const fetchUsers = async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get('/enterprise/users');
      setAdmin(data.data.admin);
      setSubUsers(data.data.subUsers);
    } catch (err) {
      console.error('[EnterpriseUsersPage] failed to load users', err);
      setError(err.response?.data?.message || 'Could not load team members.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchUsers(); }, []);

  const handleInvite = async (e) => {
    e.preventDefault();
    setInviting(true);
    setInviteError('');
    setInviteSuccess('');
    try {
      await axiosClient.post('/enterprise/users/invite', { name, email });
      setInviteSuccess(`${name} added to the team.`);
      setName('');
      setEmail('');
      await fetchUsers();
    } catch (err) {
      console.error('[EnterpriseUsersPage] invite failed', err);
      setInviteError(err.response?.data?.message || 'Could not add team member.');
    } finally {
      setInviting(false);
    }
  };

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Account</span>
        <h1 className="font-display text-2xl font-semibold mt-1">Team & roles</h1>
      </div>

      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      <form onSubmit={handleInvite} className="bg-panel border border-line rounded-lg p-4 flex flex-wrap gap-3 items-end">
        <div className="flex-1 min-w-[160px]">
          <span className="eyebrow block mb-1">Name</span>
          <input value={name} onChange={(e) => setName(e.target.value)} required className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
        </div>
        <div className="flex-1 min-w-[200px]">
          <span className="eyebrow block mb-1">Email</span>
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
        </div>
        <button type="submit" disabled={inviting} className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all">
          {inviting ? 'Adding…' : 'Add team member'}
        </button>
      </form>
      {inviteError && <p className="text-stop text-xs">{inviteError}</p>}
      {inviteSuccess && <p className="text-go text-xs">{inviteSuccess}</p>}

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading team…</div>
      ) : (
        <div className="bg-panel border border-line rounded-lg divide-y divide-line">
          {admin && (
            <div className="p-4 flex items-center justify-between">
              <div>
                <div className="text-sm font-medium">{admin.name}</div>
                <div className="text-xs text-mist">{admin.email}</div>
              </div>
              <span className="text-xs px-2 py-0.5 rounded bg-signal/10 text-signal font-mono">Admin</span>
            </div>
          )}
          {subUsers.map((u) => (
            <div key={u._id} className="p-4 flex items-center justify-between">
              <div>
                <div className="text-sm font-medium">{u.name}</div>
                <div className="text-xs text-mist">{u.email}{!u.email && u.phone}</div>
              </div>
              <span className="text-xs px-2 py-0.5 rounded bg-panel2 text-mist font-mono">Team member</span>
            </div>
          ))}
          {subUsers.length === 0 && <div className="p-4 text-center text-mist text-sm">No team members added yet.</div>}
        </div>
      )}
    </ConsoleShell>
  );
}
