import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  signInWithEmailAndPassword,
  sendPasswordResetEmail,
  sendEmailVerification,
  reload,
} from 'firebase/auth';
import { auth } from '../../firebase.js';
import axiosClient from '../../shared/api/axiosClient.js';
import { useAuthStore } from '../../shared/store/authStore.js';

// Admin now lives in a separately deployed app (web-portal-admin) at its
// own origin, not a route inside this app - a plain cross-origin link, not
// client-side routing, is what actually gets there.
const ADMIN_PORTAL_LOGIN_URL = import.meta.env.DEV
  ? 'http://localhost:5174/login'
  : 'https://raahmitr.com/login';

// Enterprise login - Firebase owns the credential + email verification
// state (matching the mobile apps' pattern); this backend never sees the
// password. Once Firebase confirms sign-in, the Firebase ID token is
// exchanged for this app's own JWT session via POST /auth/firebase-session
// (the same generic endpoint the mobile apps use), so everything
// downstream (ProtectedRoute, the pending-approval gate) is unchanged.
export default function EnterpriseLoginPage() {
  const [step, setStep] = useState('login'); // 'login' | 'verifyEmail' | 'completeProfile'
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [resendSent, setResendSent] = useState(false);
  // Recovery path for an account that verified its email/signed in via
  // Firebase but never finished POST /enterprise/firebase-signup (e.g. hit
  // "email already in use" on the Signup page after an earlier interrupted
  // attempt, then came here to log in instead) - firebase-signup creates
  // the missing Enterprise doc from these instead of leaving the account
  // permanently stuck with no company profile and no way to add one.
  const [companyName, setCompanyName] = useState('');
  const [contactName, setContactName] = useState('');
  const [gstin, setGstin] = useState('');
  const [billingEmail, setBillingEmail] = useState('');

  const navigate = useNavigate();
  const location = useLocation();
  const setAuth = useAuthStore((s) => s.setAuth);
  const setEnterpriseStatus = useAuthStore((s) => s.setEnterpriseStatus);

  const messageFor = (err) => {
    switch (err.code) {
      case 'auth/user-not-found':
      case 'auth/invalid-credential':
      case 'auth/wrong-password':
        return "No account found with that email/password. If you're migrating an older account, use Sign Up once with this email first.";
      case 'auth/too-many-requests':
        return 'Too many attempts. Try again in a moment.';
      case 'auth/invalid-email':
        return 'That email address looks invalid.';
      default:
        return err.message || 'Something went wrong. Try again.';
    }
  };

  const syncSessionAndContinue = async (user) => {
    const idToken = await user.getIdToken(true);
    const { data } = await axiosClient.post('/auth/firebase-session', { idToken, appContext: 'enterprise' });
    const { user: sessionUser, accessToken, refreshToken } = data.data;
    setAuth({ accessToken, refreshToken, user: sessionUser });

    // Pending accounts (self-signup awaiting admin approval) get sent to a
    // dedicated screen instead of the real dashboard.
    let statusData;
    try {
      ({ data: statusData } = await axiosClient.get('/enterprise/status'));
    } catch (err) {
      if (err.response?.status === 404) {
        setStep('completeProfile');
        return;
      }
      throw err;
    }
    setEnterpriseStatus(statusData.data);

    if (!statusData.data.isActive) {
      navigate('/pending-approval', { replace: true });
      return;
    }
    const redirectTo = location.state?.from?.pathname ?? '/dashboard';
    navigate(redirectTo, { replace: true });
  };

  const handleCompleteProfile = async (e) => {
    e.preventDefault();
    if (!companyName.trim() || !contactName.trim()) {
      setError('Fill in company name and contact name.');
      return;
    }

    setLoading(true);
    setError('');
    try {
      const idToken = await auth.currentUser.getIdToken(true);
      const { data } = await axiosClient.post('/enterprise/firebase-signup', {
        idToken,
        companyName: companyName.trim(),
        contactName: contactName.trim(),
        gstin: gstin.trim() || undefined,
        billingEmail: billingEmail.trim() || undefined,
      });
      const { user, accessToken, refreshToken, enterprise } = data.data;
      setAuth({ accessToken, refreshToken, user });
      setEnterpriseStatus({ companyName: enterprise.companyName, isActive: enterprise.isActive });
      navigate(enterprise.isActive ? '/dashboard' : '/pending-approval', { replace: true });
    } catch (err) {
      console.error('[EnterpriseLoginPage] completing profile failed', err);
      setError(err.response?.data?.message || 'Could not complete your account. Try again.');
    } finally {
      setLoading(false);
    }
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
      const credential = await signInWithEmailAndPassword(auth, email.trim(), password);
      if (!credential.user.emailVerified) {
        setStep('verifyEmail');
        setResendSent(false);
        return;
      }
      await syncSessionAndContinue(credential.user);
    } catch (err) {
      console.error('[EnterpriseLoginPage] login failed', err);
      setError(err.code ? messageFor(err) : err.response?.data?.message || 'Could not log in. Try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckVerified = async () => {
    setLoading(true);
    setError('');
    try {
      await reload(auth.currentUser);
      if (!auth.currentUser.emailVerified) {
        setError('Not verified yet - tap the link in the email we sent you.');
        return;
      }
      await syncSessionAndContinue(auth.currentUser);
    } catch (err) {
      console.error('[EnterpriseLoginPage] verification check failed', err);
      setError('Could not check verification status. Try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    try {
      await sendEmailVerification(auth.currentUser);
      setResendSent(true);
    } catch (err) {
      setError('Could not resend the email. Try again.');
    }
  };

  const handleForgotPassword = async () => {
    if (!email.trim()) {
      setError('Enter your email above first, then tap "Forgot password?".');
      return;
    }
    try {
      await sendPasswordResetEmail(auth, email.trim());
      setError('');
      alert(`Password reset link sent to ${email.trim()}`);
    } catch (err) {
      setError(messageFor(err));
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
          <span className="eyebrow">Enterprise portal</span>
          <h1 className="font-display text-4xl font-semibold leading-tight mt-3 max-w-md">
            Your shipments, invoices, and team — in one account.
          </h1>
          <p className="text-mist mt-4 max-w-sm text-sm leading-relaxed">
            Bulk-book deliveries, track spend, and manage your team's access across the
            Pan-India network.
          </p>
        </div>

        <div className="relative z-10 flex gap-8 text-xs text-mist">
          <div><span className="text-paper text-lg font-display block">GST</span>compliant billing</div>
          <div><span className="text-paper text-lg font-display block">CSV</span>bulk booking</div>
          <div><span className="text-paper text-lg font-display block">API</span>direct integration</div>
        </div>
      </div>

      {/* Right: form */}
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="w-full max-w-sm">
          {step === 'login' && (
            <form onSubmit={handleSubmit}>
              <h2 className="font-display text-2xl font-semibold mb-1">Enterprise sign in</h2>
              <p className="text-mist text-sm mb-8">For registered business accounts.</p>

              <label className="block text-xs eyebrow mb-1.5">Email</label>
              <input
                type="email"
                name="email"
                autoComplete="username"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@yourcompany.com"
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
                <button type="button" onClick={handleForgotPassword} className="text-xs text-mist hover:text-signal transition-colors">
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

              <p className="text-xs text-mist mt-6 text-center">
                New business account?{' '}
                <button type="button" onClick={() => navigate('/signup')} className="text-signal hover:underline">
                  Sign up
                </button>
              </p>

              <p className="text-xs text-mist mt-2 text-center">
                Ops team member?{' '}
                <a href={ADMIN_PORTAL_LOGIN_URL} className="text-signal hover:underline">
                  Go to admin console
                </a>
              </p>
            </form>
          )}

          {step === 'verifyEmail' && (
            <div>
              <h2 className="font-display text-2xl font-semibold mb-1">Verify Your Email</h2>
              <p className="text-mist text-sm mb-8">
                We've sent a verification link to<br />{email.trim()}
              </p>
              <button
                type="button"
                onClick={handleCheckVerified}
                disabled={loading}
                className="w-full bg-signal text-white font-medium text-sm rounded-md py-2.5 hover:brightness-110 disabled:opacity-60 transition-all"
              >
                {loading ? 'Checking…' : "I've verified my email"}
              </button>
              <div className="text-center mt-4">
                <button type="button" onClick={handleResend} className="text-xs text-mist hover:text-signal transition-colors">
                  {resendSent ? 'Verification email sent again' : 'Resend verification email'}
                </button>
              </div>
              {error && <p className="text-stop text-xs mt-4">{error}</p>}
            </div>
          )}

          {step === 'completeProfile' && (
            <form onSubmit={handleCompleteProfile}>
              <h2 className="font-display text-2xl font-semibold mb-1">Finish setting up your account</h2>
              <p className="text-mist text-sm mb-8">
                Your email is verified, but we're missing your company details.
              </p>

              <label className="block text-xs eyebrow mb-1.5">Company name</label>
              <input
                type="text"
                required
                value={companyName}
                onChange={(e) => setCompanyName(e.target.value)}
                placeholder="Vertex Pharma Pvt. Ltd."
                className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-4 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
              />

              <label className="block text-xs eyebrow mb-1.5">Contact name</label>
              <input
                type="text"
                required
                value={contactName}
                onChange={(e) => setContactName(e.target.value)}
                placeholder="Your full name"
                className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-4 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
              />

              <label className="block text-xs eyebrow mb-1.5">GSTIN (optional)</label>
              <input
                type="text"
                value={gstin}
                onChange={(e) => setGstin(e.target.value)}
                placeholder="22AAAAA0000A1Z5"
                className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-4 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
              />

              <label className="block text-xs eyebrow mb-1.5">Billing email (optional)</label>
              <input
                type="email"
                value={billingEmail}
                onChange={(e) => setBillingEmail(e.target.value)}
                placeholder="Defaults to your login email"
                className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-2 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
              />

              {error && <p className="text-stop text-xs mt-2 mb-4">{error}</p>}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-signal text-white font-medium text-sm rounded-md py-2.5 mt-4 hover:brightness-110 disabled:opacity-60 transition-all"
              >
                {loading ? 'Saving…' : 'Complete setup'}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
