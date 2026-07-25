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
import ConsoleShell from './shared/layouts/ConsoleShell.jsx';
import ComingSoonPage from './shared/components/ComingSoonPage.jsx';
import ProtectedRoute from './shared/routes/ProtectedRoute.jsx';
import { ADMIN_NAV } from './admin/adminNav.js';
import { ENTERPRISE_NAV } from './enterprise/enterpriseNav.js';

// Wraps an unbuilt module in the console shell so nav links never 404.
function AdminPlaceholder({ title, note }) {
  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/admin/login" dateLabel="25 JUL 2026">
      <ComingSoonPage title={title} note={note} />
    </ConsoleShell>
  );
}

function EnterprisePlaceholder({ title, note }) {
  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/enterprise/login" dateLabel="25 JUL 2026">
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
        <Route path="/enterprise/bulk-booking" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/enterprise/login"><EnterprisePlaceholder title="Bulk booking" note="CSV upload or manual multi-row form. Wire to POST /enterprise/bulk-booking." /></ProtectedRoute>} />
        <Route path="/enterprise/order-tracking" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/enterprise/login"><EnterprisePlaceholder title="Order tracking" note="Track all company orders in one view, filter by user/status/date." /></ProtectedRoute>} />
        <Route path="/enterprise/users" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/enterprise/login"><EnterprisePlaceholder title="Team & roles" note="Invite sub-users, assign viewer/booker/admin roles, spending limits." /></ProtectedRoute>} />
        <Route path="/enterprise/invoices" element={<ProtectedRoute roles={['enterprise_admin', 'enterprise_user']} loginPath="/enterprise/login"><EnterprisePlaceholder title="Invoices" note="Full invoice history with itemized PDF downloads." /></ProtectedRoute>} />
        <Route path="/enterprise/contracts" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/enterprise/login"><EnterprisePlaceholder title="Contract pricing" note="Custom negotiated rate cards per vehicle type/route." /></ProtectedRoute>} />
        <Route path="/enterprise/api-keys" element={<ProtectedRoute roles={['enterprise_admin']} loginPath="/enterprise/login"><EnterprisePlaceholder title="API access" note="Enterprise API key management for direct system integration." /></ProtectedRoute>} />
      </Routes>
    </BrowserRouter>
  );
}
