import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AdminLoginPage from './admin/dashboard/AdminLoginPage.jsx';
import AdminDashboardPage from './admin/dashboard/AdminDashboardPage.jsx';
import AdminOrdersPage from './admin/orders/AdminOrdersPage.jsx';
import AdminOrderDetailPage from './admin/orders/AdminOrderDetailPage.jsx';
import AdminDriversPage from './admin/drivers/AdminDriversPage.jsx';
import AdminDriverDetailPage from './admin/drivers/AdminDriverDetailPage.jsx';
import AdminVehiclesPage from './admin/vehicles/AdminVehiclesPage.jsx';
import AdminFleetsPage from './admin/fleets/AdminFleetsPage.jsx';
import AdminFleetDetailPage from './admin/fleets/AdminFleetDetailPage.jsx';
import AdminPricingPage from './admin/pricing/AdminPricingPage.jsx';
import AdminPaymentsPage from './admin/payments/AdminPaymentsPage.jsx';
import AdminDisputesPage from './admin/disputes/AdminDisputesPage.jsx';
import AdminEnterprisesPage from './admin/enterprises/AdminEnterprisesPage.jsx';
import AdminContentPage from './admin/content/AdminContentPage.jsx';
import AdminProfilePage from './admin/profile/AdminProfilePage.jsx';
import ProtectedRoute from './shared/routes/ProtectedRoute.jsx';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/login" replace />} />

        {/* --- Public --- */}
        <Route path="/login" element={<AdminLoginPage />} />

        {/* --- Protected, role: admin --- */}
        <Route path="/dashboard" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminDashboardPage /></ProtectedRoute>} />
        <Route path="/orders" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminOrdersPage /></ProtectedRoute>} />
        <Route path="/orders/:id" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminOrderDetailPage /></ProtectedRoute>} />
        <Route path="/drivers" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminDriversPage /></ProtectedRoute>} />
        <Route path="/drivers/:id" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminDriverDetailPage /></ProtectedRoute>} />
        <Route path="/vehicles" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminVehiclesPage /></ProtectedRoute>} />
        <Route path="/fleets" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminFleetsPage /></ProtectedRoute>} />
        <Route path="/fleets/:id" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminFleetDetailPage /></ProtectedRoute>} />
        <Route path="/pricing" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminPricingPage /></ProtectedRoute>} />
        <Route path="/payments" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminPaymentsPage /></ProtectedRoute>} />
        <Route path="/disputes" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminDisputesPage /></ProtectedRoute>} />
        <Route path="/enterprises" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminEnterprisesPage /></ProtectedRoute>} />
        <Route path="/content" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminContentPage /></ProtectedRoute>} />
        <Route path="/profile" element={<ProtectedRoute roles={['admin']} loginPath="/login"><AdminProfilePage /></ProtectedRoute>} />

        {/* Catch-all: any unmatched/stale/bookmarked path (e.g. the old
            /admin/* URLs from before this app was split out) redirects
            instead of rendering a blank page. */}
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
