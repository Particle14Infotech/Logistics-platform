import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import axiosClient from '../../shared/api/axiosClient.js';
import { useAuthStore } from '../../shared/store/authStore.js';

// Enterprise now lives in a separately deployed app (web-portal-enterprise)
// at its own origin, not a route inside this app - a plain cross-origin
// link, not client-side routing, is what actually gets there.
const ENTERPRISE_PORTAL_LOGIN_URL = import.meta.env.DEV
  ? 'http://localhost:5176/login'
  : 'https://enterprise.raahmitr.com/login';

// Admin login screen - calls POST /api/v1/auth/login
export default function AdminLoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [debugInfo, setDebugInfo] = useState(null);

  const navigate = useNavigate();
  const location = useLocation();
  const setAuth = useAuthStore((s) => s.setAuth);

  const handleSubmit = async (e) => {
    e.preventDefault();
    console.log('[AdminLoginPage] submit fired', { email, passwordLength: password.length });

    if (!email.trim() || !password) {
      setError('Enter both email and password.');
      return;
    }

    setLoading(true);
    setError('');
    setDebugInfo(null);
    try {
      const { data } = await axiosClient.post('/auth/login', { email: email.trim(), password });
      const { user, accessToken, refreshToken } = data.data;

      if (user.role !== 'admin') {
        setError('This account is not an admin account. Use the enterprise portal instead.');
        setLoading(false);
        return;
      }

      setAuth({ accessToken, refreshToken, user });
      const redirectTo = location.state?.from?.pathname ?? '/dashboard';
      navigate(redirectTo, { replace: true });
    } catch (err) {
      console.error('[AdminLoginPage] login failed', err);
      const message = err.response?.data?.message;
      setError(message || 'Invalid credentials. Check your email and password.');
      setDebugInfo({
        requestUrl: `${axiosClient.defaults.baseURL}/auth/login`,
        requestBody: { email: email.trim(), password: `(${password.length} chars)` },
        responseStatus: err.response?.status ?? 'NO RESPONSE (network error)',
        responseBody: err.response?.data ?? null,
        rawMessage: err.message,
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-ink text-paper font-body">
      {/* Left: brand panel */}
      <div className="hidden lg:flex lg:w-1/2 flex-col justify-between p-12 border-r border-line bg-panel relative overflow-hidden">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded bg-signal flex items-center justify-center">
            <span className="font-display font-bold text-white text-sm">L</span>
          </div>
          <span className="font-display font-semibold tracking-tight">LOGISTICS</span>
        </div>

        <div>
          <span className="eyebrow">Dispatch console</span>
          <h1 className="font-display text-4xl font-semibold leading-tight mt-3 max-w-md">
            Every truck, every order, one screen.
          </h1>
          <p className="text-mist mt-4 max-w-sm text-sm leading-relaxed">
            Monitor bookings, assign drivers, and control pricing across the Pan-India
            network in real time.
          </p>
        </div>

        <div className="flex gap-8 text-xs text-mist">
          <div><span className="text-paper text-lg font-display block">10K+</span>concurrent bookings</div>
          <div><span className="text-paper text-lg font-display block">99.5%</span>API uptime</div>
          <div><span className="text-paper text-lg font-display block">&lt;5s</span>tracking latency</div>
        </div>
      </div>

      {/* Right: form */}
      <div className="flex-1 flex items-center justify-center p-8">
        <form onSubmit={handleSubmit} className="w-full max-w-sm">
          <h2 className="font-display text-2xl font-semibold mb-1">Admin sign in</h2>
          <p className="text-mist text-sm mb-8">Ops team access only.</p>

          <label className="block text-xs eyebrow mb-1.5">Email</label>
          <input
            type="email"
            name="email"
            autoComplete="username"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@particle14.com"
            className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-4 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
          />

          <label className="block text-xs eyebrow mb-1.5">Password</label>
          <div className="relative mb-2">
            <input
              type={showPassword ? 'text' : 'password'}
              name="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              className="w-full bg-panel border border-line rounded-md px-3 py-2.5 pr-16 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
            />
            <button
              type="button"
              onClick={() => setShowPassword((v) => !v)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-mist hover:text-signal transition-colors"
            >
              {showPassword ? 'Hide' : 'Show'}
            </button>
          </div>

          <div className="flex justify-end mb-6">
            <button type="button" className="text-xs text-mist hover:text-signal transition-colors">
              Forgot password?
            </button>
          </div>

          {error && <p className="text-stop text-xs mb-4">{error}</p>}

          {debugInfo && (
            <div className="mb-4 p-3 rounded-md border border-line bg-panel text-[11px] font-mono text-mist leading-relaxed break-all">
              <div><span className="text-paper">Called:</span> POST {debugInfo.requestUrl}</div>
              <div><span className="text-paper">Sent:</span> {JSON.stringify(debugInfo.requestBody)}</div>
              <div><span className="text-paper">Status:</span> {debugInfo.responseStatus}</div>
              <div><span className="text-paper">Response:</span> {JSON.stringify(debugInfo.responseBody)}</div>
              {debugInfo.rawMessage && <div><span className="text-paper">Error:</span> {debugInfo.rawMessage}</div>}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-signal text-white font-medium text-sm rounded-md py-2.5 hover:brightness-110 disabled:opacity-60 transition-all"
          >
            {loading ? 'Signing in…' : 'Sign in'}
          </button>

          <p className="text-xs text-mist mt-6 text-center">
            Enterprise client?{' '}
            <a href={ENTERPRISE_PORTAL_LOGIN_URL} className="text-signal hover:underline">
              Go to enterprise portal
            </a>
          </p>

          <p className="text-xs text-mist/60 mt-8 text-center">
            Dev credentials: admin@particle14.com / Admin@12345 (run <code>npm run seed</code>)
          </p>
          <div className="text-center mt-3">
            <button
              type="button"
              onClick={() => {
                setEmail('admin@particle14.com');
                setPassword('Admin@12345');
              }}
              className="text-xs text-signal hover:underline"
            >
              Fill dev credentials
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
