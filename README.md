# Pan-India Logistics Platform

A hybrid B2C + B2B truck booking & logistics marketplace — **MERN** backend/web portal and **Flutter** mobile apps for Customer and Driver.

## Repository Structure (Monorepo)

```
pan-india-logistics-platform/
├── backend/                # Node.js + Express + MongoDB + Socket.IO REST API
├── web-portal/             # React (Vite) — Admin panel + Enterprise portal
├── mobile-customer-app/    # Flutter — Customer (Shipper) app
├── mobile-driver-app/      # Flutter — Driver / Fleet Owner app
├── docs/                   # SRS, API contracts, architecture, workflow docs
├── infra/                  # Nginx config, Docker files
└── .github/workflows/      # CI pipelines
```

## Tech Stack

| Layer | Technology |
|---|---|
| Customer App | Flutter (Android/iOS) |
| Driver App | Flutter (Android/iOS) |
| Admin & Enterprise Web Portal | React 18 + Vite + TailwindCSS |
| Backend API | Node.js + Express |
| Real-time | Socket.IO (GPS tracking, order status) |
| Database | MongoDB (Atlas) |
| File Storage | AWS S3 |
| Payments | Razorpay |
| Push Notifications | Firebase Cloud Messaging |
| SMS OTP | MSG91 / Twilio |
| Auth | JWT (access + refresh tokens) |

## High-Level Architecture

```
Flutter Customer App ─┐                         ┌─ MongoDB Atlas
Flutter Driver App ───┼─ HTTPS/REST + Socket.IO ─┤  Node.js API  ├─ AWS S3
React Admin/Enterprise ┘                         └─ Redis (cache, optional)
                                                        │
                                          Google Maps · Razorpay · Firebase FCM
```

Each service (Auth, Booking, Tracking, Payment, Notification, Invoice, Admin) is organized as
its own controller/service/model layer inside `backend/src/` for independent testability, per
the modularity goal in the SRS.

## Getting Started

### Backend
```bash
cd backend
cp .env.example .env   # fill in Mongo URI, JWT secrets, Razorpay/Firebase keys
npm install
npm run dev             # nodemon, http://localhost:5000
```

### Web Portal (Admin + Enterprise)
```bash
cd web-portal
npm install
npm run dev              # http://localhost:5174
```

### Mobile Apps (Flutter)
```bash
cd mobile-customer-app   # or mobile-driver-app
flutter pub get
flutter run
```

## Documentation

- `docs/srs/` — Original SRS, feature list, workflow, and full dev-plan PDFs
- `docs/api-contracts/` — REST API endpoint reference (see backend routes for source of truth)
- `docs/architecture/` — System architecture & database schema notes
- `docs/workflows/` — End-to-end process flows (booking, tracking, payments, enterprise, admin)

## Branching Strategy

- `main` — production, protected, deploys to `api.yourdomain.com`
- `develop` — staging/QA integration branch
- `feature/*` — individual feature branches, PR into `develop`

## Team Roles

Flutter (Senior — Customer app), Flutter (Junior — Driver app), Backend (Node.js), MERN (Web
Portal), QA Engineer, Project Manager — see `docs/srs/logistics_platform_project_document.pdf`
Section 10 for full responsibilities and the 40-day phase plan.

---
Confidential — Internal Use Only.
