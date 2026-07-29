// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
import { initializeApp } from 'firebase/app';
import { getAnalytics } from 'firebase/analytics';

const firebaseConfig = {
  apiKey: 'AIzaSyC23BDc66pnSxx2i2uGL8HMfIz8VbHxrbQ',
  authDomain: 'rahmitra-40638.firebaseapp.com',
  projectId: 'rahmitra-40638',
  storageBucket: 'rahmitra-40638.firebasestorage.app',
  messagingSenderId: '768140781082',
  appId: '1:768140781082:web:8a71cee118162cb1d053a3',
  measurementId: 'G-VZSWTRE0KC',
};

export const app = initializeApp(firebaseConfig);
export const analytics = getAnalytics(app);
