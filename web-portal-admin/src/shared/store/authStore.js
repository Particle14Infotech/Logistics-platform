import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// Global auth state, persisted to localStorage under 'logistics-auth'.
// Holds the JWT pair + user profile so refreshes don't lose the session.
export const useAuthStore = create(
  persist(
    (set) => ({
      accessToken: null,
      refreshToken: null,
      user: null, // { id, name, email, role, enterpriseId }

      setAuth: ({ accessToken, refreshToken, user }) =>
        set({ accessToken, refreshToken, user }),

      setAccessToken: (accessToken) => set({ accessToken }),

      setUser: (user) => set({ user }),

      clearAuth: () => set({ accessToken: null, refreshToken: null, user: null }),

      isAuthenticated: () => {
        // Read directly from the store rather than closing over stale state
        const { accessToken } = useAuthStore.getState();
        return Boolean(accessToken);
      },
    }),
    { name: 'logistics-auth' }
  )
);
