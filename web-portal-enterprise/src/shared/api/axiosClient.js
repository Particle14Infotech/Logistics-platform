import axios from 'axios';
import { useAuthStore } from '../store/authStore.js';

const axiosClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1',
});

// Attach the current JWT access token to every request
axiosClient.interceptors.request.use((config) => {
  const { accessToken } = useAuthStore.getState();
  if (accessToken) config.headers.Authorization = `Bearer ${accessToken}`;
  return config;
});

// On a 401, try to silently refresh the access token once and retry the
// original request. If the refresh itself fails, clear auth so the route
// guard redirects to login.
let refreshPromise = null;

axiosClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    const status = error.response?.status;

    if (!error.response) {
      // Network-level failure - wrong port, backend down, CORS block, etc.
      console.error('[axiosClient] Network error - no response received.', {
        url: originalRequest?.url,
        baseURL: originalRequest?.baseURL,
        message: error.message,
      });
    }

    if (status !== 401 || originalRequest._retry || originalRequest.url?.includes('/auth/')) {
      return Promise.reject(error);
    }

    originalRequest._retry = true;
    const { refreshToken, setAccessToken, clearAuth } = useAuthStore.getState();

    if (!refreshToken) {
      clearAuth();
      return Promise.reject(error);
    }

    try {
      // De-dupe concurrent 401s into a single refresh call
      if (!refreshPromise) {
        refreshPromise = axiosClient
          .post('/auth/refresh-token', { refreshToken })
          .finally(() => {
            refreshPromise = null;
          });
      }
      const { data } = await refreshPromise;
      setAccessToken(data.data.accessToken);
      originalRequest.headers.Authorization = `Bearer ${data.data.accessToken}`;
      return axiosClient(originalRequest);
    } catch (refreshError) {
      clearAuth();
      return Promise.reject(refreshError);
    }
  }
);

export default axiosClient;
