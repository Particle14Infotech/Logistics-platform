import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';

// Global safety nets so nothing ever fails silently during development -
// any uncaught error or rejected promise anywhere in the app gets logged
// loudly instead of vanishing.
window.addEventListener('error', (event) => {
  console.error('[GLOBAL ERROR]', event.error || event.message);
});
window.addEventListener('unhandledrejection', (event) => {
  console.error('[UNHANDLED PROMISE REJECTION]', event.reason);
});

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
