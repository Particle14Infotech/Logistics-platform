import { useEffect, useState } from 'react';
import { EmailAuthProvider, reauthenticateWithCredential, updatePassword } from 'firebase/auth';
import { auth } from '../../firebase.js';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { useAuthStore } from '../../shared/store/authStore.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

export default function EnterpriseProfilePage() {
  const user = useAuthStore((s) => s.user);
  const setUser = useAuthStore((s) => s.setUser);

  const [loading, setLoading] = useState(true);
  const [companyName, setCompanyName] = useState('');
  const [form, setForm] = useState({ name: '', email: '', phone: '' });
  const [savingProfile, setSavingProfile] = useState(false);
  const [profileMessage, setProfileMessage] = useState('');
  const [profileError, setProfileError] = useState('');

  const [passwordForm, setPasswordForm] = useState({ currentPassword: '', newPassword: '', confirmPassword: '' });
  const [savingPassword, setSavingPassword] = useState(false);
  const [passwordMessage, setPasswordMessage] = useState('');
  const [passwordError, setPasswordError] = useState('');

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [profileRes, statusRes] = await Promise.all([
          axiosClient.get('/auth/profile'),
          axiosClient.get('/enterprise/status'),
        ]);
        if (cancelled) return;
        const u = profileRes.data.data.user;
        setForm({ name: u.name ?? '', email: u.email ?? '', phone: u.phone ?? '' });
        setCompanyName(statusRes.data.data.companyName ?? '');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, []);

  const handleSaveProfile = async (e) => {
    e.preventDefault();
    setSavingProfile(true);
    setProfileMessage('');
    setProfileError('');
    try {
      const { data } = await axiosClient.put('/auth/profile', form);
      setUser(data.data.user);
      setProfileMessage('Profile updated.');
    } catch (err) {
      setProfileError(err.response?.data?.message || 'Could not update profile.');
    } finally {
      setSavingProfile(false);
    }
  };

  // Firebase owns the password here (this portal's login is Firebase
  // email/password, not this backend) - changing it means reauthenticating
  // with the current password first (Firebase requires a recent sign-in
  // for a sensitive operation like updatePassword) and calling Firebase's
  // own updatePassword, never a backend endpoint.
  const handleChangePassword = async (e) => {
    e.preventDefault();
    setPasswordMessage('');
    setPasswordError('');
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      setPasswordError('New passwords do not match.');
      return;
    }
    if (passwordForm.newPassword.length < 6) {
      setPasswordError('New password must be at least 6 characters.');
      return;
    }
    setSavingPassword(true);
    try {
      const credential = EmailAuthProvider.credential(auth.currentUser.email, passwordForm.currentPassword);
      await reauthenticateWithCredential(auth.currentUser, credential);
      await updatePassword(auth.currentUser, passwordForm.newPassword);
      setPasswordMessage('Password changed.');
      setPasswordForm({ currentPassword: '', newPassword: '', confirmPassword: '' });
    } catch (err) {
      const messages = {
        'auth/wrong-password': 'Current password is incorrect.',
        'auth/invalid-credential': 'Current password is incorrect.',
        'auth/too-many-requests': 'Too many attempts. Try again in a moment.',
      };
      setPasswordError(messages[err.code] || err.message || 'Could not change password.');
    } finally {
      setSavingPassword(false);
    }
  };

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel={companyName || 'Enterprise'} loginPath="/login" dateLabel="25 JUL 2026">
      <div>
        <span className="eyebrow">Account</span>
        <h1 className="font-display text-2xl font-semibold mt-1">My profile</h1>
      </div>

      {loading ? (
        <div className="text-center py-16 text-mist text-sm">Loading…</div>
      ) : (
        <div className="grid lg:grid-cols-2 gap-6 max-w-3xl">
          <form onSubmit={handleSaveProfile} className="bg-panel border border-line rounded-lg p-5 space-y-4">
            <span className="eyebrow">Personal information</span>

            <div>
              <span className="block text-xs eyebrow mb-1.5">Company</span>
              <div className="text-sm">{companyName || '—'}</div>
            </div>
            <div>
              <span className="block text-xs eyebrow mb-1.5">Role</span>
              <div className="text-sm capitalize">{user?.role === 'enterprise_admin' ? 'Admin' : (user?.enterpriseRole ?? '—')}</div>
            </div>

            <div>
              <label className="block text-xs eyebrow mb-1.5">Name</label>
              <input
                type="text"
                value={form.name}
                onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
                className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
              />
            </div>
            <div>
              <label className="block text-xs eyebrow mb-1.5">Email</label>
              <input
                type="email"
                value={form.email}
                onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
                className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
              />
            </div>
            <div>
              <label className="block text-xs eyebrow mb-1.5">Phone</label>
              <input
                type="tel"
                value={form.phone}
                onChange={(e) => setForm((f) => ({ ...f, phone: e.target.value }))}
                className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
              />
            </div>

            {profileError && <p className="text-stop text-xs">{profileError}</p>}
            {profileMessage && <p className="text-go text-xs">{profileMessage}</p>}

            <button
              type="submit"
              disabled={savingProfile}
              className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
            >
              {savingProfile ? 'Saving…' : 'Save changes'}
            </button>
          </form>

          <form onSubmit={handleChangePassword} className="bg-panel border border-line rounded-lg p-5 space-y-4">
            <span className="eyebrow">Change password</span>

            <div>
              <label className="block text-xs eyebrow mb-1.5">Current password</label>
              <input
                type="password"
                autoComplete="current-password"
                required
                value={passwordForm.currentPassword}
                onChange={(e) => setPasswordForm((f) => ({ ...f, currentPassword: e.target.value }))}
                className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
              />
            </div>
            <div>
              <label className="block text-xs eyebrow mb-1.5">New password</label>
              <input
                type="password"
                autoComplete="new-password"
                required
                value={passwordForm.newPassword}
                onChange={(e) => setPasswordForm((f) => ({ ...f, newPassword: e.target.value }))}
                placeholder="Min 6 characters"
                className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
              />
            </div>
            <div>
              <label className="block text-xs eyebrow mb-1.5">Confirm new password</label>
              <input
                type="password"
                autoComplete="new-password"
                required
                value={passwordForm.confirmPassword}
                onChange={(e) => setPasswordForm((f) => ({ ...f, confirmPassword: e.target.value }))}
                className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
              />
            </div>

            {passwordError && <p className="text-stop text-xs">{passwordError}</p>}
            {passwordMessage && <p className="text-go text-xs">{passwordMessage}</p>}

            <button
              type="submit"
              disabled={savingPassword}
              className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
            >
              {savingPassword ? 'Changing…' : 'Change password'}
            </button>
          </form>
        </div>
      )}
    </ConsoleShell>
  );
}
