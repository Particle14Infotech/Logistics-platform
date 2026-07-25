# System Architecture

## Three-Tier Design

1. **Client Tier** — Flutter Customer App, Flutter Driver App, React Admin/Enterprise Portal
2. **Application Tier** — Node.js REST API (Express) + Socket.IO real-time layer, split into
   internal services: Auth, Booking, Tracking, Payment, Notification, Invoice, Admin
3. **Data Tier** — MongoDB Atlas (primary store), AWS S3 (files: POD images, invoices, KYC
   documents), Redis (optional caching layer for driver locations / rate limiting)

## Real-Time Tracking Flow

1. Driver app broadcasts GPS coordinates via Socket.IO every 3–5 seconds
   (`driver_location_update` event).
2. Backend `tracking.socket.js` persists the last known location on the `Driver` document and
   re-broadcasts to the `booking:{bookingId}` room (`location_broadcast` event).
3. Customer app (and Admin live fleet map) listen on the same room and animate the marker.
4. Order status transitions (`accepted`, `picked_up`, `in_transit`, `delivered`) propagate the
   same way via `order_status_update` → `status_broadcast`.

## Auth Flow

- OTP-based login for Customer & Driver apps: `POST /auth/send-otp` → `POST /auth/verify-otp`
  → returns `{ accessToken, refreshToken }`.
- Email/password login for Admin & Enterprise users: `POST /auth/login`.
- All protected routes require `Authorization: Bearer <accessToken>`; `auth.middleware.js`
  verifies the JWT and attaches `req.user = { id, role }`.
- Role-based access via `authorize('admin')`, `authorize('driver')`, etc.

## Module Boundaries (Backend)

| Module | Responsibility |
|---|---|
| `auth.*` | OTP, JWT issue/verify/refresh, profile |
| `booking.*` | Price estimate, create/cancel booking, tracking lookup |
| `driver.*` | Available orders, accept/reject, status toggle, POD upload, earnings |
| `payment.*` | Razorpay order creation, webhook verification, refunds |
| `enterprise.*` | Enterprise account, bulk booking (CSV), invoices |
| `admin.*` | Order/driver management, pricing config, analytics |
| `sockets/tracking.socket.js` | Real-time GPS + status broadcast |

## Database Schema

See `docs/srs/logistics_platform_project_document.pdf` Section 6 for the full field-level
MongoDB schema (Users, Orders, Drivers, Payments, Enterprise). The Mongoose models in
`backend/src/models/` are the implemented source of truth and may extend the original SRS
slightly (e.g. `Bid` and `Invoice` were split into their own collections for clarity).

## Deployment Topology

- **Backend**: AWS EC2 (t3.medium) behind Nginx reverse proxy, managed by PM2
- **Web Portal**: Static build deployed to Vercel or S3 + CloudFront
- **Mobile Apps**: Google Play Store (Customer + Driver), Apple App Store (Customer)
- **Database**: MongoDB Atlas M10 cluster, daily backups, VPC peering recommended
