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
import { downloadFile, downloadFileFromUrl } from '../../shared/utils/downloadFile.js';
import { socketService } from '../../shared/services/socketService.js';
import { ENTERPRISE_NAV } from '../enterpriseNav.js';

// react-leaflet's default marker icon paths break under Vite's bundling -
// this is the standard workaround (point the icon at the actual bundled
// asset URLs instead of the relative path Leaflet assumes).
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({ iconRetinaUrl: markerIcon2x, iconUrl: markerIcon, shadowUrl: markerShadow });

// Pickup/delivery documents are stored as relative paths like
// '/uploads/xyz.pdf', served directly by the backend (express.static, no
// auth) - so the "View" link works as a plain <a>. "Download" still needs
// downloadFileFromUrl though (see that helper's comment) - api.raahmitr.com
// is a different origin from this app, and a plain <a download> silently
// doesn't force a download for a cross-origin href in most browsers.
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

export default function EnterpriseOrderDetailPage() {
  const { orderId } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [position, setPosition] = useState(null);
  const [socketConnected, setSocketConnected] = useState(false);
  const [messages, setMessages] = useState(null);
  const [chatError, setChatError] = useState('');
  const [messageText, setMessageText] = useState('');
  const [downloadingInvoice, setDownloadingInvoice] = useState(false);
  const [invoiceError, setInvoiceError] = useState('');
  const [docDownloadError, setDocDownloadError] = useState('');
  const [waybillForm, setWaybillForm] = useState(null);
  const [savingWaybill, setSavingWaybill] = useState(false);
  const [waybillError, setWaybillError] = useState('');
  const [waybillSaved, setWaybillSaved] = useState(false);
  const chatBottomRef = useRef(null);

  const fetchOrder = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data } = await axiosClient.get(`/enterprise/orders/${orderId}`);
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
      console.error('[EnterpriseOrderDetailPage] failed to load order', err);
      setError(err.response?.data?.message || 'Could not load this order.');
    } finally {
      setLoading(false);
    }
  }, [orderId]);

  useEffect(() => {
    fetchOrder();
  }, [fetchOrder]);

  // Seed the map with the driver's last-known static position, then
  // upgrade to live updates once the socket connects.
  useEffect(() => {
    const coords = order?.driverId?.currentLocation?.coordinates;
    if (coords) setPosition([coords[1], coords[0]]); // GeoJSON is [lng, lat]
  }, [order?.driverId?.currentLocation]);

  // Chat history. A company-wide enterprise_admin viewing a teammate's
  // order (one they didn't personally book) will get a 403 here, since
  // GET /booking/:id/messages only authorizes the order's own customerId,
  // its driver, or an admin - shown as a plain message rather than an error.
  useEffect(() => {
    if (!order?._id) return;
    let cancelled = false;
    axiosClient
      .get(`/booking/${order._id}/messages`)
      .then(({ data }) => {
        if (!cancelled) setMessages(data.data.messages);
      })
      .catch((err) => {
        if (cancelled) return;
        if (err.response?.status === 403) {
          setChatError("You don't have access to this conversation.");
        } else {
          setChatError(err.response?.data?.message || 'Could not load the conversation.');
        }
      });
    return () => {
      cancelled = true;
    };
  }, [order?._id]);

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

  const handleSend = () => {
    const text = messageText.trim();
    if (!text || !order?._id) return;
    if (!socketConnected) {
      setChatError("Not connected - couldn't send that message. Check your connection and try again.");
      return;
    }
    socketService.sendChatMessage(order._id, text);
    setMessageText('');
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
      await axiosClient.put(`/booking/${orderId}/waybill-details`, payload);
      setWaybillSaved(true);
      setTimeout(() => setWaybillSaved(false), 2000);
    } catch (err) {
      console.error('[EnterpriseOrderDetailPage] waybill details save failed', err);
      setWaybillError(err.response?.data?.message || 'Could not save waybill details.');
    } finally {
      setSavingWaybill(false);
    }
  };

  const handleDownloadInvoice = async () => {
    setDownloadingInvoice(true);
    setInvoiceError('');
    try {
      await downloadFile(`/booking/${orderId}/invoice`, `invoice-${orderId.slice(-8)}.pdf`);
    } catch (err) {
      console.error('[EnterpriseOrderDetailPage] invoice download failed', err);
      setInvoiceError(err.response?.data?.message || 'Could not download the invoice.');
    } finally {
      setDownloadingInvoice(false);
    }
  };

  const handleDownloadDoc = async (doc, i) => {
    setDocDownloadError('');
    try {
      await downloadFileFromUrl(resolveDocUrl(doc.url), doc.originalName || `document-${i + 1}`);
    } catch (err) {
      console.error('[EnterpriseOrderDetailPage] document download failed', err);
      setDocDownloadError('Could not download that document.');
    }
  };

  return (
    <ConsoleShell navItems={ENTERPRISE_NAV} brandSuffix="ENTERPRISE" footerLabel="Vertex Pharma" loginPath="/login" dateLabel="25 JUL 2026">
      <button onClick={() => navigate('/order-tracking')} className="text-sm text-mist hover:text-signal transition-colors">
        ← Back to order tracking
      </button>

      {loading && <div className="text-center py-16 text-mist text-sm">Loading order…</div>}
      {error && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-4">{error}</div>}

      {order && (
        <>
          <div className="flex items-start justify-between">
            <div>
              <span className="eyebrow">Shipment</span>
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
              <span className="eyebrow">Driver</span>
              {order.driverId ? (
                <div className="text-sm space-y-1.5 mt-2">
                  <div className="flex justify-between"><span className="text-mist">Name</span><span>{order.driverId.userId?.name ?? '—'}</span></div>
                  <div className="flex justify-between"><span className="text-mist">Phone</span><span className="font-mono">{order.driverId.userId?.phone ?? '—'}</span></div>
                  <div className="flex justify-between"><span className="text-mist">Vehicle no.</span><span className="font-mono">{order.driverId.vehicleNumber}</span></div>
                </div>
              ) : (
                <p className="text-xs text-mist mt-2">No driver assigned yet.</p>
              )}

              <span className="eyebrow block pt-2">Codes</span>
              <div className="text-sm space-y-1.5 mt-2">
                <div className="flex justify-between"><span className="text-mist">Start OTP</span><span className="font-mono">{order.startOtp ?? '—'}</span></div>
                <div className="flex justify-between"><span className="text-mist">Delivery OTP</span><span className="font-mono">{order.deliveryOtp ?? '—'}</span></div>
              </div>
            </div>
          </div>

          {docDownloadError && <div className="border border-stop/30 bg-stop/10 text-stop text-sm rounded-lg p-3">{docDownloadError}</div>}

          <div className="bg-panel border border-line rounded-lg p-4 space-y-3">
            <div className="flex items-center justify-between">
              <span className="eyebrow">Pickup documents</span>
              <span className="text-xs text-mist">{order.pickupDocuments?.length ?? 0}</span>
            </div>
            {order.pickupDocuments?.length > 0 ? (
              <div className="grid sm:grid-cols-2 gap-1.5">
                {order.pickupDocuments.map((doc, i) => (
                  <div key={i} className="flex items-center justify-between gap-2 px-3 py-2 border border-line rounded-md text-sm">
                    <span className="truncate">{doc.originalName || `Document ${i + 1}`}</span>
                    <div className="flex items-center gap-3 shrink-0">
                      <a href={resolveDocUrl(doc.url)} target="_blank" rel="noreferrer" className="text-signal text-xs hover:underline">View</a>
                      <button onClick={() => handleDownloadDoc(doc, i)} className="text-signal text-xs hover:underline">Download</button>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-xs text-mist">
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
              <div className="grid sm:grid-cols-2 gap-1.5">
                {order.deliveryDocuments.map((doc, i) => (
                  <div key={i} className="flex items-center justify-between gap-2 px-3 py-2 border border-line rounded-md text-sm">
                    <span className="truncate">{doc.originalName || `Document ${i + 1}`}</span>
                    <div className="flex items-center gap-3 shrink-0">
                      <a href={resolveDocUrl(doc.url)} target="_blank" rel="noreferrer" className="text-signal text-xs hover:underline">View</a>
                      <button onClick={() => handleDownloadDoc(doc, i)} className="text-signal text-xs hover:underline">Download</button>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-xs text-mist">
                {['awaiting_payment', 'delivered'].includes(order.status)
                  ? 'None uploaded.'
                  : 'Not collected yet - uploaded by the driver while in transit, before delivery can be confirmed.'}
              </p>
            )}
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

            <div className="bg-panel border border-line rounded-lg p-4 flex flex-col">
              <span className="eyebrow">Chat with driver</span>
              <div className="mt-2 flex-1 max-h-40 overflow-y-auto space-y-2 pr-1">
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
              {!chatError && messages !== null && (
                <div className="flex gap-2 mt-3">
                  <input
                    type="text"
                    placeholder="Type a message…"
                    value={messageText}
                    onChange={(e) => setMessageText(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                    className="flex-1 bg-ink border border-line rounded-md px-3 py-2 text-sm focus:border-signal focus:outline-none transition-colors"
                  />
                  <button
                    onClick={handleSend}
                    disabled={!messageText.trim()}
                    className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
                  >
                    Send
                  </button>
                </div>
              )}
            </div>
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

          <div className="bg-panel border border-line rounded-lg p-4 flex items-center justify-between flex-wrap gap-3">
            <div>
              <span className="eyebrow">Invoice</span>
              <p className="text-xs text-mist mt-1">Available once a payment for this order has been captured.</p>
              {invoiceError && <p className="text-xs text-stop mt-1">{invoiceError}</p>}
            </div>
            <button
              onClick={handleDownloadInvoice}
              disabled={downloadingInvoice}
              className="bg-signal text-white text-sm font-medium rounded-md px-4 py-2 hover:brightness-110 disabled:opacity-50 transition-all"
            >
              {downloadingInvoice ? 'Downloading…' : 'Download invoice'}
            </button>
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
