import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axiosClient from '../../shared/api/axiosClient.js';
import { useAuthStore } from '../../shared/store/authStore.js';

// Shown to a logged-in enterprise_admin/enterprise_user whose Enterprise
// doc has isActive:false - reachable regardless of approval status (see
// ProtectedRoute.jsx, which redirects every OTHER protected route here
// while pending). enterpriseStatus is a point-in-time snapshot cached at
// login/signup, so "Check again" re-fetches it rather than making the user
// log out and back in just to notice they've been approved.
export default function PendingApprovalScreen() {
  const navigate = useNavigate();
  const companyName = useAuthStore((s) => s.enterpriseStatus?.companyName);
  const clearAuth = useAuthStore((s) => s.clearAuth);
  const setEnterpriseStatus = useAuthStore((s) => s.setEnterpriseStatus);
  const [checking, setChecking] = useState(false);
  const [stillPending, setStillPending] = useState(false);

  const handleSignOut = () => {
    clearAuth();
    navigate('/login', { replace: true });
  };

  const handleCheckAgain = async () => {
    setChecking(true);
    setStillPending(false);
    try {
      const { data } = await axiosClient.get('/enterprise/status');
      setEnterpriseStatus(data.data);
      if (data.data.isActive) {
        navigate('/dashboard', { replace: true });
      } else {
        setStillPending(true);
      }
    } catch (err) {
      console.error('[PendingApprovalScreen] status check failed', err);
    } finally {
      setChecking(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-ink text-paper font-body p-8">
      <div className="w-full max-w-md text-center">
        <div className="w-14 h-14 rounded-full bg-panel border border-line flex items-center justify-center mx-auto mb-6">
          <span className="text-2xl">⏳</span>
        </div>
        <h1 className="font-display text-2xl font-semibold mb-2">Pending approval</h1>
        <p className="text-mist text-sm leading-relaxed mb-1">
          {companyName ? `Your account for ${companyName} is` : 'Your enterprise account is'} awaiting review by
          our team.
        </p>
        <p className="text-mist text-sm leading-relaxed mb-8">
          We'll notify you at your login email once it's approved - bulk booking, invoicing, and
          the rest of the portal unlock automatically after that.
        </p>
        {stillPending && <p className="text-xs text-mist/70 mb-4">Still pending - check back soon.</p>}

        <div className="flex items-center justify-center gap-6">
          <button
            type="button"
            onClick={handleCheckAgain}
            disabled={checking}
            className="text-sm text-signal hover:underline disabled:opacity-60"
          >
            {checking ? 'Checking…' : 'Check again'}
          </button>
          <button
            type="button"
            onClick={handleSignOut}
            className="text-sm text-mist hover:text-signal transition-colors"
          >
            Sign out
          </button>
        </div>
      </div>
    </div>
  );
}
