import { Navigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '../store/authStore.js';

/**
 * Wrap a route element with this to require authentication (and optionally
 * a specific role). Redirects to `loginPath`, preserving the attempted
 * location so login can send the user back afterward.
 *
 * Usage: <ProtectedRoute roles={['admin']} loginPath="/login"><AdminDashboardPage /></ProtectedRoute>
 */
export default function ProtectedRoute({ children, roles, loginPath = '/login' }) {
  const { accessToken, user } = useAuthStore();
  const location = useLocation();

  if (!accessToken) {
    return <Navigate to={loginPath} replace state={{ from: location }} />;
  }

  if (roles && user && !roles.includes(user.role)) {
    // Authenticated, but wrong portal (e.g. a driver token hitting /*)
    return <Navigate to={loginPath} replace state={{ from: location, reason: 'wrong-role' }} />;
  }

  return children;
}
