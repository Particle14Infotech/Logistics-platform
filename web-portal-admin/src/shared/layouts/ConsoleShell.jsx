import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Sidebar from './Sidebar.jsx';
import Topbar from './Topbar.jsx';
import { useAuthStore } from '../store/authStore.js';

/**
 * Shared console layout for both Admin and Enterprise portals.
 * Pulls the signed-in user from the auth store by default; explicit
 * userName/userRole props (used by pre-login mock states) still override it.
 */
export default function ConsoleShell({
  navItems,
  brandSuffix,
  footerLabel,
  userName,
  userRole,
  dateLabel,
  loginPath = '/login',
  children,
}) {
  const navigate = useNavigate();
  const { user, clearAuth } = useAuthStore();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  const handleSignOut = () => {
    clearAuth();
    navigate(loginPath, { replace: true });
  };

  const displayName = userName ?? user?.name ?? 'User';
  const displayRole = userRole ?? user?.role ?? '';

  return (
    <div className="min-h-screen flex bg-ink text-paper font-body">
      <Sidebar
        items={navItems}
        brandSuffix={brandSuffix}
        footerLabel={footerLabel}
        onSignOut={handleSignOut}
        mobileOpen={mobileNavOpen}
        onClose={() => setMobileNavOpen(false)}
      />
      <div className="flex-1 flex flex-col min-w-0">
        <Topbar userName={displayName} userRole={displayRole} dateLabel={dateLabel} onMenuClick={() => setMobileNavOpen(true)} />
        <main className="flex-1 p-4 sm:p-6 space-y-8 max-w-[1400px] w-full mx-auto">{children}</main>
      </div>
    </div>
  );
}
