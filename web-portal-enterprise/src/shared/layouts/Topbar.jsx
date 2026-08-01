import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import axiosClient from '../api/axiosClient.js';

/**
 * Top bar: search + live status pill + notifications + identity. Kept quiet
 * so the signature fleet ticker and KPI strip below do the visual work.
 */
export default function Topbar({ userName, userRole, dateLabel, onMenuClick }) {
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const containerRef = useRef(null);

  const fetchNotifications = () => {
    setLoading(true);
    axiosClient
      .get('/notifications', { params: { limit: 10 } })
      .then(({ data }) => {
        setNotifications(data.data.notifications);
        setUnreadCount(data.data.unreadCount);
      })
      .catch((err) => console.error('[Topbar] failed to load notifications', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchNotifications();
  }, []);

  useEffect(() => {
    function handleClickOutside(event) {
      if (containerRef.current && !containerRef.current.contains(event.target)) setOpen(false);
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const toggleOpen = () => {
    const next = !open;
    setOpen(next);
    if (next) fetchNotifications();
  };

  const markRead = async (id) => {
    try {
      await axiosClient.put(`/notifications/${id}/read`);
      setNotifications((prev) => prev.map((n) => (n._id === id ? { ...n, isRead: true } : n)));
      setUnreadCount((c) => Math.max(0, c - 1));
    } catch (err) {
      console.error('[Topbar] failed to mark notification read', err);
    }
  };

  const markAllRead = async () => {
    try {
      await axiosClient.put('/notifications/read-all');
      setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
      setUnreadCount(0);
    } catch (err) {
      console.error('[Topbar] failed to mark all notifications read', err);
    }
  };

  return (
    <header className="h-16 flex items-center justify-between gap-4 px-4 sm:px-6 border-b border-line bg-ink/80 backdrop-blur sticky top-0 z-10 shadow-sm">
      <div className="flex items-center gap-3 flex-1 max-w-md min-w-0">
        <button
          type="button"
          onClick={onMenuClick}
          className="md:hidden shrink-0 w-9 h-9 flex items-center justify-center rounded-md border border-line text-mist hover:text-paper hover:bg-panel2 transition-colors"
          aria-label="Open menu"
        >
          ☰
        </button>
        <div className="relative w-full">
          <span className="absolute left-3 top-1/2 -translate-y-1/2 text-mist text-sm">⌕</span>
          <input
            type="text"
            placeholder="Search orders, drivers, waybill no."
            className="w-full bg-panel border border-line rounded-md pl-9 pr-3 py-2 text-sm placeholder:text-mist/70 focus:border-signal focus:outline-none transition-colors"
          />
        </div>
      </div>

      <div className="flex items-center gap-4">
        <span className="hidden sm:block eyebrow">{dateLabel}</span>
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-go/10 text-go text-xs font-semibold">
          <span className="w-1.5 h-1.5 rounded-full bg-go animate-pulse" />
          Live
        </div>

        <div className="relative pl-4 border-l border-line" ref={containerRef}>
          <button
            type="button"
            onClick={toggleOpen}
            className="relative w-9 h-9 flex items-center justify-center rounded-md border border-line text-mist hover:text-paper hover:bg-panel2 transition-colors"
            aria-label="Notifications"
          >
            🔔
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 min-w-[18px] h-[18px] px-1 flex items-center justify-center rounded-full bg-stop text-white text-[10px] font-semibold">
                {unreadCount > 9 ? '9+' : unreadCount}
              </span>
            )}
          </button>

          {open && (
            <div className="absolute right-0 mt-2 w-80 max-h-96 overflow-y-auto bg-panel border border-line rounded-lg shadow-lg z-20">
              <div className="flex items-center justify-between px-3 py-2 border-b border-line">
                <span className="text-sm font-medium">Notifications</span>
                {unreadCount > 0 && (
                  <button onClick={markAllRead} className="text-xs text-signal hover:underline">
                    Mark all read
                  </button>
                )}
              </div>
              {loading && <div className="px-3 py-4 text-xs text-mist text-center">Loading…</div>}
              {!loading && notifications.length === 0 && (
                <div className="px-3 py-6 text-xs text-mist text-center">You're all caught up.</div>
              )}
              {!loading &&
                notifications.map((n) => (
                  <button
                    key={n._id}
                    onClick={() => markRead(n._id)}
                    className={`block w-full text-left px-3 py-2.5 border-b border-line last:border-0 hover:bg-panel2 transition-colors ${n.isRead ? 'opacity-60' : ''}`}
                  >
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-sm font-medium truncate">{n.title}</span>
                      {!n.isRead && <span className="w-1.5 h-1.5 rounded-full bg-signal shrink-0" />}
                    </div>
                    <p className="text-xs text-mist mt-0.5 line-clamp-2">{n.body}</p>
                    <span className="text-[10px] text-mist font-mono">{new Date(n.createdAt).toLocaleString('en-IN')}</span>
                  </button>
                ))}
            </div>
          )}
        </div>

        <Link to="/profile" className="flex items-center gap-2 pl-4 border-l border-line hover:opacity-80 transition-opacity">
          <div className="w-8 h-8 rounded-full bg-panel2 border border-line flex items-center justify-center font-display text-xs font-semibold">
            {userName?.[0] ?? '?'}
          </div>
          <div className="hidden sm:block leading-tight">
            <div className="text-sm font-medium">{userName}</div>
            <div className="text-xs text-mist">{userRole}</div>
          </div>
        </Link>
      </div>
    </header>
  );
}
