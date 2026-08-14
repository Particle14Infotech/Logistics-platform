import { useEffect, useState, useCallback, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { MapContainer, TileLayer, Marker, useMap } from 'react-leaflet';
import L from 'leaflet';
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';
import ConsoleShell from '../../shared/layouts/ConsoleShell.jsx';
import StatusBadge from '../../shared/components/StatusBadge.jsx';
import axiosClient from '../../shared/api/axiosClient.js';
import { downloadFile } from '../../shared/utils/downloadFile.js';
import { socketService } from '../../shared/services/socketService.js';
import { ADMIN_NAV } from '../adminNav.js';

// react-leaflet's default marker icon paths break under Vite's bundling -
// this is the standard workaround (point the icon at the actual bundled
// asset URLs instead of the relative path Leaflet assumes).
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({ iconRetinaUrl: markerIcon2x, iconUrl: markerIcon, shadowUrl: markerShadow });

// Pickup documents are stored as relative paths like '/uploads/xyz.pdf',
// served directly by the backend (express.static, no auth) - same pattern
// AdminDriverDetailPage.jsx uses for KYC documents, so a plain <a> works,
// no need to route through the authenticated downloadFile() blob helper.
const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1';
const BACKEND_ORIGIN = API_BASE.replace(/\/api\/v1\/?$/, '');
function resolveDocUrl(url) {
  return url.startsWith('/') ? `${BACKEND_ORIGIN}${url}` : url;
}

function MapRecenter({ position }) {
  const map = useMap();
  useEffect(() => {
    if (position) map.setView(position, map.getZoom());
  }, [position, map]);
  return null;
}

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

  const [position, setPosition] = useState(null);
  const [socketConnected, setSocketConnected] = useState(false);
  const [messages, setMessages] = useState(null);
  const [chatError, setChatError] = useState('');
  const [downloadingInvoice, setDownloadingInvoice] = useState(false);
  const [invoiceError, setInvoiceError] = useState('');
  const [waybillForm, setWaybillForm] = useState(null);
  const [savingWaybill, setSavingWaybill] = useState(false);
  const [waybillError, setWaybillError] = useState('');
  const [waybillSaved, setWaybillSaved] = useState(false);
  const chatBottomRef = useRef(null);

  const fetchOrder = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get(`/admin/orders/${id}`);
      setOrder(data.data.order);
      const wb = data.data.order.waybillDetails || {};
      setWaybillForm({
        consigneeName: wb.consigneeName || '',
        consigneePhone: wb.consigneePhone || '',
        consignorGstin: wb.consignorGstin || '',
        consigneeGstin: wb.consigneeGstin || '',
        ewayBillNo: wb.ewayBillNo || '',
        declaredValue: wb.declaredValue ?? '',
        ratePerTon: wb.ratePerTon ?? '',
        rto: wb.rto || '',
        gstPayableBy: wb.gstPayableBy || '',
        taxType: wb.taxType || 'none',
        gstAmount: wb.gstAmount ?? 0,
        remark: wb.remark || '',
      });
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
      .get('/admin/drivers', { params: { isApproved: true, vehicleType: order.vehicleType } })
      .then(({ data }) => setAvailableDrivers(data.data.drivers))
      .catch((err) => console.error('[AdminOrderDetailPage] failed to load drivers', err));
  }, [order]);

  // Seed the map with the driver's last-known static position as soon as
  // the order loads, then upgrade to live updates once the socket connects.
  useEffect(() => {
    const coords = order?.driverId?.currentLocation?.coordinates;
    if (coords) setPosition([coords[1], coords[0]]); // GeoJSON is [lng, lat]
  }, [order?.driverId?.currentLocation]);

  // Chat history, admin is read-only here - the backend's chat_message
  // socket handler only accepts sends from the order's own customer/driver.
  useEffect(() => {
    if (!order?._id) return;
    let cancelled = false;
    axiosClient
      .get(`/booking/${order._id}/messages`)
      .then(({ data }) => {
        if (!cancelled) setMessages(data.data.messages);
      })
      .catch((err) => {
        if (!cancelled) setChatError(err.response?.data?.message || 'Could not load the conversation.');
      });
    return () => {
      cancelled = true;
    };
  }, [order?._id]);

  // Live socket: join this order's room for live GPS + live chat while the
  // page is open, matching the mobile apps' booking:${id} room contract.
  useEffect(() => {
    if (!order?._id) return;
    socketService.connect();
    socketService.joinBookingRoom(order._id);
    socketService.onConnectionChange(setSocketConnected);
    socketService.onLocationBroadcast((data) => {
      if (data.bookingId === order._id) setPosition([data.lat, data.lng]);
    });
    socketService.onChatMessage((msg) => {
      if (msg.bookingId === order._id) setMessages((prev) => [...(prev || []), msg]);
    });
    return () => {
      socketService.leaveBookingRoom(order._id);
    };
  }, [order?._id]);

  useEffect(() => {
    chatBottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

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

  const handleSaveWaybill = async () => {
    setSavingWaybill(true);
    setWaybillError('');
    setWaybillSaved(false);
    try {
      const payload = {
        ...waybillForm,
        declaredValue: waybillForm.declaredValue === '' ? undefined : Number(waybillForm.declaredValue),
        ratePerTon: waybillForm.ratePerTon === '' ? undefined : Number(waybillForm.ratePerTon),
        gstAmount: waybillForm.gstAmount === '' ? 0 : Number(waybillForm.gstAmount),
        gstPayableBy: waybillForm.gstPayableBy || undefined,
      };
      await axiosClient.put(`/booking/${id}/waybill-details`, payload);
      setWaybillSaved(true);
      setTimeout(() => setWaybillSaved(false), 2000);
    } catch (err) {
      console.error('[AdminOrderDetailPage] waybill details save failed', err);
      setWaybillError(err.response?.data?.message || 'Could not save waybill details.');
    } finally {
      setSavingWaybill(false);
    }
  };

  const handleDownloadInvoice = async () => {
    setDownloadingInvoice(true);
    setInvoiceError('');
    try {
      await downloadFile(`/booking/${id}/invoice`, `invoice-${id.slice(-8)}.pdf`);
    } catch (err) {
      console.error('[AdminOrderDetailPage] invoice download failed', err);
      setInvoiceError(err.response?.data?.message || 'Could not download the invoice.');
    } finally {
      setDownloadingInvoice(false);
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
                {order.enterpriseId?.companyName && (
                  <div className="flex justify-between"><span className="text-mist">Company</span><span>{order.enterpriseId.companyName}</span></div>
                )}
                <div className="flex justify-between"><span className="text-mist">Name</span><span>{order.customerId?.name ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Phone</span><span className="font-mono">{order.customerId?.phone ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Email</span><span>{order.customerId?.email ?? '—'}</span></div>
              </div>

              <span className="eyebrow block pt-2">Driver</span>
              {order.driverId ? (
                <div className="text-sm space-y-1.5 mt-2">
                  <div className="flex justify-between"><span className="text-mist">Name</span><span>{order.driverId.userId?.name ?? '—'}</span></div>
                  <div className="flex justify-between"><span className="text-mist">Vehicle no.</span><span className="font-mono">{order.driverId.vehicleNumber}</span></div>
                  <div className="flex justify-between"><span className="text-mist">Rating</span><span>{order.driverId.ratingCount ? `${order.driverId.rating?.toFixed(1)} ★ (${order.driverId.ratingCount})` : 'No ratings yet'}</span></div>
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
                        className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
                      >
                        {assigning ? 'Assigning…' : 'Assign driver'}
                      </button>
                    </>
                  )}
                </div>
              )}
            </div>
          </div>

          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-panel border border-line rounded-lg p-4 space-y-2">
              <div className="flex items-center justify-between">
                <span className="eyebrow">Live tracking</span>
                {order.driverId && (
                  <span className="text-xs">
                    {socketConnected ? <span className="text-go">● Live</span> : <span className="text-mist">○ Last known position</span>}
                  </span>
                )}
              </div>
              {position ? (
                <div className="h-52 rounded-md overflow-hidden border border-line mt-2">
                  <MapContainer center={position} zoom={13} style={{ height: '100%', width: '100%' }} scrollWheelZoom={false}>
                    <TileLayer
                      attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    />
                    <Marker position={position} />
                    <MapRecenter position={position} />
                  </MapContainer>
                </div>
              ) : (
                <div className="h-52 flex items-center justify-center text-xs text-mist bg-ink/50 rounded-md border border-line mt-2">
                  {order.driverId ? 'No location reported yet.' : 'No driver assigned yet.'}
                </div>
              )}
            </div>

            <div className="bg-panel border border-line rounded-lg p-4">
              <span className="eyebrow">Conversation</span>
              <div className="mt-2 max-h-52 overflow-y-auto space-y-2 pr-1">
                {chatError && <p className="text-xs text-stop">{chatError}</p>}
                {!chatError && messages === null && <p className="text-xs text-mist">Loading conversation…</p>}
                {!chatError && messages?.length === 0 && <p className="text-xs text-mist">No messages yet.</p>}
                {messages?.map((m) => (
                  <div key={m._id || m.id} className="text-sm">
                    <span className="text-xs text-mist capitalize">{m.senderRole}</span>
                    <span className="mx-1.5 text-mist">·</span>
                    <span className="text-xs text-mist font-mono">{new Date(m.createdAt).toLocaleTimeString('en-IN')}</span>
                    <p>{m.text}</p>
                  </div>
                ))}
                <div ref={chatBottomRef} />
              </div>
            </div>
          </div>

          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
              <span className="eyebrow">Pickup / delivery codes</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Start OTP</span><span className="font-mono">{order.startOtp ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Delivery OTP</span><span className="font-mono">{order.deliveryOtp ?? '—'}</span></div>
              </div>
              <span className="eyebrow block pt-2">Proof of delivery</span>
              {order.podImageUrl ? (
                <a href={order.podImageUrl} target="_blank" rel="noreferrer" className="text-xs text-signal hover:underline">View POD image →</a>
              ) : (
                <p className="text-xs text-mist mt-2">Not yet uploaded.</p>
              )}
            </div>

            <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
              <div className="flex items-center justify-between">
                <span className="eyebrow">Pickup documents</span>
                <span className="text-xs text-mist">{order.pickupDocuments?.length ?? 0}</span>
              </div>
              {order.pickupDocuments?.length > 0 ? (
                <div className="space-y-1.5 mt-1">
                  {order.pickupDocuments.map((doc, i) => (
                    <a
                      key={i}
                      href={resolveDocUrl(doc.url)}
                      target="_blank"
                      rel="noreferrer"
                      download={doc.originalName || undefined}
                      className="flex items-center justify-between px-3 py-2 border border-line rounded-md hover:border-signal transition-colors text-sm"
                    >
                      <span className="truncate">{doc.originalName || `Document ${i + 1}`}</span>
                      <span className="text-signal text-xs shrink-0 ml-2">Download →</span>
                    </a>
                  ))}
                </div>
              ) : (
                <p className="text-xs text-mist mt-2">
                  {['picked_up', 'in_transit', 'awaiting_payment', 'delivered'].includes(order.status)
                    ? 'None uploaded.'
                    : 'Not collected yet - uploaded by the driver at pickup, before the trip can start.'}
                </p>
              )}
            </div>

            <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
              <div className="flex items-center justify-between">
                <span className="eyebrow">Delivery documents</span>
                <span className="text-xs text-mist">{order.deliveryDocuments?.length ?? 0}</span>
              </div>
              {order.deliveryDocuments?.length > 0 ? (
                <div className="space-y-1.5 mt-1">
                  {order.deliveryDocuments.map((doc, i) => (
                    <a
                      key={i}
                      href={resolveDocUrl(doc.url)}
                      target="_blank"
                      rel="noreferrer"
                      download={doc.originalName || undefined}
                      className="flex items-center justify-between px-3 py-2 border border-line rounded-md hover:border-signal transition-colors text-sm"
                    >
                      <span className="truncate">{doc.originalName || `Document ${i + 1}`}</span>
                      <span className="text-signal text-xs shrink-0 ml-2">Download →</span>
                    </a>
                  ))}
                </div>
              ) : (
                <p className="text-xs text-mist mt-2">
                  {['awaiting_payment', 'delivered'].includes(order.status)
                    ? 'None uploaded.'
                    : 'Not collected yet - uploaded by the driver while in transit, before delivery can be confirmed.'}
                </p>
              )}
            </div>

            {waybillForm && (
              <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
                <span className="eyebrow">Waybill details</span>
                <p className="text-xs text-mist mt-1">Fills in the LR/waybill fields the app doesn't collect at booking - shown on the downloaded invoice below.</p>
                <div className="grid md:grid-cols-2 gap-3 mt-2">
                  <div>
                    <span className="eyebrow block mb-1">Consignee name</span>
                    <input type="text" value={waybillForm.consigneeName} onChange={(e) => setWaybillForm((f) => ({ ...f, consigneeName: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">Consignee phone</span>
                    <input type="text" value={waybillForm.consigneePhone} onChange={(e) => setWaybillForm((f) => ({ ...f, consigneePhone: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">Consignor GSTIN</span>
                    <input type="text" value={waybillForm.consignorGstin} onChange={(e) => setWaybillForm((f) => ({ ...f, consignorGstin: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">Consignee GSTIN</span>
                    <input type="text" value={waybillForm.consigneeGstin} onChange={(e) => setWaybillForm((f) => ({ ...f, consigneeGstin: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">E-way bill no.</span>
                    <input type="text" value={waybillForm.ewayBillNo} onChange={(e) => setWaybillForm((f) => ({ ...f, ewayBillNo: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">R.T.O.</span>
                    <input type="text" value={waybillForm.rto} onChange={(e) => setWaybillForm((f) => ({ ...f, rto: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">Declared value (₹)</span>
                    <input type="number" value={waybillForm.declaredValue} onChange={(e) => setWaybillForm((f) => ({ ...f, declaredValue: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">Rate per ton (₹)</span>
                    <input type="number" value={waybillForm.ratePerTon} onChange={(e) => setWaybillForm((f) => ({ ...f, ratePerTon: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">Tax type</span>
                    <select value={waybillForm.taxType} onChange={(e) => setWaybillForm((f) => ({ ...f, taxType: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors">
                      <option value="none">None</option>
                      <option value="intra_state">Intra-state (SGST + CGST)</option>
                      <option value="inter_state">Inter-state (IGST)</option>
                    </select>
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">GST amount (₹)</span>
                    <input type="number" value={waybillForm.gstAmount} onChange={(e) => setWaybillForm((f) => ({ ...f, gstAmount: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm font-mono focus:border-signal focus:outline-none transition-colors" />
                  </div>
                  <div>
                    <span className="eyebrow block mb-1">GST payable by</span>
                    <select value={waybillForm.gstPayableBy} onChange={(e) => setWaybillForm((f) => ({ ...f, gstPayableBy: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors">
                      <option value="">—</option>
                      <option value="consignor">Consignor</option>
                      <option value="consignee">Consignee</option>
                      <option value="transporter">Transporter</option>
                    </select>
                  </div>
                  <div className="md:col-span-2">
                    <span className="eyebrow block mb-1">Remark</span>
                    <input type="text" value={waybillForm.remark} onChange={(e) => setWaybillForm((f) => ({ ...f, remark: e.target.value }))} className="w-full bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors" />
                  </div>
                </div>
                {waybillError && <p className="text-xs text-stop">{waybillError}</p>}
                <button
                  onClick={handleSaveWaybill}
                  disabled={savingWaybill}
                  className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
                >
                  {savingWaybill ? 'Saving…' : waybillSaved ? 'Saved ✓' : 'Save waybill details'}
                </button>
              </div>
            )}

            <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
              <span className="eyebrow">Invoice</span>
              <p className="text-xs text-mist mt-2">Available once a payment for this order has been captured.</p>
              {invoiceError && <p className="text-xs text-stop">{invoiceError}</p>}
              <button
                onClick={handleDownloadInvoice}
                disabled={downloadingInvoice}
                className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
              >
                {downloadingInvoice ? 'Downloading…' : 'Download invoice'}
              </button>
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
