import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import EnterpriseLoginPage from './enterprise/dashboard/EnterpriseLoginPage.jsx';
import EnterpriseSignupPage from './enterprise/dashboard/EnterpriseSignupPage.jsx';
import PendingApprovalScreen from './enterprise/dashboard/PendingApprovalScreen.jsx';
import EnterpriseDashboardPage from './enterprise/dashboard/EnterpriseDashboardPage.jsx';
import EnterpriseBulkBookingPage from './enterprise/bulk-booking/EnterpriseBulkBookingPage.jsx';
import EnterpriseOrderTrackingPage from './enterprise/order-tracking/EnterpriseOrderTrackingPage.jsx';
import EnterpriseUsersPage from './enterprise/users/EnterpriseUsersPage.jsx';
import EnterpriseInvoicesPage from './enterprise/invoices/EnterpriseInvoicesPage.jsx';
import EnterpriseContractsPage from './enterprise/contracts/EnterpriseContractsPage.jsx';
import EnterpriseApiKeysPage from './enterprise/api-keys/EnterpriseApiKeysPage.jsx';
import ProtectedRoute from './shared/routes/ProtectedRoute.jsx';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/login" replace />} />

        {/* --- Public --- */}
        <Route path="/login" element={<EnterpriseLoginPage />} />
        <Route path="/signup" element={<EnterpriseSignupPage />} />

        {/* Reachable while pending approval - deliberately NOT given a
            `roles` prop, so ProtectedRoute's isActive gate (which only
            fires when `roles` is set) can't redirect it back to itself. */}
        <Route path="/pending-approval" element={<ProtectedRoute loginPath="/login"><PendingApprovalScreen /></ProtectedRoute>} />

        {/* --- Protected, role: enterprise_admin | enterprise_user --- */}
        <Route path="/dashboard" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/login"><EnterpriseDashboardPage /></ProtectedRoute>} />
        <Route path="/bulk-booking" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/login"><EnterpriseBulkBookingPage /></ProtectedRoute>} />
        <Route path="/order-tracking" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/login"><EnterpriseOrderTrackingPage /></ProtectedRoute>} />
        <Route path="/users" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/login"><EnterpriseUsersPage /></ProtectedRoute>} />
        <Route path="/invoices" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/login"><EnterpriseInvoicesPage /></ProtectedRoute>} />
        <Route path="/contracts" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/login"><EnterpriseContractsPage /></ProtectedRoute>} />
        <Route path="/api-keys" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/login"><EnterpriseApiKeysPage /></ProtectedRoute>} />

        {/* Catch-all: any unmatched/stale/bookmarked path (e.g. the old
            /enterprise/* URLs from before this app was split out) redirects
            instead of rendering a blank page. */}
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
