import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AdminLoginPage from './admin/dashboard/AdminLoginPage.jsx';
import AdminDashboardPage from './admin/dashboard/AdminDashboardPage.jsx';
import EnterpriseDashboardPage from './enterprise/dashboard/EnterpriseDashboardPage.jsx';
import ConsoleShell from './shared/layouts/ConsoleShell.jsx';
import ComingSoonPage from './shared/components/ComingSoonPage.jsx';
import { ADMIN_NAV } from './admin/adminNav.js';
import { ENTERPRISE_NAV } from './enterprise/enterpriseNav.js';

// Wraps an unbuilt module in the console shell so nav links never 404.
function AdminPlaceholder({ title, note }) {
  return (
    <ConsoleShell
      navItems={ADMIN_NAV}
      brandSuffix="ADMIN"
      footerLabel="Neeraj Kumar · Ops Admin"
      userName="Neeraj Kumar"
      userRole="Operations Admin"
      dateLabel="25 JUL 2026"
    >
      <ComingSoonPage title={title} note={note} />
    </ConsoleShell>
  );
}

function EnterprisePlaceholder({ title, note }) {
  return (
    <ConsoleShell
      navItems={ENTERPRISE_NAV}
      brandSuffix="ENTERPRISE"
      footerLabel="Vertex Pharma · Enterprise Admin"
      userName="Priya Sharma"
      userRole="Enterprise Admin"
      dateLabel="25 JUL 2026"
    >
      <ComingSoonPage title={title} note={note} />
    </ConsoleShell>
  );
}

// TODO: wrap protected routes with an auth guard once auth store is wired up
export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/admin/login" replace />} />
        <Route path="/admin/login" element={<AdminLoginPage />} />
        <Route path="/admin/dashboard" element={<AdminDashboardPage />} />
        <Route path="/admin/orders" element={<AdminPlaceholder title="Order management" note="Full orders table with filters, manual driver reassignment. Wire to GET /admin/orders." />} />
        <Route path="/admin/drivers" element={<AdminPlaceholder title="Driver management" note="Onboard/suspend drivers, live location, performance scores. Wire to GET /admin/drivers." />} />
        <Route path="/admin/vehicles" element={<AdminPlaceholder title="Vehicle management" note="Vehicle inventory by type, availability, maintenance alerts." />} />
        <Route path="/admin/pricing" element={<AdminPlaceholder title="Pricing engine" note="Base fares, per-km rates, surge pricing per city/vehicle. Wire to PUT /admin/pricing." />} />
        <Route path="/admin/payments" element={<AdminPlaceholder title="Payment management" note="Transaction monitoring, refund processing, wallet management." />} />
        <Route path="/admin/disputes" element={<AdminPlaceholder title="Dispute management" note="Raise, track, and resolve customer/driver disputes." />} />
        <Route path="/admin/content" element={<AdminPlaceholder title="Content management" note="Promo banners, FAQs, in-app notification copy." />} />

        <Route path="/enterprise/dashboard" element={<EnterpriseDashboardPage />} />
        <Route path="/enterprise/bulk-booking" element={<EnterprisePlaceholder title="Bulk booking" note="CSV upload or manual multi-row form. Wire to POST /enterprise/bulk-booking." />} />
        <Route path="/enterprise/order-tracking" element={<EnterprisePlaceholder title="Order tracking" note="Track all company orders in one view, filter by user/status/date." />} />
        <Route path="/enterprise/users" element={<EnterprisePlaceholder title="Team & roles" note="Invite sub-users, assign viewer/booker/admin roles, spending limits." />} />
        <Route path="/enterprise/invoices" element={<EnterprisePlaceholder title="Invoices" note="Full invoice history with itemized PDF downloads." />} />
        <Route path="/enterprise/contracts" element={<EnterprisePlaceholder title="Contract pricing" note="Custom negotiated rate cards per vehicle type/route." />} />
        <Route path="/enterprise/api-keys" element={<EnterprisePlaceholder title="API access" note="Enterprise API key management for direct system integration." />} />
      </Routes>
    </BrowserRouter>
  );
}
