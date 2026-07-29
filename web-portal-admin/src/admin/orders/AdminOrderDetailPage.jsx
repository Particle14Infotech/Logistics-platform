import { useEffect, useState, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { ADMIN_NAV } from '../adminNav.js';

export default function AdminOrderDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [availableDrivers, setAvailableDrivers] = useState([]);
  const [selectedDriverId, setSelectedDriverId] = useState('');
  const [loading, setLoading] = useState(true);
  const [assigning, setAssigning] = useState(false);
  const [error, setError] = useState('');
  const [assignError, setAssignError] = useState('');

  const fetchOrder = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get(`/admin/orders/${id}`);
      setOrder(data.data.order);
    } catch (err) {
      console.error('[AdminOrderDetailPage] failed to load order', err);
      setError(err.response?.data?.message || 'Could not load this order.');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchOrder();
  }, [fetchOrder]);

  useEffect(() => {
    // Load approved, available drivers matching this order's vehicle type for the assignment dropdown
    if (!order) return;
    axiosClient
      .get('/drivers', { params: { isApproved: true, vehicleType: order.vehicleType } })
      .then(({ data }) => setAvailableDrivers(data.data.drivers))
      .catch((err) => console.error('[AdminOrderDetailPage] failed to load drivers', err));
  }, [order]);

  const handleAssign = async () => {
    if (!selectedDriverId) return;
    setAssigning(true);
    setAssignError('');
    try {
      await axiosClient.put(`/admin/orders/${id}/assign`, { driverId: selectedDriverId });
      await fetchOrder();
      setSelectedDriverId('');
    } catch (err) {
      console.error('[AdminOrderDetailPage] assign failed', err);
      setAssignError(err.response?.data?.message || 'Could not assign driver.');
    } finally {
      setAssigning(false);
    }
  };

  return (
    <ConsoleShell navItems={ADMIN_NAV} brandSuffix="ADMIN" footerLabel="Ops Admin" loginPath="/login" dateLabel="25 JUL 2026">
      <button onClick={() => navigate('/orders')} className="text-sm text-mist hover:text-signal transition-colors">
        ← Back to orders
      </button>

      {loading && <div className="text-center py-16 text-mist text-sm">Loading order…</div>}
      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {order && (
        <>
          <div className="flex items-start justify-between">
            <div>
              <span className="eyebrow">Order</span>
              <h1 className="font-display text-2xl font-semibold mt-1 font-mono">{order._id.slice(-8).toUpperCase()}</h1>
            </div>
            <StatusBadge status={order.status} />
          </div>

          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
              <span className="eyebrow">Shipment</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Pickup</span><span>{order.pickupLocation?.address ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Drop</span><span>{order.dropLocation?.address ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Vehicle</span><span className="capitalize">{order.vehicleType.replace('_', ' ')}</span></div>
                <div className="flex justify-between"><span className="text-mist">Goods</span><span>{order.goodsType ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Weight</span><span>{order.weightKg ? `${order.weightKg} kg` : '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Distance</span><span>{order.distanceKm ? `${order.distanceKm} km` : '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Amount</span><span className="font-mono">₹{order.price.toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between"><span className="text-mist">Payment</span><StatusBadge status={order.paymentStatus} /></div>
              </div>
            </div>

            <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
              <span className="eyebrow">Customer</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Name</span><span>{order.customerId?.name ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Phone</span><span className="font-mono">{order.customerId?.phone ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Email</span><span>{order.customerId?.email ?? '—'}</span></div>
              </div>

              <span className="eyebrow block pt-2">Driver</span>
              {order.driverId ? (
                <div className="text-sm space-y-1.5 mt-2">
                  <div className="flex justify-between"><span className="text-mist">Name</span><span>{order.driverId.userId?.name ?? '—'}</span></div>
                  <div className="flex justify-between"><span className="text-mist">Vehicle no.</span><span className="font-mono">{order.driverId.vehicleNumber}</span></div>
                  <div className="flex justify-between"><span className="text-mist">Rating</span><span>{order.driverId.rating?.toFixed(1) ?? '—'} ★</span></div>
                </div>
              ) : (
                <div className="mt-2 space-y-2">
                  <p className="text-xs text-mist">No driver assigned yet.</p>
                  {['delivered', 'cancelled'].includes(order.status) ? (
                    <p className="text-xs text-mist italic">This order is {order.status} — assignment closed.</p>
                  ) : (
                    <>
                      <select
                        value={selectedDriverId}
                        onChange={(e) => setSelectedDriverId(e.target.value)}
                        className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
                      >
                        <option value="">Select an available {order.vehicleType.replace('_', ' ')} driver…</option>
                        {availableDrivers.map((d) => (
                          <option key={d._id} value={d._id}>
                            {d.userId?.name ?? 'Unnamed'} — {d.vehicleNumber} {d.isAvailable ? '(online)' : '(offline)'}
                          </option>
                        ))}
                      </select>
                      {availableDrivers.length === 0 && (
                        <p className="text-xs text-mist">No approved {order.vehicleType.replace('_', ' ')} drivers found.</p>
                      )}
                      {assignError && <p className="text-xs text-stop">{assignError}</p>}
                      <button
                        onClick={handleAssign}
                        disabled={!selectedDriverId || assigning}
                        className="bg-signal text-ink text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
                      >
                        {assigning ? 'Assigning…' : 'Assign driver'}
                      </button>
                    </>
                  )}
                </div>
              )}
            </div>
          </div>

          <div className="bg-panel border border-line rounded-lg p-4">
            <span className="eyebrow">Timeline</span>
            <div className="mt-3 space-y-2">
              {order.timeline?.slice().reverse().map((event, i) => (
                <div key={i} className="flex items-start gap-3 text-sm">
                  <span className="font-mono text-xs text-mist w-40 shrink-0">
                    {new Date(event.timestamp).toLocaleString('en-IN')}
                  </span>
                  <StatusBadge status={event.status} />
                  {event.note && <span className="text-mist text-xs">{event.note}</span>}
                </div>
              ))}
              {(!order.timeline || order.timeline.length === 0) && (
                <p className="text-xs text-mist">No status events recorded yet.</p>
              )}
            </div>
          </div>
        </>
      )}
    </ConsoleShell>
  );
}
