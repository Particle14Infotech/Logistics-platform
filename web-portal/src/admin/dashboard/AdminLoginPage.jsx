// Admin login screen - calls POST /api/v1/auth/login
export default function AdminLoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-100">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-sm">
        <h1 className="text-xl font-semibold mb-4">Admin Login</h1>
        {/* TODO: build login form, call axiosClient.post('/auth/login', {...}) */}
      </div>
    </div>
  );
}
