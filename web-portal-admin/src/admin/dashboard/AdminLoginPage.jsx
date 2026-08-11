import { useState, useRef } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { RecaptchaVerifier, signInWithPhoneNumber } from 'firebase/auth';
import { auth as firebaseAuth } from '../../firebase.js';
import axiosClient from '../../shared/api/axiosClient.js';
import { useAuthStore } from '../../shared/store/authStore.js';

// Enterprise now lives in a separately deployed app (web-portal-enterprise)
// at its own origin, not a route inside this app - a plain cross-origin
// link, not client-side routing, is what actually gets there.
const ENTERPRISE_PORTAL_LOGIN_URL = import.meta.env.DEV
  ? 'http://localhost:5176/login'
  : 'https://enterprise.raahmitr.com/login';

// Admin login screen - password calls POST /api/v1/auth/login (bcrypt,
// unrelated to Firebase); email OTP and phone OTP are two independent
// alternatives alongside it, not replacements.
export default function AdminLoginPage() {
  const [method, setMethod] = useState('password'); // 'password' | 'emailOtp' | 'phoneOtp'
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Passwordless email OTP - handled entirely by our own backend
  // (SendGrid), no Firebase involved for this one.
  const [emailOtpSent, setEmailOtpSent] = useState(false);
  const [emailOtpCode, setEmailOtpCode] = useState('');

  // Phone/SMS OTP - Firebase Web SDK sends and verifies the code itself
  // (invisible reCAPTCHA instead of the Play Integrity check the mobile
  // apps get, since there's no app-signing key on the web) - no separate
  // SMS gateway/DLT registration needed here either.
  const [phone, setPhone] = useState('');
  const [phoneOtpSent, setPhoneOtpSent] = useState(false);
  const [phoneOtpCode, setPhoneOtpCode] = useState('');
  const recaptchaVerifierRef = useRef(null);
  const confirmationResultRef = useRef(null);

  const navigate = useNavigate();
  const location = useLocation();
  const setAuth = useAuthStore((s) => s.setAuth);

  // Shared by all three methods once each has produced a real backend JWT
  // session - the role check matters most here since firebase-session and
  // portal/verify-otp both gate on role server-side too, but a clear
  // client-side message beats a generic failure.
  const finishSession = ({ user, accessToken, refreshToken }) => {
    if (user.role !== 'admin') {
      setError('This account is not an admin account. Use the enterprise portal instead.');
      return;
    }
    setAuth({ accessToken, refreshToken, user });
    const redirectTo = location.state?.from?.pathname ?? '/dashboard';
    navigate(redirectTo, { replace: true });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!email.trim() || !password) {
      setError('Enter both email and password.');
      return;
    }

    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.post('/auth/login', { email: email.trim(), password });
      finishSession(data.data);
    } catch (err) {
      const message = err.response?.data?.message;
      setError(message || 'Invalid credentials. Check your email and password.');
    } finally {
      setLoading(false);
    }
  };

  const handleRequestEmailOtp = async (e) => {
    e.preventDefault();
    if (!email.trim()) {
      setError('Enter your email.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      await axiosClient.post('/auth/portal/request-otp', { email: email.trim(), appContext: 'admin' });
      setEmailOtpSent(true);
    } catch (err) {
      setError(err.response?.data?.message || 'Could not send the code. Try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyEmailOtp = async (e) => {
    e.preventDefault();
    if (emailOtpCode.trim().length !== 6) {
      setError('Enter the 6-digit code.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.post('/auth/portal/verify-otp', {
        email: email.trim(),
        code: emailOtpCode.trim(),
        appContext: 'admin',
      });
      finishSession(data.data);
    } catch (err) {
      setError(err.response?.data?.message || 'Could not verify that code. Try again.');
    } finally {
      setLoading(false);
    }
  };

  const messageFor = (err) => {
    switch (err.code) {
      case 'auth/invalid-phone-number':
        return 'That phone number looks invalid.';
      case 'auth/code-expired':
        return 'That code expired - request a new one.';
      case 'auth/too-many-requests':
        return 'Too many attempts. Try again in a moment.';
      default:
        return err.message || 'Something went wrong. Try again.';
    }
  };

  // Invisible by default - only renders a visible challenge if Google's
  // risk check actually flags this attempt. Created lazily (once) rather
  // than on every send, since Firebase ties one verifier instance to one
  // underlying reCAPTCHA widget.
  const getRecaptchaVerifier = () => {
    if (!recaptchaVerifierRef.current) {
      recaptchaVerifierRef.current = new RecaptchaVerifier(firebaseAuth, 'recaptcha-container', { size: 'invisible' });
    }
    return recaptchaVerifierRef.current;
  };

  const handleSendPhoneOtp = async (e) => {
    e.preventDefault();
    if (!/^[6-9]\d{9}$/.test(phone.trim())) {
      setError('Enter a valid 10-digit mobile number.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      confirmationResultRef.current = await signInWithPhoneNumber(firebaseAuth, `+91${phone.trim()}`, getRecaptchaVerifier());
      setPhoneOtpSent(true);
    } catch (err) {
      console.error('[AdminLoginPage] sending phone OTP failed', err);
      setError(err.code ? messageFor(err) : 'Could not send the code. Try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyPhoneOtp = async (e) => {
    e.preventDefault();
    if (phoneOtpCode.trim().length !== 6) {
      setError('Enter the 6-digit code.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const credential = await confirmationResultRef.current.confirm(phoneOtpCode.trim());
      const idToken = await credential.user.getIdToken(true);
      const { data } = await axiosClient.post('/auth/firebase-session', { idToken, appContext: 'admin' });
      finishSession(data.data);
    } catch (err) {
      console.error('[AdminLoginPage] verifying phone OTP failed', err);
      setError(err.code ? messageFor(err) : err.response?.data?.message || 'Could not verify that code. Try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-ink text-paper font-body">
      {/* Left: brand panel - the one deliberate glass moment in this portal,
          matching the public website's hero treatment (frosted glass over
          blurred brand-colored blobs). Everything else in this app stays
          the plain dense-data console it needs to be; this panel is pure
          brand, not a place anyone scans a table. */}
      <div className="hidden lg:flex lg:w-1/2 flex-col justify-between p-12 border-r border-line bg-panel/60 backdrop-blur-xl relative overflow-hidden">
        <div className="absolute w-[480px] h-[480px] rounded-full blur-[100px] opacity-25 -top-40 -left-36 bg-signal -z-10" aria-hidden="true" />
        <div className="absolute w-[420px] h-[420px] rounded-full blur-[100px] opacity-20 -bottom-44 -right-32 bg-[#F7B500] -z-10" aria-hidden="true" />

        <div className="relative z-10 flex items-center gap-2">
          <div className="w-8 h-8 rounded bg-signal flex items-center justify-center">
            <span className="font-display font-bold text-white text-sm">R</span>
          </div>
          <span className="font-display font-semibold tracking-tight">RAAH MITR</span>
        </div>

        <div className="relative z-10">
          <span className="eyebrow">Dispatch console</span>
          <h1 className="font-display text-4xl font-semibold leading-tight mt-3 max-w-md">
            Every truck, every order, one screen.
          </h1>
          <p className="text-mist mt-4 max-w-sm text-sm leading-relaxed">
            Monitor bookings, assign drivers, and control pricing across the Pan-India
            network in real time.
          </p>
        </div>

        <div className="relative z-10 flex gap-8 text-xs text-mist">
          <div><span className="text-paper text-lg font-display block">10K+</span>concurrent bookings</div>
          <div><span className="text-paper text-lg font-display block">99.5%</span>API uptime</div>
          <div><span className="text-paper text-lg font-display block">&lt;5s</span>tracking latency</div>
        </div>
      </div>

      {/* Right: form */}
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="w-full max-w-sm">
          {/* Invisible reCAPTCHA mount point for phone OTP - stays in the
              DOM regardless of which method tab is active, since Firebase
              ties one RecaptchaVerifier instance to this exact node. */}
          <div id="recaptcha-container" />

          <h2 className="font-display text-2xl font-semibold mb-1">Admin sign in</h2>
          <p className="text-mist text-sm mb-6">Ops team access only.</p>

          <div className="flex gap-1 bg-panel border border-line rounded-md p-1 mb-6">
            {[
              ['password', 'Password'],
              ['emailOtp', 'Email OTP'],
              ['phoneOtp', 'Phone OTP'],
            ].map(([value, label]) => (
              <button
                key={value}
                type="button"
                onClick={() => {
                  setMethod(value);
                  setError('');
                  setEmailOtpSent(false);
                  setPhoneOtpSent(false);
                }}
                className={`flex-1 text-xs font-medium rounded py-1.5 transition-colors ${
                  method === value ? 'bg-signal text-white' : 'text-mist hover:text-paper'
                }`}
              >
                {label}
              </button>
            ))}
          </div>

          {method === 'password' && (
            <form onSubmit={handleSubmit}>
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

              <div className="flex justify-end mb-4">
                <button type="button" className="text-xs text-mist hover:text-signal transition-colors">
                  Forgot password?
                </button>
              </div>

              {error && <p className="text-stop text-xs mb-4">{error}</p>}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-signal text-white font-medium text-sm rounded-md py-2.5 hover:brightness-110 disabled:opacity-60 transition-all"
              >
                {loading ? 'Signing in…' : 'Sign in'}
              </button>
            </form>
          )}

          {method === 'emailOtp' && (
            <form onSubmit={emailOtpSent ? handleVerifyEmailOtp : handleRequestEmailOtp}>
              <label className="block text-xs eyebrow mb-1.5">Email</label>
              <input
                type="email"
                name="email"
                autoComplete="username"
                required
                disabled={emailOtpSent}
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@particle14.com"
                className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-4 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors disabled:opacity-60"
              />

              {emailOtpSent && (
                <>
                  <label className="block text-xs eyebrow mb-1.5">6-digit code</label>
                  <input
                    type="text"
                    inputMode="numeric"
                    maxLength={6}
                    required
                    value={emailOtpCode}
                    onChange={(e) => setEmailOtpCode(e.target.value)}
                    placeholder="123456"
                    className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-2 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors tracking-widest"
                  />
                  <div className="flex justify-end mb-4">
                    <button type="button" onClick={handleRequestEmailOtp} className="text-xs text-mist hover:text-signal transition-colors">
                      Resend code
                    </button>
                  </div>
                </>
              )}

              {error && <p className="text-stop text-xs mb-4">{error}</p>}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-signal text-white font-medium text-sm rounded-md py-2.5 hover:brightness-110 disabled:opacity-60 transition-all"
              >
                {loading ? 'Please wait…' : emailOtpSent ? 'Verify & sign in' : 'Send code'}
              </button>
            </form>
          )}

          {method === 'phoneOtp' && (
            <form onSubmit={phoneOtpSent ? handleVerifyPhoneOtp : handleSendPhoneOtp}>
              <label className="block text-xs eyebrow mb-1.5">Mobile number</label>
              <div className="flex mb-4">
                <span className="flex items-center px-3 bg-panel border border-r-0 border-line rounded-l-md text-sm text-mist">+91</span>
                <input
                  type="tel"
                  inputMode="numeric"
                  maxLength={10}
                  required
                  disabled={phoneOtpSent}
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="98765 43210"
                  className="w-full bg-panel border border-line rounded-r-md px-3 py-2.5 text-sm placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors disabled:opacity-60"
                />
              </div>

              {phoneOtpSent && (
                <>
                  <label className="block text-xs eyebrow mb-1.5">6-digit code</label>
                  <input
                    type="text"
                    inputMode="numeric"
                    maxLength={6}
                    required
                    value={phoneOtpCode}
                    onChange={(e) => setPhoneOtpCode(e.target.value)}
                    placeholder="123456"
                    className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-2 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors tracking-widest"
                  />
                  <div className="flex justify-end mb-4">
                    <button type="button" onClick={handleSendPhoneOtp} className="text-xs text-mist hover:text-signal transition-colors">
                      Resend code
                    </button>
                  </div>
                </>
              )}

              {error && <p className="text-stop text-xs mb-4">{error}</p>}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-signal text-white font-medium text-sm rounded-md py-2.5 hover:brightness-110 disabled:opacity-60 transition-all"
              >
                {loading ? 'Please wait…' : phoneOtpSent ? 'Verify & sign in' : 'Send OTP'}
              </button>
            </form>
          )}

          <p className="text-xs text-mist mt-6 text-center">
            Enterprise client?{' '}
            <a href={ENTERPRISE_PORTAL_LOGIN_URL} className="text-signal hover:underline">
              Go to enterprise portal
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}
