import { useState, useRef } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  signInWithEmailAndPassword,
  sendPasswordResetEmail,
  sendEmailVerification,
  reload,
  RecaptchaVerifier,
  signInWithPhoneNumber,
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

// signInWithPhoneNumber's returned promise depends on the invisible
// reCAPTCHA challenge actually resolving - a browser that partitions/
// blocks the storage that handshake needs (seen in testing: Brave) can
// leave it neither resolving nor rejecting, so the "Please wait…" button
// spins forever with no feedback. This turns that into a real, visible
// error after a bounded wait instead.
const withTimeout = (promise, ms, message) =>
  Promise.race([promise, new Promise((_, reject) => setTimeout(() => reject({ code: 'verification-timeout', message }), ms))]);

// Enterprise login - Firebase owns the credential + email verification
// state (matching the mobile apps' pattern); this backend never sees the
// password. Once Firebase confirms sign-in, the Firebase ID token is
// exchanged for this app's own JWT session via POST /auth/firebase-session
// (the same generic endpoint the mobile apps use), so everything
// downstream (ProtectedRoute, the pending-approval gate) is unchanged.
export default function EnterpriseLoginPage() {
  const [step, setStep] = useState('login'); // 'login' | 'verifyEmail' | 'completeProfile'
  const [method, setMethod] = useState('password'); // 'password' | 'emailOtp' | 'phoneOtp'
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

  // Passwordless email OTP - a second, independent way in alongside
  // Firebase email/password, not a replacement. Handled entirely by our
  // own backend (no Firebase involved for this one).
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
      case 'auth/invalid-phone-number':
        return 'That phone number looks invalid.';
      case 'auth/code-expired':
        return 'That code expired - request a new one.';
      default:
        return err.message || 'Something went wrong. Try again.';
    }
  };

  // Shared by every sign-in method once it has produced a real backend JWT
  // session - password/phone both get there via /auth/firebase-session,
  // email OTP via /auth/portal/verify-otp, but everything past that point
  // (pending-approval gate, completeProfile recovery, redirect) is
  // identical regardless of how the person actually signed in.
  const finishSession = async ({ accessToken, refreshToken, user: sessionUser }) => {
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

  const syncSessionAndContinue = async (user) => {
    const idToken = await user.getIdToken(true);
    const { data } = await axiosClient.post('/auth/firebase-session', { idToken, appContext: 'enterprise' });
    await finishSession(data.data);
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
      await axiosClient.post('/auth/portal/request-otp', { email: email.trim(), appContext: 'enterprise' });
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
        appContext: 'enterprise',
      });
      await finishSession(data.data);
    } catch (err) {
      setError(err.response?.data?.message || 'Could not verify that code. Try again.');
    } finally {
      setLoading(false);
    }
  };

  // Invisible by default - only renders a visible challenge if Google's
  // risk check actually flags this attempt, same UX as most reCAPTCHA-
  // gated forms. Created lazily (once) rather than on every send, since
  // Firebase ties one verifier instance to one underlying reCAPTCHA widget.
  const getRecaptchaVerifier = () => {
    if (!recaptchaVerifierRef.current) {
      recaptchaVerifierRef.current = new RecaptchaVerifier(auth, 'recaptcha-container', { size: 'invisible' });
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
      confirmationResultRef.current = await withTimeout(
        signInWithPhoneNumber(auth, `+91${phone.trim()}`, getRecaptchaVerifier()),
        45000,
        "Couldn't verify this device automatically. Try again, or use email/password instead."
      );
      setPhoneOtpSent(true);
    } catch (err) {
      console.error('[EnterpriseLoginPage] sending phone OTP failed', err);
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
      await syncSessionAndContinue(credential.user);
    } catch (err) {
      console.error('[EnterpriseLoginPage] verifying phone OTP failed', err);
      setError(err.code ? messageFor(err) : err.response?.data?.message || 'Could not verify that code. Try again.');
    } finally {
      setLoading(false);
    }
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
          {/* Invisible reCAPTCHA mount point for phone OTP - stays in the
              DOM regardless of which method tab is active, since Firebase
              ties one RecaptchaVerifier instance to this exact node. */}
          <div id="recaptcha-container" />

          {step === 'login' && (
            <div>
              <h2 className="font-display text-2xl font-semibold mb-1">Enterprise sign in</h2>
              <p className="text-mist text-sm mb-6">For registered business accounts.</p>

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

                  <div className="flex justify-end mb-4">
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
                    placeholder="you@yourcompany.com"
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
            </div>
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
