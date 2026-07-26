import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AdminLoginPage from './admin/dashboard/AdminLoginPage.jsx';
import AdminDashboardPage from './admin/dashboard/AdminDashboardPage.jsx';
import AdminOrdersPage from './admin/orders/AdminOrdersPage.jsx';
import AdminOrderDetailPage from './admin/orders/AdminOrderDetailPage.jsx';
import AdminDriversPage from './admin/drivers/AdminDriversPage.jsx';
import AdminDriverDetailPage from './admin/drivers/AdminDriverDetailPage.jsx';
import AdminVehiclesPage from './admin/vehicles/AdminVehiclesPage.jsx';
import AdminPricingPage from './admin/pricing/AdminPricingPage.jsx';
import AdminPaymentsPage from './admin/payments/AdminPaymentsPage.jsx';
import AdminDisputesPage from './admin/disputes/AdminDisputesPage.jsx';
import EnterpriseLoginPage from './enterprise/dashboard/EnterpriseLoginPage.jsx';
import EnterpriseDashboardPage from './enterprise/dashboard/EnterpriseDashboardPage.jsx';
import EnterpriseBulkBookingPage from './enterprise/bulk-booking/EnterpriseBulkBookingPage.jsx';
import EnterpriseOrderTrackingPage from './enterprise/order-tracking/EnterpriseOrderTrackingPage.jsx';
import EnterpriseUsersPage from './enterprise/users/EnterpriseUsersPage.jsx';
import EnterpriseInvoicesPage from './enterprise/invoices/EnterpriseInvoicesPage.jsx';
import EnterpriseContractsPage from './enterprise/contracts/EnterpriseContractsPage.jsx';
import EnterpriseApiKeysPage from './enterprise/api-keys/EnterpriseApiKeysPage.jsx';
import ConsoleShell from './shared/layouts/ConsoleShell.jsx';
import ComingSoonPage from './shared/components/ComingSoonPage.jsx';
import ProtectedRoute from './shared/routes/ProtectedRoute.jsx';
import { ADMIN_NAV } from './admin/adminNav.js';

// Wraps an unbuilt module in the console shell so nav links never 404.
function AdminPlaceholder({ title, note }) {
  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/admin/login" dateLabel="25 JUL 2026">
      <ComingSoonPage title={title} note={note} />
    </ConsoleShell>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/admin/login" replace />} />

        {/* --- Public --- */}
        <Route path="/admin/login" element={<AdminLoginPage />} />
        <Route path="/enterprise/login" element={<EnterpriseLoginPage />} />

        {/* --- Admin (protected, role: admin) --- */}
        <Route path="/admin/dashboard" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminDashboardPage /></ProtectedRoute>} />
        <Route path="/admin/orders" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminOrdersPage /></ProtectedRoute>} />
        <Route path="/admin/orders/:id" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminOrderDetailPage /></ProtectedRoute>} />
        <Route path="/admin/drivers" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminDriversPage /></ProtectedRoute>} />
        <Route path="/admin/drivers/:id" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminDriverDetailPage /></ProtectedRoute>} />
        <Route path="/admin/vehicles" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminVehiclesPage /></ProtectedRoute>} />
        <Route path="/admin/pricing" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminPricingPage /></ProtectedRoute>} />
        <Route path="/admin/payments" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminPaymentsPage /></ProtectedRoute>} />
        <Route path="/admin/disputes" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminDisputesPage /></ProtectedRoute>} />
        <Route path="/admin/content" element={<ProtectedRoute roles={['admin']} loginPath="/admin/login"><AdminPlaceholder title="Content management" note="Promo banners, FAQs, in-app notification copy." /></ProtectedRoute>} />

        {/* --- Enterprise (protected, role: enterprise_admin | enterprise_user) --- */}
        <Route path="/enterprise/dashboard" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/enterprise/login"><EnterpriseDashboardPage /></ProtectedRoute>} />
        <Route path="/enterprise/bulk-booking" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/enterprise/login"><EnterpriseBulkBookingPage /></ProtectedRoute>} />
        <Route path="/enterprise/order-tracking" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/enterprise/login"><EnterpriseOrderTrackingPage /></ProtectedRoute>} />
        <Route path="/enterprise/users" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/enterprise/login"><EnterpriseUsersPage /></ProtectedRoute>} />
        <Route path="/enterprise/invoices" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/enterprise/login"><EnterpriseInvoicesPage /></ProtectedRoute>} />
        <Route path="/enterprise/contracts" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/enterprise/login"><EnterpriseContractsPage /></ProtectedRoute>} />
        <Route path="/enterprise/api-keys" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/enterprise/login"><EnterpriseApiKeysPage /></ProtectedRoute>} />
      </Routes>
    </BrowserRouter>
  );
}
