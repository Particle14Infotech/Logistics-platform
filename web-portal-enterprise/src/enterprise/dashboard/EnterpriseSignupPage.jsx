import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  createUserWithEmailAndPassword,
  sendEmailVerification,
  reload,
} from 'firebase/auth';
import { auth } from '../../firebase.js';
import axiosClient from '../../shared/api/axiosClient.js';
import { useAuthStore } from '../../shared/store/authStore.js';

// Self-service enterprise signup - Firebase owns the password + email
// verification (matching the mobile apps' pattern); once verified, the
// Firebase ID token is exchanged for this app's own JWT session via
// POST /enterprise/firebase-signup, which creates the Enterprise doc
// (or, for a pre-Firebase account using this same email, links the
// existing one instead of duplicating it - see the backend controller).
// Logs the user in immediately and sends them to the pending-approval
// screen (or straight to the dashboard if the linked account was already
// approved) rather than making them wait for an email round-trip here.
export default function EnterpriseSignupPage() {
  const [step, setStep] = useState('form'); // 'form' | 'verifyEmail'
  const [companyName, setCompanyName] = useState('');
  const [contactName, setContactName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [gstin, setGstin] = useState('');
  const [billingEmail, setBillingEmail] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [resendSent, setResendSent] = useState(false);

  const navigate = useNavigate();
  const setAuth = useAuthStore((s) => s.setAuth);
  const setEnterpriseStatus = useAuthStore((s) => s.setEnterpriseStatus);

  const messageFor = (err) => {
    switch (err.code) {
      case 'auth/email-already-in-use':
        return 'An account already exists for that email. Try logging in instead.';
      case 'auth/invalid-email':
        return 'That email address looks invalid.';
      case 'auth/weak-password':
        return 'Choose a stronger password.';
      default:
        return err.message || 'Something went wrong. Try again.';
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!companyName.trim() || !contactName.trim() || !email.trim() || !password) {
      setError('Fill in company name, contact name, email, and password.');
      return;
    }
    if (password.length < 6) {
      setError('Password must be at least 6 characters.');
      return;
    }
    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    setLoading(true);
    setError('');
    try {
      const credential = await createUserWithEmailAndPassword(auth, email.trim(), password);
      await sendEmailVerification(credential.user);
      setStep('verifyEmail');
      setResendSent(false);
    } catch (err) {
      console.error('[EnterpriseSignupPage] signup failed', err);
      setError(err.code ? messageFor(err) : 'Could not create your account. Try again.');
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

      // Usually a fresh signup, so isActive is false and this goes to the
      // pending screen - but firebase-signup can also resolve to an
      // ALREADY-approved existing account (a pre-Firebase/bcrypt enterprise
      // migrating by signing up again with the same email), so check
      // rather than navigating to /pending-approval unconditionally.
      navigate(enterprise.isActive ? '/dashboard' : '/pending-approval', { replace: true });
    } catch (err) {
      console.error('[EnterpriseSignupPage] verification/link failed', err);
      setError(err.response?.data?.message || 'Could not verify your account. Try again.');
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
          <span className="eyebrow">Enterprise portal</span>
          <h1 className="font-display text-4xl font-semibold leading-tight mt-3 max-w-md">
            Set up your business account.
          </h1>
          <p className="text-mist mt-4 max-w-sm text-sm leading-relaxed">
            Sign up now - our team reviews new accounts before contract pricing, credit
            terms, and API access unlock.
          </p>
        </div>

        <div className="flex gap-8 text-xs text-mist">
          <div><span className="text-paper text-lg font-display block">GST</span>compliant billing</div>
          <div><span className="text-paper text-lg font-display block">CSV</span>bulk booking</div>
          <div><span className="text-paper text-lg font-display block">API</span>direct integration</div>
        </div>
      </div>

      {/* Right: form */}
      <div className="flex-1 flex items-center justify-center p-8 overflow-y-auto">
        <div className="w-full max-w-sm py-8">
          {step === 'form' && (
            <form onSubmit={handleSubmit}>
              <h2 className="font-display text-2xl font-semibold mb-1">Create your account</h2>
              <p className="text-mist text-sm mb-8">For new business/enterprise customers.</p>

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

              <label className="block text-xs eyebrow mb-1.5">Email</label>
              <input
                type="email"
                autoComplete="username"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@yourcompany.com"
                className="w-full bg-panel border border-line rounded-md px-3 py-2.5 text-sm mb-4 placeholder:text-mist/60 focus:border-signal focus:outline-none transition-colors"
              />

              <label className="block text-xs eyebrow mb-1.5">Password</label>
              <div className="relative mb-4">
                <input
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="new-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Min 6 characters"
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

              <label className="block text-xs eyebrow mb-1.5">Confirm password</label>
              <input
                type={showPassword ? 'text' : 'password'}
                autoComplete="new-password"
                required
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Re-enter password"
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
                {loading ? 'Creating account…' : 'Create account'}
              </button>

              <p className="text-xs text-mist mt-6 text-center">
                Already have an account?{' '}
                <button type="button" onClick={() => navigate('/login')} className="text-signal hover:underline">
                  Log in
                </button>
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
        </div>
      </div>
    </div>
  );
}
