import { useState } from 'react';
// import axiosClient from '../../shared/api/axiosClient.js';
// import { useNavigate } from 'react-router-dom';

// Admin login screen - calls POST /api/v1/auth/login
export default function AdminLoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      // const { data } = await axiosClient.post('/auth/login', { email, password });
      // localStorage.setItem('accessToken', data.data.accessToken);
      // navigate('/admin/dashboard');
      // TODO: wire once backend auth.controller.login is implemented end-to-end
      await new Promise((r) => setTimeout(r, 600));
    } catch (err) {
      setError('Invalid credentials. Check your email and password.');
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
            <span className="font-display font-bold text-ink text-sm">L</span>
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

        <div className="flex gap-8 font-mono text-xs text-mist">
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
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@particle14.com"
            className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-4 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
          />

          <label className="block text-xs eyebrow mb-1.5">Password</label>
          <input
            type="password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-2 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
          />

          <div className="flex justify-end mb-6">
            <button type="button" className="text-xs text-mist hover:text-signal transition-colors">
              Forgot password?
            </button>
          </div>

          {error && <p className="text-stop text-xs mb-4 font-mono">{error}</p>}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-signal text-ink font-medium text-sm rounded-md py-2.5 hover:brightness-110 disabled:opacity-60 transition-all"
          >
            {loading ? 'Signing in…' : 'Sign in'}
          </button>

          <p className="text-xs text-mist mt-6 text-center">
            Enterprise client?{' '}
            <a href="/enterprise/dashboard" className="text-signal hover:underline">
              Go to enterprise portal
            </a>
          </p>
        </form>
      </div>
    </div>
  );
}
