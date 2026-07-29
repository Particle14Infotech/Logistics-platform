// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
import { initializeApp } from 'firebase/app';
import { getAnalytics } from 'firebase/analytics';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: 'AIzaSyC23BDc66pnSxx2i2uGL8HMfIz8VbHxrbQ',
  authDomain: 'rahmitra-40638.firebaseapp.com',
  projectId: 'rahmitra-40638',
  storageBucket: 'rahmitra-40638.firebasestorage.app',
  messagingSenderId: '768140781082',
  appId: '1:768140781082:web:b04db1401537fd04d053a3',
  measurementId: 'G-YPSCJGKNF9',
};

export const app = initializeApp(firebaseConfig);
export const analytics = getAnalytics(app);
export const auth = getAuth(app);
