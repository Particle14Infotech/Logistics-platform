import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AdminLoginPage from './admin/dashboard/AdminLoginPage.jsx';
import AdminDashboardPage from './admin/dashboard/AdminDashboardPage.jsx';
import EnterpriseDashboardPage from './enterprise/dashboard/EnterpriseDashboardPage.jsx';

// TODO: wrap protected routes with an auth guard once auth store is wired up
export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/admin/login" replace />} />
        <Route path="/admin/login" element={<AdminLoginPage />} />
        <Route path="/admin/dashboard" element={<AdminDashboardPage />} />
        <Route path="/enterprise/dashboard" element={<EnterpriseDashboardPage />} />
      </Routes>
    </BrowserRouter>
  );
}
