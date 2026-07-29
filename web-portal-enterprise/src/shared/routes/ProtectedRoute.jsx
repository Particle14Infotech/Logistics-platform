import { Navigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '../store/authStore.js';

/**
 * Wrap a route element with this to require authentication (and optionally
 * a specific role). Redirects to `loginPath`, preserving the attempted
 * location so login can send the user back afterward.
 *
 * Usage: <ProtectedRoute roles={['enterprise_admin']} loginPath="/login"><EnterpriseDashboardPage /></ProtectedRoute>
 */
export default function ProtectedRoute({ children, roles, loginPath = '/login' }) {
  const { accessToken, user, enterpriseStatus } = useAuthStore();
  const location = useLocation();

  if (!accessToken) {
    return <Navigate to={loginPath} replace state={{ from: location }} />;
  }

  if (roles && user && !roles.includes(user.role)) {
    // Authenticated, but wrong portal (e.g. a driver token hitting /admin/*)
    return <Navigate to={loginPath} replace state={{ from: location, reason: 'wrong-role' }} />;
  }

  // A pending (not yet admin-approved) enterprise account can't use any
  // real feature route - redirect there instead. PendingApprovalScreen
  // itself is wrapped in <ProtectedRoute> with no `roles` prop, so this
  // never loops back on itself.
  const isEnterpriseRoute = roles?.some((role) => role.startsWith('enterprise_'));
  if (isEnterpriseRoute && enterpriseStatus && !enterpriseStatus.isActive) {
    return <Navigate to="/pending-approval" replace />;
  }

  return children;
}
