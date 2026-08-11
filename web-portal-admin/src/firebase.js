// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
import { initializeApp } from 'firebase/app';
import { getAnalytics } from 'firebase/analytics';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: 'AIzaSyCiNw55MzaJPqW409-iMZxUMeUTKfmGqFU',
  authDomain: 'logix-94060.firebaseapp.com',
  projectId: 'logix-94060',
  storageBucket: 'logix-94060.firebasestorage.app',
  messagingSenderId: '84806642758',
  appId: '1:84806642758:web:7c9c56e5f196368f292e47',
  measurementId: 'G-86X42LY6XG',
};

export const app = initializeApp(firebaseConfig);
export const analytics = getAnalytics(app);
// Only used for phone-OTP login (see AdminLoginPage.jsx) - Admin's
// password login stays on the separate bcrypt /auth/login endpoint,
// unrelated to Firebase.
export const auth = getAuth(app);
